import React from 'react';
import { Text, StyleSheet } from 'react-native';

export default function TimestampLabel({ timestamp, style }) {
  return (
    <Text variant="labelLarge" style={[styles.timestamp, style]}>
      {timestamp}
    </Text>
  );
}

const styles = StyleSheet.create({
  timestamp: {
    fontSize: 14, // Default size for 'labelLarge' variant
    color: '#555', // Example color, adjust as needed
  },
});
