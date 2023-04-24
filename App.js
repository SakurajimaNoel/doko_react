/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 */

/**
 * To Do:
  1. Create UI for sign in, sign up and set up the navigational flow.
  2. For sign up we need following params: 
      name
      preferred_username
      email
      PS: Username field mai bhi email pass kar do idk but mangta hai wo, preferred username mai pass the username that will be dispalyed to other users, eg. saki_nobashi_kun.
  3. Password params:
      Contains at least 1 number
      Contains at least 1 special character
      Contains at least 1 uppercase letter
      Contains at least 1 lowercase letter
      min length = 8 characters.
      PS: Sign up ka catch block will return error with what's missing but still bandwidth bachao and sanitize input from client side.
    
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

import {Auth, AWSCloudWatchProvider, Hub} from 'aws-amplify';

//*************************appsync library************************************//
import {API} from 'aws-amplify';
import * as mutations from './src/graphql/mutations';
import * as queries from './src/graphql/queries';
//***************************************************************************//

import {NavigationContainer} from '@react-navigation/native';
import {createNativeStackNavigator} from '@react-navigation/native-stack';

// our navigation components
import Home from './src/screens/Home';
import Login from './src/screens/Login';
import Signup from './src/screens/Signup';
import Profile from './src/screens/Profile';

const Stack = createNativeStackNavigator();

function App() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  //temp vars for testing integration, replace with actual fields.
  var username = email;
  var name = 'testName';
  var preferred_username = 'testPrefUsername';

  const handleLogin = () => {
    console.log(email);
    console.log(password);
  };

  async function signUp() {
    try {
      const {user} = await Auth.signUp({
        username,
        password,
        attributes: {
          email,
          name,
          preferred_username,
        },
        autoSignIn: {
          enabled: true,
        },
      });
      console.log(user);
    } catch (error) {
      console.log('sign up error: ', error);
    }
  }

  function listenToAutoSignInEvent() {
    //called automatically if sign up successful to sign in the user.
    Hub.listen('auth', ({payload}) => {
      const {event} = payload;
      if (event === 'autoSignIn') {
        const user = payload.data;
      } else if (event === 'autoSignIn_failure') {
        //sign in page open crow.
      }
    });
  }

  async function signIn() {
    try {
      const user = await Auth.signIn(email, password);
    } catch (error) {
      console.log('error signing in: ', error);
    }
  }

  async function signOut() {
    try {
      await Auth.signOut();
    } catch (error) {
      console.log('error signing out: ', error);
    }
  }

  async function globalSignOut() {
    // sign out from all devices
    try {
      await Auth.signOut({global: true});
    } catch (error) {
      console.log('error signing out: ', error);
    }
  }

  async function createProfile() {
    try {
      await API.graphql({
        query: mutations.createProfile,
        variables: {input: profileDetails},
      });
    } catch (error) {
      console.log('appsync error: failed to create user profile');
    }
  }

  async function createFriendship() {
    try {
      await API.graphql({
        query: mutations.createFriendship,
        variables: {input: friendshipDetails},
      });
    } catch (error) {
      console.log('appsync error: failed to create friendship');
    }
  }

  async function getProfile() {
    try {
      const fetchedProfile = await API.graphql({
        query: queries.getProfile,
        variables: {id: 'user_Id_jo_hoga'},
      });
    } catch (error) {
      console.log('appsync error: failed to fetch profile');
    }
  }

  return (
    <NavigationContainer>
      {/* will shift this code elsewhere only navigation related code should be herer */}
      {/* <SafeAreaView>
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

          <Button style={styles.button} title={'login'} onPress={signUp} />
        </View>
      </SafeAreaView> */}

      <Stack.Navigator initialRouteName="Home">
        <Stack.Screen name="Home" component={Home} />

        <Stack.Screen name="Login" component={Login} />

        <Stack.Screen name="Profile" component={Profile} />

        <Stack.Screen name="Signup" component={Signup} />
      </Stack.Navigator>
    </NavigationContainer>
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
