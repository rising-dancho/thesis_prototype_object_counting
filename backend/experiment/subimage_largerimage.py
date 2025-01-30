import cv2

# Read the input image
image = cv2.imread(
    "C:/Users/adfinem/Documents/Github/thesis_prototype_object_counting/backend/experiment/pipes.jpg"
)
image_copy = image.copy()

# Convert to grayscale
image_copy = cv2.cvtColor(image_copy, cv2.COLOR_BGR2GRAY)

# Read the template image (grayscale)
template = cv2.imread(
    "C:/Users/adfinem/Documents/Github/thesis_prototype_object_counting/backend/experiment/template.png",
    0,
)
w, h = template.shape[::-1]

# Apply template matching
result = cv2.matchTemplate(image_copy, template, cv2.TM_CCOEFF_NORMED)

# Find the best match location
min_val, max_val, min_loc, max_loc = cv2.minMaxLoc(result)

# Get the coordinates of the detected region
x1, y1 = max_loc
x2, y2 = (x1 + w, y1 + h)

# Draw a rectangle around the detected region
cv2.rectangle(image, (x1, y1), (x2, y2), (0, 0, 255), 2)

# Display the result with a rectangle
cv2.imshow("Detected Image", image)

# Display the result of the template matching (as heatmap)
cv2.imshow("Template Match Heatmap", result)

# Wait for key press to close the windows
cv2.waitKey(0)
cv2.destroyAllWindows()

# Save the output images
cv2.imwrite("path/to/output/image_result.jpg", image)
cv2.imwrite("path/to/output/template_result.jpg", result * 255.0)
