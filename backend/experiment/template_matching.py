import cv2
import numpy as np
import io
import base64
from flask import Flask, request, jsonify, render_template_string
from flask_cors import CORS
from PIL import Image

app = Flask(__name__)
CORS(app)

# Simple HTML Upload Form
HTML_TEMPLATE = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Template Matching</title>
</head>
<body>
    <h2>Upload Image and Template</h2>
    <form action="/template-matching" method="post" enctype="multipart/form-data">
        <label>Main Image:</label>
        <input type="file" name="image" required><br><br>
        <label>Template Image:</label>
        <input type="file" name="template" required><br><br>
        <button type="submit">Upload and Match</button>
    </form>
    
    {% if processed_image %}
        <h3>Best Match: {{ best_method }}</h3>
        <h4>Objects Found: {{ object_count }}</h4>
        <img src="data:image/png;base64,{{ processed_image }}" alt="Processed Image">
    {% endif %}
</body>
</html>
"""

@app.route("/", methods=["GET"])
def index():
    return render_template_string(HTML_TEMPLATE)


@app.route("/template-matching", methods=["POST"])
def template_matching():
    try:
        if "image" not in request.files or "template" not in request.files:
            return jsonify({"error": "Both image and template files are required"}), 400

        # Read images
        image_file = request.files["image"]
        template_file = request.files["template"]

        # Convert images to OpenCV format
        img = cv2.imdecode(np.frombuffer(image_file.read(), np.uint8), cv2.IMREAD_COLOR)
        template = cv2.imdecode(np.frombuffer(template_file.read(), np.uint8), cv2.IMREAD_COLOR)

        # Convert images to grayscale
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

        best_method = None
        object_count = 0

        # Store bounding boxes
        bounding_boxes = []

        # Threshold for detecting multiple matches
        threshold = 0.8  # Adjust this as needed

        # Sensitivity for rounding coordinates
        sensitivity = 100

        for method_name, method in methods.items():
            result = cv2.matchTemplate(img_gray, template_gray, method)

            # For each match, check if it exceeds the threshold
            if method in [cv2.TM_SQDIFF, cv2.TM_SQDIFF_NORMED]:
                min_val, _, min_loc, _ = cv2.minMaxLoc(result)
                if min_val < threshold:
                    top_left = min_loc
                    bottom_right = (top_left[0] + w, top_left[1] + h)
                    bounding_boxes.append((top_left, bottom_right))
                    object_count += 1
            else:
                _, max_val, _, max_loc = cv2.minMaxLoc(result)
                if max_val > threshold:
                    top_left = max_loc
                    bottom_right = (top_left[0] + w, top_left[1] + h)
                    bounding_boxes.append((top_left, bottom_right))
                    object_count += 1

        # Merge duplicate detections based on sensitivity
        unique_bounding_boxes = set()
        for top_left, bottom_right in bounding_boxes:
            # Round the coordinates to avoid duplicates close to each other
            rounded_top_left = (round(top_left[0] / sensitivity), round(top_left[1] / sensitivity))
            rounded_bottom_right = (round(bottom_right[0] / sensitivity), round(bottom_right[1] / sensitivity))

            # Add the rounded bounding box to the set (automatically avoids duplicates)
            unique_bounding_boxes.add((rounded_top_left, rounded_bottom_right))

        # Draw bounding boxes on the original image
        for top_left, bottom_right in unique_bounding_boxes:
            # Convert back to the original scale
            top_left = (top_left[0] * sensitivity, top_left[1] * sensitivity)
            bottom_right = (bottom_right[0] * sensitivity, bottom_right[1] * sensitivity)

            cv2.rectangle(img, top_left, bottom_right, (0, 255, 0), 2)

        # Convert processed image to Base64
        img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        pil_img = Image.fromarray(img_rgb)
        img_io = io.BytesIO()
        pil_img.save(img_io, "PNG")
        img_io.seek(0)
        img_base64 = base64.b64encode(img_io.read()).decode("utf-8")

        return render_template_string(
            HTML_TEMPLATE,
            best_method=best_method,
            object_count=len(unique_bounding_boxes),
            processed_image=img_base64,
        )

    except Exception as e:
        return jsonify({"error": str(e)}), 500


if __name__ == "__main__":
    app.run(debug=True)
