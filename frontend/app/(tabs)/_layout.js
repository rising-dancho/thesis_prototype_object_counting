import { Tabs } from 'expo-router';
import { StyleSheet } from 'react-native';
import { Ionicons } from '@expo/vector-icons';

export default function TabsLayout() {
  return (
    <Tabs
      screenOptions={{
        tabBarActiveTintColor: '#50AB5E',
        tabBarInactiveTintColor: '#3F7140', // Customize inactive color here
        headerStyle: {
          backgroundColor: '#25292e',
        },
        headerShadowVisible: false,
        headerTintColor: '#50AB5E',

        tabBarStyle: {
          backgroundColor: '#25292e',
          borderTopColor: '#3F7140', // Change the border color here
          borderTopWidth: 1, // Adjust border width if needed
          shadowColor: '#50AB5E', // Shadow color
          shadowOpacity: 0.22, // Shadow opacity
          shadowRadius: 30, // Radius of the shadow
          elevation: 1, // For Android
        },
      }}
    >
      <Tabs.Screen
        name="index"
        options={{
          headerTitle: 'Objects Counter Prototype',
          tabBarLabel: 'Count',
          tabBarIcon: ({ focused, color }) => (
            <Ionicons
              name={focused ? 'sparkles' : 'sparkles-outline'}
              color={color}
              size={24}
            />
          ),
        }}
      />
      <Tabs.Screen
        name="about"
        options={{
          headerTitle: 'Objects Counter Prototype',
          tabBarLabel: 'About',
          tabBarIcon: ({ focused, color }) => (
            <Ionicons
              name={focused ? 'alert-circle' : 'alert-circle-outline'}
              color={color}
              size={24}
            />
          ),
        }}
      />
    </Tabs>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#25292e',
    justifyContent: 'center',
    alignItems: 'center',
  },

  button: {
    fontSize: 20,
    textDecorationLine: 'underline',
    color: '#fff',
  },
});
