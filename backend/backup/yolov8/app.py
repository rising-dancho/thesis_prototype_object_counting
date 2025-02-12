from flask import Flask, request, jsonify
import onnxruntime as ort
import numpy as np
import cv2

# Initialize Flask app
app = Flask(__name__)

# Load the ONNX model
session = ort.InferenceSession("./best.onnx", providers=["CPUExecutionProvider"])


def run_yolo_onnx(image):
    input_shape = (640, 640)  # Adjust if needed
    img_resized = cv2.resize(image, (640, 640)) / 255.0
    img_resized = img_resized.transpose(2, 0, 1).astype(np.float32)  # HWC to CHW
    img_resized = np.expand_dims(img_resized, axis=0)  # Add batch dimension

    # Run inference
    input_name = session.get_inputs()[0].name
    output_name = session.get_outputs()[0].name
    outputs = session.run([output_name], {input_name: img_resized})

    # Extract bounding boxes
    detections = outputs[0][0]  # Assuming first batch
    bounding_boxes = []
    object_count = 0

    for det in detections:
        x1, y1, x2, y2, conf, cls = det[:6]  # Adjust if needed

        # Normalize coordinates if required
        x1, y1, x2, y2 = (
            x1 * image.shape[1],
            y1 * image.shape[0],
            x2 * image.shape[1],
            y2 * image.shape[0],
        )

        if conf > 0.5:  # Confidence threshold
            object_count += 1
            w, h = x2 - x1, y2 - y1
            bounding_boxes.append(
                {
                    "x": int(x1),
                    "y": int(y1),
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

        # Run YOLO model
        object_count, bounding_boxes = run_yolo_onnx(img)

        return (
            jsonify(
                {
                    "object_count": object_count,
                    "bounding_boxes": bounding_boxes,
                    "message": "Image processed successfully!",
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
