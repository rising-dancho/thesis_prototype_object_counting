import React, { useState, Fragment } from 'react';
import {
  View,
  Text,
  Button,
  Image,
  FlatList,
  StyleSheet,
  Platform,
  ScrollView,
} from 'react-native';
import axios from 'axios';
import * as ImagePicker from 'expo-image-picker';
import Svg, { Rect, Text as SvgText } from 'react-native-svg';

const ImageUpload = () => {
  const [response, setResponse] = useState(null);
  const [selectedImage, setSelectedImage] = useState(undefined);
  const [error, setError] = useState(null);
  const [boxes, setBoxes] = useState([]); // Holds the bounding boxes
  const [imageDimensions, setImageDimensions] = useState(null); // Holds image dimensions

  const handleSubmit = async () => {
    if (!selectedImage) {
      setError('No image selected');
      return;
    }

    const formData = new FormData();

    if (Platform.OS === 'web') {
      const response = await fetch(selectedImage);
      const blob = await response.blob();
      formData.append('image', blob, 'uploaded-image.jpg');
    } else {
      formData.append('image', {
        uri: selectedImage,
        type: 'image/jpeg',
        name: 'uploaded-image.jpg',
      });
    }

    try {
      const res = await axios.post(
        'http://localhost:5000/image-processing',
        formData,
        {
          headers: { 'Content-Type': 'multipart/form-data' },
        }
      );
      setResponse(res.data);
      console.log(res.data.bounding_boxes); // box coordinates
      console.log(res.data);
      console.log(res.data.image_dimensions.height); // image dimension
      console.log(res.data.image_dimensions.width);

      // Call addBox for each bounding box in the response
      res.data.bounding_boxes.forEach((box) => {
        setBoxes((prevBoxes) => [
          ...prevBoxes,
          { x: box[0], y: box[1], width: box[2], height: box[3] }, // Add each box
        ]);
      });

      setError(null);
    } catch (err) {
      setError('Error uploading image: ' + err.message);
      setResponse(null);
    }
  };

  const selectImage = async () => {
    try {
      let result = await ImagePicker.launchImageLibraryAsync({
        mediaTypes: ['images'],
        allowsEditing: true,
        quality: 1,
      });

      if (!result.canceled) {
        const selectedAsset = result.assets[0].uri;
        const { width, height } = result.assets[0];
        setSelectedImage(selectedAsset);
        setImageDimensions({ width, height });
        setError(null);
      } else {
        setError('You did not select any image.');
      }
    } catch (err) {
      setError('Error selecting image: ' + err.message);
    }
  };

  // Scale the bounding box coordinates relative to the image size
  const scaleBoxCoordinates = (box) => {
    if (imageDimensions) {
      const { width: imgWidth, height: imgHeight } = imageDimensions;
      return {
        x: (box.x / imgWidth) * imageDimensions.width, // Adjust to image's displayed width
        y: (box.y / imgHeight) * imageDimensions.height, // Adjust to image's displayed height
        width: (box.width / imgWidth) * imageDimensions.width, // Adjust to image's displayed width
        height: (box.height / imgHeight) * imageDimensions.height, // Adjust to image's displayed height
      };
    }
    return box;
  };

  return (
    <ScrollView contentContainerStyle={styles.container}>
      <Text style={styles.title}>Upload Image for Processing</Text>
      <Button title="Select Image" onPress={selectImage} />
      <Button
        title="Upload and Process"
        onPress={handleSubmit}
        disabled={!selectedImage}
      />

      {error && <Text style={styles.error}>{error}</Text>}

      {/* {image && <Image source={{ uri: image }} style={styles.image} />} */}

      {response && (
        <View>
          <Text style={styles.subtitle}>Processed Image:</Text>

          <View style={styles.imageContainer}>
            <Image
              source={{
                uri: `data:image/png;base64,${response.processed_image}`,
              }}
              style={{
                width: imageDimensions?.width,
                height: imageDimensions?.height,
                resizeMode: 'contain', // Ensures image is contained within bounds
              }}
            />
            {/* SVG component to draw the boxes */}
            {imageDimensions && (
              <Svg
                height={imageDimensions.height}
                width={imageDimensions.width}
                style={styles.svg}
              >
                {boxes.map((box, index) => {
                  const scaledBox = scaleBoxCoordinates(box);
                  return (
                    <Fragment key={index}>
                      {/* Bounding Box */}
                      <Rect
                        x={scaledBox.x}
                        y={scaledBox.y}
                        width={scaledBox.width}
                        height={scaledBox.height}
                        stroke="#00FF00"
                        fill="transparent"
                        strokeWidth="3"
                      />
                      {/* Object Number */}
                      <SvgText
                        x={scaledBox.x + scaledBox.width / 2}
                        y={scaledBox.y + scaledBox.height / 2}
                        fill="#122FBA"
                        fontSize="32"
                        fontWeight="bold"
                        textAnchor="middle"
                      >
                        {index + 1}
                      </SvgText>
                    </Fragment>
                  );
                })}
              </Svg>
            )}
          </View>

          <Text style={styles.objectCount}>
            Object Count: {response.object_count}
          </Text>
          <Text style={styles.boundingBoxTitle}>Bounding Boxes:</Text>
          <FlatList
            data={response.bounding_boxes}
            renderItem={({ item }) => (
              <Text>
                X: {item[0]}, Y: {item[1]}, Width: {item[2]}, Height: {item[3]}
              </Text>
            )}
            keyExtractor={(item, index) => index.toString()}
          />
        </View>
      )}
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    marginTop: '20%',
    marginBottom: '20%',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 20,
  },
  error: {
    color: 'red',
    marginTop: 10,
  },
  image: {
    width: 200,
    height: 200,
    marginTop: 10,
  },
  imageContainer: {
    position: 'relative',
    marginTop: 20,
  },
  objectCount: {
    fontSize: 18,
    marginTop: 10,
  },
  boundingBoxTitle: {
    fontSize: 18,
    marginTop: 10,
  },
  subtitle: {
    fontSize: 20,
    marginTop: 20,
  },
  svg: {
    position: 'absolute',
    top: 0,
    left: 0,
    zIndex: 999,
  },
});

export default ImageUpload;
