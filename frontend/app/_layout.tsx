import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { StyleSheet, LogBox } from 'react-native';
import { GestureHandlerRootView } from 'react-native-gesture-handler';

LogBox.ignoreAllLogs(true);

export default function RootLayout() {
  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <StatusBar style="auto" />
      <Stack>
        <Stack.Screen
          name="(tabs)"
          options={{
            headerShown: false,
          }}
        />
      </Stack>
    </GestureHandlerRootView>
  );
}
