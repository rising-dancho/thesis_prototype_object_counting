import cv2
import imutils
import numpy as np
import matplotlib.pyplot as plt
from flask import Flask, request, jsonify, send_file
import io
from PIL import Image
from flask_cors import CORS
import base64
from werkzeug.utils import secure_filename

# Initialize Flask app
app = Flask(__name__)
CORS(app)


# Object detection and counting endpoint
@app.route("/image-processing", methods=["POST"])
def automatic_process_image():
    try:
        # Check if a file was uploaded
        if "image" not in request.files:
            return jsonify({"error": "No file uploaded"}), 400

        file = request.files["image"]
        print(f"Received file: {file.filename}")

        # Read the uploaded image
        npimg = np.frombuffer(file.read(), np.uint8)
        img = cv2.imdecode(npimg, cv2.IMREAD_COLOR)

        # Check if the image was properly loaded
        if img is None:
            return jsonify({"error": "Invalid image data"}), 400

        # Extract image dimensions (height, width, channels)
        height, width, channels = img.shape

        # Step 1: Apply median blur to reduce noise
        image_blur = cv2.medianBlur(img, 25)

        # Step 2: Convert to grayscale
        image_blur_gray = cv2.cvtColor(image_blur, cv2.COLOR_BGR2GRAY)

        # Step 3: Apply thresholding (Inverted binary)
        _, image_thresh = cv2.threshold(
            image_blur_gray, 240, 255, cv2.THRESH_BINARY_INV
        )

        # Step 4: Apply morphological operation to remove noise
        kernel = np.ones((3, 3), np.uint8)
        opening = cv2.morphologyEx(image_thresh, cv2.MORPH_OPEN, kernel)

        # Step 5: Apply distance transform and normalize the result
        dist_transform = cv2.distanceTransform(opening, cv2.DIST_L2, 5)
        _, last_image = cv2.threshold(
            dist_transform, 0.3 * dist_transform.max(), 255, 0
        )
        last_image = np.uint8(last_image)

        # Step 6: Find contours
        cnts = cv2.findContours(
            last_image.copy(), cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE
        )
        cnts = imutils.grab_contours(cnts)

        # Step 7: Collect bounding box data and count objects
        object_count = 0
        bounding_boxes = []

        for i, cnt in enumerate(cnts):
            if cv2.contourArea(cnt) > 200:  # Filter out small contours based on area
                object_count += 1
                x1, y1, w, h = cv2.boundingRect(cnt)
                bounding_boxes.append([x1, y1, w, h])

        # Convert processed image (BGR) to RGB for sending in the response
        img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)

        # Encode image as base64
        pil_img = Image.fromarray(img_rgb)
        img_io = io.BytesIO()
        pil_img.save(img_io, "PNG")
        img_io.seek(0)
        img_base64 = base64.b64encode(img_io.read()).decode("utf-8")

        # Return JSON response with object count, bounding boxes, image dimensions, and base64 image
        return (
            jsonify(
                {
                    "object_count": object_count,
                    "message": "Image processed successfully!",
                    "image_dimensions": {"width": width, "height": height},
                    "processed_image": img_base64,
                    "bounding_boxes": bounding_boxes,
                }
            ),
            200,
        )

    except Exception as e:
        return jsonify({"error": str(e)}), 500


# Template Matching Route
@app.route("/template-matching", methods=["POST"])
def template_matching():
    try:
        # Check if files are uploaded
        if "image" not in request.files or "template" not in request.files:
            return jsonify({"error": "Both image and template files are required"}), 400

        # Read main image
        image_file = request.files["image"]
        npimg = np.frombuffer(image_file.read(), np.uint8)
        img = cv2.imdecode(npimg, cv2.IMREAD_COLOR)

        # Read template image
        template_file = request.files["template"]
        np_template = np.frombuffer(template_file.read(), np.uint8)
        template = cv2.imdecode(np_template, cv2.IMREAD_COLOR)

        # Convert images to grayscale for matching
        img_gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        template_gray = cv2.cvtColor(template, cv2.COLOR_BGR2GRAY)

        # Get template dimensions
        h, w = template_gray.shape

        # OpenCV template matching methods
        methods = {
            "TM_CCOEFF": cv2.TM_CCOEFF,
            "TM_CCOEFF_NORMED": cv2.TM_CCOEFF_NORMED,
            "TM_CCORR": cv2.TM_CCORR,
            "TM_CCORR_NORMED": cv2.TM_CCORR_NORMED,
            "TM_SQDIFF": cv2.TM_SQDIFF,
            "TM_SQDIFF_NORMED": cv2.TM_SQDIFF_NORMED,
        }

        best_match = None
        best_method = None
        best_top_left = None
        best_val = None
        object_count = 0
        bounding_boxes = []

        for method_name, method in methods.items():
            img_copy = img_gray.copy()

            # Apply template matching
            result = cv2.matchTemplate(img_copy, template_gray, method)

            # Get threshold based on method type
            threshold = (
                0.8 if method in [cv2.TM_CCOEFF_NORMED, cv2.TM_CCORR_NORMED] else 0.2
            )

            # Get locations where template matches
            if method in [cv2.TM_SQDIFF, cv2.TM_SQDIFF_NORMED]:
                loc = np.where(result <= threshold)  # Lower values mean better matches
            else:
                loc = np.where(result >= threshold)  # Higher values mean better matches

            for pt in zip(*loc[::-1]):
                bounding_boxes.append([int(pt[0]), int(pt[1]), int(w), int(h)])
                object_count += 1
                cv2.rectangle(
                    img, (pt[0], pt[1]), (pt[0] + w, pt[1] + h), (0, 255, 0), 2
                )

            # Get best match for response
            min_val, max_val, min_loc, max_loc = cv2.minMaxLoc(result)
            if method in [cv2.TM_SQDIFF, cv2.TM_SQDIFF_NORMED]:
                top_left = min_loc
                match_val = min_val
            else:
                top_left = max_loc
                match_val = max_val

            # Store best match
            if (
                best_match is None
                or (
                    method not in [cv2.TM_SQDIFF, cv2.TM_SQDIFF_NORMED]
                    and match_val > best_val
                )
                or (
                    method in [cv2.TM_SQDIFF, cv2.TM_SQDIFF_NORMED]
                    and match_val < best_val
                )
            ):
                best_match = match_val
                best_method = method_name  # Convert method to string
                best_top_left = (
                    int(top_left[0]),
                    int(top_left[1]),
                )  # Convert int64 to int
                best_val = match_val

        # Convert image for response
        img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        pil_img = Image.fromarray(img_rgb)
        img_io = io.BytesIO()
        pil_img.save(img_io, "PNG")
        img_io.seek(0)
        img_base64 = base64.b64encode(img_io.read()).decode("utf-8")

        return (
            jsonify(
                {
                    "object_count": object_count,
                    # "bounding_boxes": bounding_boxes,
                    # "best_match_location": best_top_left,
                    "best_method": best_method,
                    # "processed_image": img_base64,
                }
            ),
            200,
        )

    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/")
def index():
    return "Flask server running!"


if __name__ == "__main__":
    app.run(debug=True)
