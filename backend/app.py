import cv2
import imutils
import numpy as np
from flask import Flask, request, jsonify
import io
from PIL import Image
from flask_cors import CORS
import base64
import onnxruntime as ort
from werkzeug.utils import secure_filename

# Initialize Flask app
app = Flask(__name__)
CORS(app)

# Load ONNX model
session = ort.InferenceSession("./best.onnx", providers=["CPUExecutionProvider"])


def run_yolo_onnx(image):
    input_shape = (640, 640)
    img_resized = cv2.resize(image, input_shape) / 255.0
    img_resized = img_resized.transpose(2, 0, 1).astype(np.float32)
    img_resized = np.expand_dims(img_resized, axis=0)

    input_name = session.get_inputs()[0].name
    output_name = session.get_outputs()[0].name
    outputs = session.run([output_name], {input_name: img_resized})

    detections = outputs[0][0]
    bounding_boxes = []
    confidences = []
    class_ids = []

    for det in detections:
        x1, y1, x2, y2, conf, cls = det[:6]

        if conf >= 0.75:
            x1, y1, x2, y2 = (
                x1 * image.shape[1],
                y1 * image.shape[0],
                x2 * image.shape[1],
                y2 * image.shape[0],
            )

            bounding_boxes.append([int(x1), int(y1), int(x2 - x1), int(y2 - y1)])
            confidences.append(float(conf))
            class_ids.append(int(cls))

    # Apply Non-Max Suppression (NMS)
    indices = cv2.dnn.NMSBoxes(
        bounding_boxes, confidences, score_threshold=0.75, nms_threshold=0.4
    )
    filtered_boxes = []
    for i in indices.flatten():
        filtered_boxes.append(
            {
                "x": bounding_boxes[i][0],
                "y": bounding_boxes[i][1],
                "width": bounding_boxes[i][2],
                "height": bounding_boxes[i][3],
                "confidence": confidences[i],
                "class_id": class_ids[i],
            }
        )

    return len(filtered_boxes), filtered_boxes


@app.route("/object-detection", methods=["POST"])
def detect_objects():
    try:
        if "image" not in request.files:
            return jsonify({"error": "No file uploaded"}), 400

        file = request.files["image"]
        npimg = np.frombuffer(file.read(), np.uint8)
        img = cv2.imdecode(npimg, cv2.IMREAD_COLOR)

        if img is None:
            return jsonify({"error": "Invalid image data"}), 400

        # Run YOLO model
        object_count, bounding_boxes = run_yolo_onnx(img)

        # Draw bounding boxes on the image
        for box in bounding_boxes:
            x, y, w, h = box["x"], box["y"], box["width"], box["height"]
            cv2.rectangle(img, (x, y), (x + w, y + h), (0, 255, 0), 2)
            cv2.putText(
                img,
                f"ID {box['class_id']} ({box['confidence']:.2f})",
                (x, y - 10),
                cv2.FONT_HERSHEY_SIMPLEX,
                0.5,
                (0, 255, 0),
                2,
            )

        # Convert image to Base64 format
        _, buffer = cv2.imencode(".png", img)
        img_base64 = base64.b64encode(buffer).decode("utf-8")

        return (
            jsonify(
                {
                    "object_count": object_count,
                    "message": "Image processed successfully!",
                    "bounding_boxes": bounding_boxes,
                    "image": img_base64,
                }
            ),
            200,
        )

    except Exception as e:
        return jsonify({"error": str(e)}), 500


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


@app.route("/")
def index():
    return "Flask server running with YOLOv8!"


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)