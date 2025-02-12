from flask import Flask, request, jsonify
import onnxruntime as ort
import numpy as np
import cv2
import io
import base64
from PIL import Image
from flask_cors import CORS

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
    object_count = 0

    for det in detections:
        x1, y1, x2, y2, conf, cls = det[:6]

        # Normalize confidence (if needed)
        if conf > 1:  # Model might return confidence as percentage
            conf /= 100.0

        if conf >= 0.75:  # Ensure proper threshold check
            object_count += 1
            x1, y1, x2, y2 = (
                x1 * image.shape[1],
                y1 * image.shape[0],
                x2 * image.shape[1],
                y2 * image.shape[0],
            )

            # Ensure width and height are non-negative
            w, h = abs(x2 - x1), abs(y2 - y1)

            bounding_boxes.append(
                {
                    "x": int(min(x1, x2)),  # Ensure x is always the left coordinate
                    "y": int(min(y1, y2)),  # Ensure y is always the top coordinate
                    "width": int(w),
                    "height": int(h),
                    "confidence": float(conf),
                    "class_id": int(cls),
                }
            )

    return object_count, bounding_boxes



@app.route("/image-processing", methods=["POST"])
def automatic_process_image():
    try:
        if "image" not in request.files:
            return jsonify({"error": "No file uploaded"}), 400

        file = request.files["image"]
        npimg = np.frombuffer(file.read(), np.uint8)
        img = cv2.imdecode(npimg, cv2.IMREAD_COLOR)

        if img is None:
            return jsonify({"error": "Invalid image data"}), 400

        # Extract image dimensions
        height, width, _ = img.shape

        # Run YOLO model to get detections
        object_count, bounding_boxes = run_yolo_onnx(img)

        # Convert image to Base64 format
        img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)  # Convert BGR to RGB
        pil_img = Image.fromarray(img_rgb)
        img_io = io.BytesIO()
        pil_img.save(img_io, "PNG")
        img_io.seek(0)
        img_base64 = base64.b64encode(img_io.read()).decode("utf-8")

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
    app.run(debug=True, port=5000)
