import {View, Text, Button} from 'react-native';

function Signup({navigation}) {
  return (
    <View
      style={{
        flex: 1,
        alignItems: 'center',
        justifyContent: 'space-between',
        backgroundColor: '#010101',
      }}>
      <Text>SignUp Page!!</Text>

      <Button title="Go back to home" onPress={() => navigation.popToTop()} />

      <Button title="Go Back" onPress={() => navigation.goBack()} />

      <Button title="Login" onPress={() => navigation.navigate('Login')} />

      <Button title="Profile" onPress={() => navigation.navigate('Profile')} />
    </View>
  );
}

export default Signup;
