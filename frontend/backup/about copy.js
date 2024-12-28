import React, { useState } from 'react';
import {
  View,
  Text,
  Button,
  Image,
  FlatList,
  StyleSheet,
  Platform,
} from 'react-native';
import axios from 'axios';
import * as ImagePicker from 'expo-image-picker';

const ImageUpload = () => {
  const [image, setImage] = useState(null);
  const [response, setResponse] = useState(null);
  const [error, setError] = useState(null);

  const selectImage = async () => {
    try {
      let result = await ImagePicker.launchImageLibraryAsync({
        mediaTypes: ImagePicker.MediaTypeOptions.Images,
        allowsEditing: true,
        quality: 1,
      });

      if (!result.canceled) {
        const selectedAsset = result.assets[0].uri;
        setImage(selectedAsset);
        setError(null);
      } else {
        setError('You did not select any image.');
      }
    } catch (err) {
      setError('Error selecting image: ' + err.message);
    }
  };

  const handleSubmit = async () => {
    if (!image) {
      setError('No image selected');
      return;
    }

    const formData = new FormData();

    if (Platform.OS === 'web') {
      const response = await fetch(image);
      const blob = await response.blob();
      formData.append('image', blob, 'uploaded-image.jpg');
    } else {
      formData.append('image', {
        uri: image,
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
      setError(null);
    } catch (err) {
      setError('Error uploading image: ' + err.message);
      setResponse(null);
    }
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Upload Image for Processing</Text>
      <Button title="Select Image" onPress={selectImage} />
      <Button
        title="Upload and Process"
        onPress={handleSubmit}
        disabled={!image}
      />

      {error && <Text style={styles.error}>{error}</Text>}

      {image && <Image source={{ uri: image }} style={styles.image} />}

      {response && (
        <View>
          <Text style={styles.subtitle}>Processed Image:</Text>
          <Image
            source={{
              uri: `data:image/png;base64,${response.processed_image}`,
            }}
            style={styles.processedImage}
          />
          <Text style={styles.objectCount}>
            Object Count: {response.object_count}
          </Text>
          <Text style={styles.boundingBoxTitle}>Bounding Boxes:</Text>
          <FlatList
            data={response.bounding_boxes}
            renderItem={({ item }) => (
              <Text>
                X: {item.x}, Y: {item.y}, Width: {item.width}, Height: {item.height}
              </Text>
            )}
            keyExtractor={(item, index) => index.toString()}
          />
        </View>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 16,
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
  processedImage: {
    width: 300,
    height: 300,
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
});

export default ImageUpload;
