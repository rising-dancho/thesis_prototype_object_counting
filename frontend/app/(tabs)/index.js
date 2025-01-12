import {
  View,
  StyleSheet,
  Platform,
  Pressable,
  Text,
  TextInput,
} from 'react-native';
import * as ImagePicker from 'expo-image-picker';
import { useEffect, useState, useRef } from 'react';
import * as MediaLibrary from 'expo-media-library';
import { captureRef } from 'react-native-view-shot';
import domtoimage from 'dom-to-image';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import axios from 'axios';
import Ionicons from '@expo/vector-icons/Ionicons';

// components
import Button from '../../components/Button';
import CircleButton from '../../components/CircleButton';
import ImageViewer from '../../components/ImageViewer';
import IconButton from '../../components/IconButton';
// import PanGesture from '../../components/PanGesture';

export default function Index() {
  // hooks
  const [status, requestPermission] = MediaLibrary.usePermissions();
  const [selectedImage, setSelectedImage] = useState(undefined);

  // --- Bounding Boxes ---
  const [boxes, setBoxes] = useState([]); // Holds the bounding boxes
  const [response, setResponse] = useState(null);
  const [imageDimensions, setImageDimensions] = useState(null); // Holds image dimensions

  const [parentDimensions, setParentDimensions] = useState({
    width: 0,
    height: 0,
  });
  const [isAddingBox, setIsAddingBox] = useState(false);

  // navigation pagination
  const [currentPage, setCurrentPage] = useState('choosePhoto');

  // ui
  const imageRef = useRef(null);
  const [title, setTitle] = useState('');
  const [count, setCount] = useState('');
  const [timestamp, setTimestamp] = useState('');
  const [isCountClicked, setIsCountClicked] = useState(false);

  // methods
  useEffect(() => {
    if (!status?.granted) {
      requestPermission();
    }
  }, [status, requestPermission]);

  useEffect(() => {
    console.log(response, 'RESPONSE');
    console.log(selectedImage, 'selectedImage');
  }, [response]); // This will run whenever 'response' changes

  const selectImage = async () => {
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
      return selectedAsset;
    } else {
      alert('You did not select any image.');
      return undefined;
    }
  };

  const handleAddBox = (event) => {
    if (isAddingBox) {
      const { locationX, locationY } = event.nativeEvent;
      setBoxes((prevBoxes) => [
        ...prevBoxes,
        { x: locationX, y: locationY, width: 100, height: 100 },
      ]);
      setIsAddingBox(false); // Disable adding mode after placing one box
    }
  };

  const pickImageAsync = async () => {
    const selectedAsset = await selectImage();
    if (selectedAsset) {
      setSelectedImage(selectedAsset);
      setCurrentPage('showAppOptions');
    }
  };

  const onReset = () => {
    setCurrentPage('choosePhoto');
    setTitle('');
    setCount('');
    setTimestamp('');
    setSelectedImage(undefined);
    setIsCountClicked(false);
    setBoxes([]);
  };

  const processImage = async () => {
    try {
      // Ensure an image has already been selected before processing
      if (!selectedImage) {
        alert('Please select an image first.');
        return;
      }

      getTimestamp();

      // Indicate that the CircleButton has been clicked
      setIsCountClicked(true);

      // Create FormData for upload
      const formData = new FormData();

      if (Platform.OS === 'web') {
        // For web, fetch the file and convert it into a Blob
        const response = await fetch(selectedImage);
        const blob = await response.blob();
        formData.append('image', blob, 'uploaded-image.jpg');
      } else {
        // For React Native, use a compatible format
        formData.append('image', {
          uri: selectedImage,
          name: 'uploaded-image.jpg',
          type: 'image/jpeg',
        }); // Use 'as any' to bypass strict type checks for React Native
      }

      // Upload image to the server
      const res = await axios.post(
        'http://localhost:5000/image-processing',
        formData,
        {
          headers: { 'Content-Type': 'multipart/form-data' },
        }
      );

      setResponse(res.data);
      setCount(res.data.object_count);
      console.log(res.data.object_count, 'object_count');
      console.log(response, 'RESPONSE');
      console.log(res.data.bounding_boxes, 'res.data.bounding_boxes'); // box coordinates
      console.log(res.data, 'res:data');
      console.log(
        res.data.image_dimensions.height,
        'res.data.image_dimensions.height'
      ); // image dimension
      console.log(
        res.data.image_dimensions.width,
        'res.data.image_dimensions.width'
      );

      // Call addBox for each bounding box in the response
      setBoxes(
        res.data.bounding_boxes.map((box) => ({
          x: box[0],
          y: box[1],
          width: box[2],
          height: box[3],
        }))
      );
    } catch (error) {
      console.error(
        'Error picking or uploading image:',
        error.response?.data || error.message
      );
    }
  };

  const onSaveImageAsync = async () => {
    if (Platform.OS !== 'web') {
      try {
        const localUri = await captureRef(imageRef, {
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
          quality: 1,
        });
        let link = document.createElement('a');
        link.download = 'processed-image.jpeg';
        link.href = dataUrl;
        link.click();
      } catch (e) {
        console.log(e);
      }
    }
  };

  const getTimestamp = () => {
    const date = new Date();

    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0'); // Months are 0-indexed
    const day = String(date.getDate()).padStart(2, '0');

    let hours = date.getHours();
    const minutes = String(date.getMinutes()).padStart(2, '0');
    const seconds = String(date.getSeconds()).padStart(2, '0');

    // Determine AM or PM and convert to 12-hour format
    const ampm = hours >= 12 ? 'PM' : 'AM';
    hours = hours % 12 || 12; // Convert 0 to 12 for midnight

    // Format result
    let result = `${year}-${month}-${day} ${hours}:${minutes}:${seconds} ${ampm}`;

    return setTimestamp(result);
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
    <GestureHandlerRootView style={styles.container}>
      <View
        style={styles.imageContainer}
        onStartShouldSetResponder={() => true}
        onResponderRelease={handleAddBox}
        onLayout={(event) => {
          let { width, height } = event.nativeEvent.layout;
          setParentDimensions({ width, height });
        }}
      >
        <View
          ref={imageRef}
          collapsable={false}
          key={selectedImage ? selectedImage : 'reset'}
        >
          {selectedImage !== undefined && (
            <ImageViewer
              imgSource={selectedImage ? selectedImage : undefined}
              text={title}
              count={count}
              timestamp={timestamp}
              clicked={isCountClicked}
              boxes={boxes}
              setBoxes={setBoxes}
              response={response}
              scaleBoxCoordinates={scaleBoxCoordinates}
              imageDimensions={imageDimensions}
            />
          )}
        </View>
      </View>

      {currentPage === 'choosePhoto' && (
        <View style={styles.buttonContainer}>
          <Button
            theme="primary"
            label="Choose a photo"
            onPress={pickImageAsync}
          />
          {/* <Button
            label="Use this photo"
            onPress={() => currentPage('showAppOptions')}
          /> */}
        </View>
      )}

      {currentPage === 'showAppOptions' && (
        <View style={styles.buttonContainer}>
          <Text
            style={{
              color: 'white',
              width: '100%',
              marginBottom: 8,
              fontWeight: 'bold',
            }}
          >
            File name
          </Text>
          <TextInput
            value={title}
            placeholder="Type in your file name.."
            onChangeText={(text) => setTitle(text)}
            style={{
              backgroundColor: '#ffffff', // Input background
              color: '#000000', // Text color
              fontWeight: 'bold',
              marginBottom: 10,
              padding: 10,
              borderRadius: 6,
              width: '100%',
            }}
            placeholderTextColor="#aaa" // Placeholder text color
          />
          <View style={styles.optionsRow}>
            <IconButton icon="refresh" label="Reset" onPress={onReset} />
            <CircleButton onPress={processImage} />
            <IconButton
              icon="arrow-forward"
              label="Next"
              onPress={() => setCurrentPage('showEditPage')}
            />
          </View>
        </View>
      )}

      {currentPage === 'showEditPage' && (
        <View style={styles.buttonContainer}>
          <View style={styles.buttonGap}>
            <IconButton
              icon="arrow-back"
              label="Back"
              onPress={() => setCurrentPage('showAppOptions')}
            />
            <IconButton
              icon="add"
              label="Add"
              onPress={() => setIsAddingBox(true)}
            />
            {/* Custom Pressable Icon */}

            <Pressable
              style={styles.iconButton}
              onPress={() => alert('Remove')}
            >
              <Ionicons name="close" size={24} color="#fff" />
              <Text style={styles.iconButtonLabel}>Remove</Text>
            </Pressable>

            {/* ----- */}
            <IconButton
              icon="save-alt"
              label="Save"
              onPress={onSaveImageAsync}
            />
          </View>
        </View>
      )}
    </GestureHandlerRootView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#25292e',
    alignItems: 'center',
  },
  iconButton: {
    justifyContent: 'center',
    alignItems: 'center',
    marginHorizontal: 20,
  },
  iconButtonLabel: {
    color: '#fff',
    marginTop: 12,
  },
  imageContainer: {
    flex: 1,
    flexDirection: 'column',
    margin: 20,
    overflow: 'hidden',
    width: 520,
    height: 640,
    // borderStyle: 'solid',
    // borderColor: 'red',
    // borderWidth: 1,
  },
  buttonGap: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'space-evenly', // Evenly spaces the buttons
    alignItems: 'center',
    width: '100%', // Ensures full width of the parent container
    paddingHorizontal: 20, // Optional: Add some padding on both sides
    marginVertical: 10, // Add vertical margin to give buttons breathing room
  },
  buttonContainer: {
    flex: 1 / 4,
    alignItems: 'center',
    marginBottom: 10,
    // borderStyle: 'solid',
    // borderColor: 'red',
    // borderWidth: 1,
  },
  optionsRow: {
    flex: 2,
    alignItems: 'center',
    flexDirection: 'row',
  },
  text: {
    color: 'red',
    marginTop: 10,
  },
  objectCount: {
    fontSize: 18,
    marginTop: 10,
  },
  svg: {
    position: 'absolute',
    top: 0,
    left: 0,
    zIndex: 999,
  },
});
