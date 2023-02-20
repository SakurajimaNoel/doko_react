import {View, Text, Button} from 'react-native';

function Home({navigation}) {
  return (
    <View
      style={{
        flex: 1,
        alignItems: 'center',
        justifyContent: 'space-between',
        backgroundColor: '#010101',
      }}>
      <Text>Welcome to Dokii!!</Text>

      <Button title="Login" onPress={() => navigation.navigate('Login')} />

      <Button title="Profile" onPress={() => navigation.navigate('Profile')} />

      <Button title="Signup" onPress={() => navigation.navigate('Signup')} />
    </View>
  );
}

export default Home;
