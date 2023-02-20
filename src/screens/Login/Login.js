import {View, Text, Button} from 'react-native';

function Login({navigation}) {
  return (
    <View
      style={{
        flex: 1,
        alignItems: 'center',
        justifyContent: 'space-between',
        backgroundColor: '#010101',
      }}>
      <Text>Login Page!!</Text>

      <Button title="Go back to home" onPress={() => navigation.popToTop()} />

      <Button title="Go Back" onPress={() => navigation.goBack()} />

      <Button title="Profile" onPress={() => navigation.navigate('Profile')} />

      <Button title="Signup" onPress={() => navigation.navigate('Signup')} />
    </View>
  );
}

export default Login;
