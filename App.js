/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 */

import React, {useState} from 'react';
import {
  Text,
  View,
  SafeAreaView,
  TextInput,
  StyleSheet,
  Button,
} from 'react-native';

function App() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  const handleLogin = () => {
    console.log(email);
    console.log(password);
  };

  return (
    <SafeAreaView>
      <View style={styles.container}>
        <TextInput
          style={styles.input}
          placeholder="Email"
          onChangeText={email => setEmail(email)}
          value={email}
        />

        <TextInput
          style={styles.input}
          placeholder="password"
          onChangeText={password => setPassword(password)}
          value={password}
          secureTextEntry={true}
        />

        <Button style={styles.button} title={'login'} onPress={handleLogin} />
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    height: '100%',
    width: '100%',
    backgroundColor: 'lightpink',
  },
  input: {
    width: '75%',
    borderWidth: 2,
    borderColor: 'white',
    color: 'black',
    fontSize: 24,
    fontWeight: '500',
    marginVertical: 20,
  },
  button: {
    backgroundColor: 'red',
  },
});

export default App;
