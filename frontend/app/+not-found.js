import { View, StyleSheet } from 'react-native';
import { Fragment } from 'react';
import { Link, Stack } from 'expo-router';

export default function NotFoundScreen() {
  return (
    <Fragment>
      <Stack.Screen
        options={{
          title: 'Oops! Not found',
          headerStyle: {
            backgroundColor: '#25292e',
          },
          headerTintColor: '#50AB5E',
          headerShadowVisible: false,
        }}
      />
      <View style={styles.container}>
        <Link href="/" style={styles.button}>
          Go back to Home Screen!
        </Link>
      </View>
    </Fragment>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F3ECF8',
    justifyContent: 'center',
    alignItems: 'center',
  },

  button: {
    fontSize: 20,
    textDecorationLine: 'underline',
    color: '#25292e',
  },
});
