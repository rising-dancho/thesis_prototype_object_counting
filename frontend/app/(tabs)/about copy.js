import React, { useState } from 'react';
import {
  View,
  Text,
  Image,
  Button,
  FlatList,
  StyleSheet,
  TextInput,
  TouchableOpacity,
} from 'react-native';

const ImageWithBoundingBoxes = ({ image, initialBoxes }) => {
  const [boxes, setBoxes] = useState(initialBoxes || []);
  const [newBox, setNewBox] = useState({ x: '', y: '', width: '', height: '' });

  // Add a new bounding box
  const addBox = () => {
    if (
      newBox.x !== '' &&
      newBox.y !== '' &&
      newBox.width !== '' &&
      newBox.height !== ''
    ) {
      setBoxes([...boxes, newBox]);
      setNewBox({ x: '', y: '', width: '', height: '' });
    }
  };

  // Remove a bounding box
  const removeBox = (index) => {
    const updatedBoxes = boxes.filter((_, i) => i !== index);
    setBoxes(updatedBoxes);
  };

  return (
    <View style={styles.container}>
      <Image source={{ uri: image }} style={styles.image} />
      <Text style={styles.objectCount}>Object Count: {boxes.length}</Text>
      <FlatList
        data={boxes}
        renderItem={({ item, index }) => (
          <View style={styles.boxItem}>
            <Text>
              Box {index + 1}: X: {item.x}, Y: {item.y}, Width: {item.width},
              Height: {item.height}
            </Text>
            <TouchableOpacity
              style={styles.removeButton}
              onPress={() => removeBox(index)}
            >
              <Text style={styles.removeButtonText}>Remove</Text>
            </TouchableOpacity>
          </View>
        )}
        keyExtractor={(item, index) => index.toString()}
      />

      <View style={styles.inputRow}>
        <TextInput
          style={styles.input}
          placeholder="X"
          keyboardType="numeric"
          value={newBox.x}
          onChangeText={(text) => setNewBox({ ...newBox, x: text })}
        />
        <TextInput
          style={styles.input}
          placeholder="Y"
          keyboardType="numeric"
          value={newBox.y}
          onChangeText={(text) => setNewBox({ ...newBox, y: text })}
        />
        <TextInput
          style={styles.input}
          placeholder="Width"
          keyboardType="numeric"
          value={newBox.width}
          onChangeText={(text) => setNewBox({ ...newBox, width: text })}
        />
        <TextInput
          style={styles.input}
          placeholder="Height"
          keyboardType="numeric"
          value={newBox.height}
          onChangeText={(text) => setNewBox({ ...newBox, height: text })}
        />
        <Button title="Add Box" onPress={addBox} />
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 16,
  },
  image: {
    width: '100%',
    height: 300,
    resizeMode: 'contain',
  },
  objectCount: {
    fontSize: 18,
    marginTop: 10,
  },
  boxItem: {
    marginVertical: 5,
    padding: 10,
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 5,
  },
  removeButton: {
    marginTop: 5,
    backgroundColor: '#ff4d4d',
    padding: 5,
    borderRadius: 5,
  },
  removeButtonText: {
    color: 'white',
    textAlign: 'center',
  },
  inputRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 20,
  },
  input: {
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 5,
    padding: 5,
    marginRight: 10,
    width: 60,
  },
});

export default ImageWithBoundingBoxes;
