import cv2
import imutils
import numpy as np
import matplotlib.pyplot as plt
from flask import Flask, request, jsonify, send_file
import io
import os
from PIL import Image
from flask_cors import CORS
import base64
from werkzeug.utils import secure_filename

# Initialize Flask app
app = Flask(__name__)
CORS(app)

# Allow only specific file types
ALLOWED_EXTENSIONS = {"png", "jpg", "jpeg", "gif"}


def allowed_file(filename):
    return "." in filename and filename.rsplit(".", 1)[1].lower() in ALLOWED_EXTENSIONS


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

        # Step 7: Draw bounding rectangles, count objects, and add number labels
        object_count = 0
        for i, cnt in enumerate(cnts):
            if cv2.contourArea(cnt) > 200:  # Filter out small contours based on area
                object_count += 1
                x1, y1, w, h = cv2.boundingRect(cnt)
                cv2.rectangle(img, (x1, y1), (x1 + w, y1 + h), (0, 255, 0), 3)

                # Calculate the centroid of the bounding box
                cx = x1 + w // 2
                cy = y1 + h // 2

                # Add a label with the object's count inside the box
                cv2.putText(
                    img,
                    f"{object_count}",
                    (cx - 10, cy + 10),  # Center the label
                    cv2.FONT_HERSHEY_SIMPLEX,
                    1.25,  # Font scale
                    (155, 25, 25),  # Color (blue)
                    3,  # Thickness
                )

        # Add text label for the total object count (outside the loop)
        cv2.putText(
            img,
            f"Total: {object_count}",
            (50, 50),  # Position of the label
            cv2.FONT_HERSHEY_SIMPLEX,
            1,  # Font scale
            (0, 0, 0),  # Color (red)
            2,  # Thickness
        )

        # Convert processed image (BGR) to RGB for sending in the response
        img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)

        # Encode image as base64
        pil_img = Image.fromarray(img_rgb)
        img_io = io.BytesIO()
        pil_img.save(img_io, "PNG")
        img_io.seek(0)
        img_base64 = base64.b64encode(img_io.read()).decode("utf-8")

        # Return JSON response with object count and base64 image
        return (
            jsonify(
                {
                    "object_count": object_count,
                    "message": "Image processed successfully!",
                    "processed_image": img_base64,
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
    if not os.path.exists("uploads"):
        os.makedirs("uploads")

    app.run(debug=True)
