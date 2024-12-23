import React from 'react';
import { WebView } from 'react-native-webview';

type OpenCVWebViewProps = {
  selectedImageUri: string;
  minThreshold: number;
  maxThreshold: number;
};

const OpenCVWebView: React.FC<OpenCVWebViewProps> = ({
  selectedImageUri,
  minThreshold,
  maxThreshold,
}) => {
  const htmlContent = `
    <!DOCTYPE html>
    <html>
    <head>
      <script src="./assets/js/opencv.js"></script>
    </head>
    <body>
      <canvas id="canvas"></canvas>
      <script>
        window.onload = function() {
          const canvas = document.getElementById('canvas');
          const ctx = canvas.getContext('2d');

          const img = new Image();
          img.src = "${selectedImageUri}";

          img.onload = function() {
            canvas.width = img.width;
            canvas.height = img.height;
            ctx.drawImage(img, 0, 0);

            const src = cv.imread(canvas);
            const gray = new cv.Mat();
            const edges = new cv.Mat();
            cv.cvtColor(src, gray, cv.COLOR_RGBA2GRAY);
            cv.Canny(gray, edges, ${minThreshold}, ${maxThreshold});
            cv.imshow(canvas, edges);

            src.delete();
            gray.delete();
            edges.delete();
          };
        };
      </script>
    </body>
    </html>
  `;

  return <WebView originWhitelist={['*']} source={{ html: htmlContent }} />;
};

export default OpenCVWebView;
