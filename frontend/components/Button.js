import { StyleSheet, View, Pressable, Text } from 'react-native';
import FontAwesome from '@expo/vector-icons/FontAwesome';

export default function Button({ label, theme, onPress }) {
  if (theme === 'primary') {
    return (
      <View style={[styles.buttonContainer, styles.primary]}>
        <Pressable style={[styles.button, styles.white]} onPress={onPress}>
          <FontAwesome
            name="picture-o"
            size={18}
            color="#123117"
            style={styles.buttonIcon}
          />
          <Text style={[styles.buttonLabel, { color: '#123117' }]}>
            {label}
          </Text>
        </Pressable>
      </View>
    );
  }

  return (
    <View style={styles.buttonContainer}>
      <Pressable style={styles.button} onPress={onPress}>
        <Text style={styles.buttonLabel}>{label}</Text>
      </Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  buttonContainer: {
    width: 320,
    height: 68,
    marginHorizontal: 20,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 3,
  },
  button: {
    borderRadius: 10,
    width: '100%',
    height: '100%',
    alignItems: 'center',
    justifyContent: 'center',
    flexDirection: 'row',
  },
  buttonIcon: {
    paddingRight: 8,
  },
  buttonLabel: {
    color: '#123117',
    fontSize: 16,
  },
  primary: {
    borderWidth: 4,
    borderColor: '#50AB5E',
    borderRadius: 18,
  },
  white: { backgroundColor: '#fff' },
});
