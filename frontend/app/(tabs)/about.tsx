import React, { useState, useEffect, useRef } from 'react';
import { View, StyleSheet, Platform, Text } from 'react-native';
import * as ImagePicker from 'expo-image-picker';
import { captureRef } from 'react-native-view-shot';
import axios from 'axios';
import * as MediaLibrary from 'expo-media-library';
import Slider from '@react-native-community/slider';
import { GestureHandlerRootView } from 'react-native-gesture-handler';

// Components
import Button from '@/components/Button';
import CircleButton from '@/components/CircleButton';
import ImageViewer from '@/components/ImageViewer';
import IconButton from '@/components/IconButton';

const PlaceholderImage = require('@/assets/images/background-image.png');

export default function AboutScreen() {
  const [status, requestPermission] = MediaLibrary.usePermissions();
  const [selectedImage, setSelectedImage] = useState<string | undefined>(
    undefined
  );
  const [minThreshold, setMinThreshold] = useState(100);
  const [maxThreshold, setMaxThreshold] = useState(200);
  const [showAppOptions, setShowAppOptions] = useState(false);
  const [isModalVisible, setIsModalVisible] = useState(false);
  const imageRef = useRef<View>(null);

  useEffect(() => {
    if (!status?.granted) {
      requestPermission();
    }
  }, [status, requestPermission]);

  const pickAndUploadImage = async () => {
    try {
      let result = await ImagePicker.launchImageLibraryAsync({
        allowsEditing: true,
        quality: 1,
      });

      if (!result.canceled) {
        const selectedAsset = result.assets[0];

        const formData = new FormData();
        if (Platform.OS === 'web') {
          const response = await fetch(selectedAsset.uri);
          const blob = await response.blob();
          formData.append(
            'image',
            blob,
            selectedAsset.fileName || 'uploaded-image.jpg'
          );
        } else {
          formData.append('image', {
            uri: selectedAsset.uri,
            name: selectedAsset.fileName || 'uploaded-image.jpg',
            type: selectedAsset.type || 'image/jpeg',
          } as any);
        }

        // Send the image and slider values to the server
        await axios
          .post('http://127.0.0.1:5000/manual-image-processing', formData, {
            headers: { 'Content-Type': 'multipart/form-data' },
            params: {
              minThreshold,
              maxThreshold,
            },
          })
          .then((response) => {
            const { object_count, message, processed_image } = response.data;
            setSelectedImage(`data:image/png;base64,${processed_image}`);
            setShowAppOptions(true);
            alert('Object Count: ' + object_count);
            console.log(message);
          })
          .catch((error) => {
            console.error('Error:', error);
          });
      } else {
        alert('You did not select any image');
      }
    } catch (error) {
      console.error('Error picking or uploading image:', error);
    }
  };

  const onReset = () => {
    setShowAppOptions(false);
  };

  const onSaveImageAsync = async () => {
    if (Platform.OS !== 'web') {
      try {
        const localUri = await captureRef(imageRef, {
          height: 440,
          quality: 1,
        });

        await MediaLibrary.saveToLibraryAsync(localUri);
        if (localUri) {
          alert('Saved!');
        }
      } catch (e) {
        console.log(e);
      }
    }
  };

  return (
    <GestureHandlerRootView style={styles.container}>
      <View style={styles.imageContainer}>
        <View ref={imageRef} collapsable={false}>
          <ImageViewer imgSource={selectedImage || PlaceholderImage} />
        </View>
      </View>

      {showAppOptions ? (
        <View style={styles.footerContainer}>
          <View style={styles.optionsRow}>
            <IconButton icon="refresh" label="Reset" onPress={onReset} />
            <CircleButton onPress={onSaveImageAsync} />
          </View>
        </View>
      ) : (
        <View style={styles.footerContainer}>
          <Button
            theme="primary"
            label="Choose a photo"
            onPress={pickAndUploadImage}
          />
        </View>
      )}

      <View style={styles.sliderContainer}>
        <Text style={styles.sliderLabel}>Min Threshold: {minThreshold}</Text>
        <Slider
          style={styles.slider}
          minimumValue={0}
          maximumValue={255}
          step={1}
          value={minThreshold}
          onValueChange={(value) => setMinThreshold(value)}
        />
        <Text style={styles.sliderLabel}>Max Threshold: {maxThreshold}</Text>
        <Slider
          style={styles.slider}
          minimumValue={0}
          maximumValue={255}
          step={1}
          value={maxThreshold}
          onValueChange={(value) => setMaxThreshold(value)}
        />
      </View>
    </GestureHandlerRootView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#25292e',
    alignItems: 'center',
  },
  imageContainer: {
    flex: 1,
    justifyContent: 'center',
  },
  footerContainer: {
    flex: 1 / 3,
    alignItems: 'center',
  },
  optionsRow: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  sliderContainer: {
    width: '80%',
    marginTop: 20,
  },
  slider: {
    width: '100%',
    height: 40,
  },
  sliderLabel: {
    color: 'white',
    marginVertical: 10,
  },
});
