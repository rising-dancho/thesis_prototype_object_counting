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


@app.route("/manual-process-image", methods=["POST"])
def manual_process_image():
    if "file" not in request.files:
        return jsonify({"error": "No file part"}), 400

    file = request.files["file"]
    if file.filename == "":
        return jsonify({"error": "No selected file"}), 400

    if file and allowed_file(file.filename):
        filename = secure_filename(file.filename)
        filepath = os.path.join("uploads", filename)
        file.save(filepath)

        # Read the image using OpenCV
        image = cv2.imread(filepath)
        if image is None:
            return jsonify({"error": "Could not read image"}), 400

        # Get the threshold values from the request
        min_threshold = int(
            request.form.get("minThreshold", 100)
        )  # Default 100 if not provided
        max_threshold = int(
            request.form.get("maxThreshold", 200)
        )  # Default 200 if not provided

        # Convert image to grayscale
        gray_image = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

        # Perform edge detection with the thresholds from the frontend
        edges = cv2.Canny(gray_image, min_threshold, max_threshold)

        # Save the processed image
        output_filepath = os.path.join("uploads", "processed_" + filename)
        cv2.imwrite(output_filepath, edges)

        # Return the processed image
        return send_file(
            output_filepath,
            mimetype="image/jpeg",
            as_attachment=True,
            download_name="processed_image.jpg",
        )

    return jsonify({"error": "Invalid file format"}), 400


# Object detection and counting endpoint
@app.route("/process-image", methods=["POST"])
def automatic_process_image():
    try:
        # Check if a file was uploaded
        if "image" not in request.files:
            return jsonify({"error": "No file uploaded"}), 400

        file = request.files["image"]
        print(
            f"Received file: {file.filename}"
        )  # Log the filename to ensure it's being received

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
            last_image.copy(), cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE
        )
        cnts = imutils.grab_contours(cnts)

        # Step 7: Draw contours and label the objects
        object_count = 0
        for i, c in enumerate(cnts):
            ((x, y), radius) = cv2.minEnclosingCircle(c)
            if radius > 15:  # Filter out small contours based on radius
                object_count += 1
                # Draw the contour and the label
                cv2.putText(
                    img,
                    f"#{object_count}",
                    (int(x) - 45, int(y) + 20),
                    cv2.FONT_HERSHEY_SIMPLEX,
                    1,
                    (255, 0, 0),
                    2,
                )
                cv2.drawContours(img, [c], -1, (0, 255, 0), 2)

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
