import { Tabs } from 'expo-router';
import { StyleSheet } from 'react-native';
import { Ionicons } from '@expo/vector-icons';

export default function TabsLayout() {
  return (
    <Tabs
      screenOptions={{
        tabBarActiveTintColor: '#50AB5E',
        tabBarInactiveTintColor: '#25292e', // Customize inactive color here
        headerStyle: {
          backgroundColor: '#ebf6ed',
        },
        headerShadowVisible: true,
        headerTintColor: '#50AB5E',

        tabBarStyle: {
          backgroundColor: '#ebf6ed',
          borderTopColor: '#cee8d2', // Change the border color here
          borderTopWidth: 1, // Adjust border width if needed
        },
      }}
    >
      <Tabs.Screen
        name="index"
        options={{
          headerTitle: 'Prototype',
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
          headerTitle: 'Prototype',
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
