import { View, StyleSheet, Platform } from 'react-native';
import * as ImagePicker from 'expo-image-picker';
import { useEffect, useState, useRef } from 'react';
import * as MediaLibrary from 'expo-media-library';
import { captureRef } from 'react-native-view-shot';
import { type ImageSource } from 'expo-image';
import domtoimage from 'dom-to-image';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import axios from 'axios';

// components
import Button from '@/components/Button';
import CircleButton from '@/components/CircleButton';
import ImageViewer from '@/components/ImageViewer';
import IconButton from '@/components/IconButton';
import EmojiPicker from '@/components/EmojiPicker';
import EmojiList from '@/components/EmojiList';
import EmojiSticker from '@/components/EmojiSticker';

const PlaceholderImage = require('@/assets/images/background-image.png');

export default function Index() {
  // hooks
  const [status, requestPermission] = MediaLibrary.usePermissions();
  const [selectedImage, setSelectedImage] = useState<string | undefined>(
    undefined
  );
  const [showAppOptions, setShowAppOptions] = useState<boolean>(false);
  const [isModalVisible, setIsModalVisible] = useState<boolean>(false);
  const [pickedEmoji, setPickedEmoji] = useState<ImageSource | undefined>(
    undefined
  );
  const imageRef = useRef<View>(null);

  // methods
  useEffect(() => {
    if (!status?.granted) {
      requestPermission();
    }
  }, [status, requestPermission]);

  interface Asset {
    file: File; // You can replace with Blob if needed
    fileName: string;
    fileSize: number;
    height: number;
    width: number;
    mimeType: string;
    type: string;
  }

  const pickAndUploadImage = async () => {
    try {
      // Step 1: Launch image picker
      let result = await ImagePicker.launchImageLibraryAsync({
        allowsEditing: true,
        quality: 1,
      });

      // Step 2: Check if an image was selected
      if (!result.canceled) {
        const selectedAsset = result.assets[0];

        // Step 4: Create FormData for upload
        const formData = new FormData();

        if (Platform.OS === 'web') {
          // For web, fetch the file and convert it into a Blob
          const response = await fetch(selectedAsset.uri);
          const blob = await response.blob();
          formData.append(
            'image',
            blob,
            selectedAsset.fileName || 'uploaded-image.jpg'
          );
        } else {
          // For React Native, use a compatible format
          formData.append('image', {
            uri: selectedAsset.uri,
            name: selectedAsset.fileName || 'uploaded-image.jpg',
            type: selectedAsset.type || 'image/jpeg',
          } as any); // Use 'as any' to bypass strict type checks for React Native
        }

        // Step 5: Upload image to the server
        await axios
          .post('http://127.0.0.1:5000/image-processing', formData, {
            headers: { 'Content-Type': 'multipart/form-data' },
          })
          .then((response) => {
            const { object_count, message, processed_image } = response.data;

            // Update the selectedImage state with the base64 string (prepended with the appropriate data URL prefix)
            setSelectedImage(`data:image/png;base64,${processed_image}`);
            setShowAppOptions(true);

            alert('Object Count: ' + object_count);
            console.log(message);
            console.log('Server Response:', response.data);
          })
          .catch((error) => {
            console.error('Error:', error);
          });
      } else {
        alert('You did not select any image');
      }
    } catch (error: any) {
      console.error(
        'Error picking or uploading image:',
        error.response?.data || error.message
      );
    }
  };

  const onReset = () => {
    setShowAppOptions(false);
  };

  const onModalClose = () => {
    setIsModalVisible(false);
  };

  const onAddSticker = () => {
    setIsModalVisible(true);
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
    } else {
      try {
        const dataUrl = await domtoimage.toJpeg(imageRef.current, {
          quality: 0.95,
          width: 320,
          height: 440,
        });

        let link = document.createElement('a');
        link.download = 'sticker-smash.jpeg';
        link.href = dataUrl;
        link.click();
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
          {pickedEmoji && (
            <EmojiSticker imageSize={40} stickerSource={pickedEmoji} />
          )}
        </View>
      </View>

      {showAppOptions ? (
        <View style={styles.footerContainer}>
          <View style={styles.optionsRow}>
            <IconButton icon="refresh" label="Reset" onPress={onReset} />
            <CircleButton onPress={onAddSticker} />
            <IconButton
              icon="save-alt"
              label="Save"
              onPress={onSaveImageAsync}
            />
          </View>
        </View>
      ) : (
        <View style={styles.footerContainer}>
          <Button
            theme="primary"
            label="Choose a photo"
            onPress={pickAndUploadImage}
          />
          <Button
            label="Use this photo"
            onPress={() => setShowAppOptions(true)}
          />
        </View>
      )}
      <EmojiPicker isVisible={isModalVisible} onClose={onModalClose}>
        <EmojiList
          onSelect={(item) => setPickedEmoji(item)}
          onCloseModal={onModalClose}
        ></EmojiList>
      </EmojiPicker>
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
  },
  footerContainer: {
    flex: 1 / 3,
    alignItems: 'center',
  },
  optionsRow: {
    alignItems: 'center',
    flexDirection: 'row',
  },
});
