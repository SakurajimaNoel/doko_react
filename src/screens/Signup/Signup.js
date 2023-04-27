import {
  View,
  Text,
  Button,
  StyleSheet,
  TextInput,
  Pressable,
} from 'react-native';

import {Auth, Hub} from 'aws-amplify';
import {useState} from 'react';

// aws
import {API} from 'aws-amplify';
import * as mutations from '../../graphql/mutations';
import * as queries from '../../graphql/queries';
//

const userDetails = {
  id: '1212',
  name: 'Abc',
  username: 'abc',
  email: 'abc@gmail.com',
  dob: '2001-05-23',
};

function Signup({navigation}) {
  const [userInfo, setUserInfo] = useState({
    name: 'rohan',
    email: 'vermarohan031@gmail.com',
    password: '6s4UPYN6@P]W8[p8',
    confirmPassword: '6s4UPYN6@P]W8[p8',
  });

  const handleInput = (type, value) => {
    setUserInfo(prev => {
      return {...prev, [type]: value};
    });
  };

  // create profile
  async function createProfile() {
    try {
      await API.graphql({
        query: mutations.createProfile,
        variables: {
          input: userDetails,
        },
      });
    } catch (error) {
      console.log('appsync error: failed to create user profile');
      console.log(error);
    }
  }

  async function getProfile() {
    try {
      const fetchedProfile = await API.graphql({
        query: queries.getProfile,
        variables: {id: '122'},
      });

      console.log(fetchedProfile.data.getProfile);
    } catch (error) {
      console.log('appsync error: failed to fetch profile');
      console.log(error);
    }
  }

  // handle sign up aws
  const handleSignup = async () => {
    console.log(userInfo);

    try {
      const {user} = await Auth.signUp({
        username: userInfo.email,
        password: userInfo.password,
        attributes: {
          email: userInfo.email,
          name: userInfo.name,
          preferred_username: userInfo.email,
        },
        autoSignIn: {
          enabled: true,
        },
      });
      console.log(user.pool.clientId);
    } catch (error) {
      console.log('sign up error: ', error);
    }
  };

  //auto sign in after sign up
  function listenToAutoSignInEvent() {
    //called automatically if sign up successful to sign in the user.
    Hub.listen('auth', ({payload}) => {
      const {event} = payload;
      if (event === 'autoSignIn') {
        const user = payload.data;
      } else if (event === 'autoSignIn_failure') {
        //sign in page open crow.
        navigation.navigate('Login');
      }
    });
  }

  const goToLogin = () => {
    navigation.navigate('Login');
  };

  const handleHome = () => {
    navigation.popToTop();
  };

  return (
    <View style={styles.container}>
      <View style={styles.inputContainer}>
        <TextInput
          placeholder="Name..."
          placeholderTextColor="#7F8487"
          style={styles.input}
          value={userInfo.name}
          onChangeText={name => handleInput('name', name)}
        />
      </View>

      <View style={styles.inputContainer}>
        <TextInput
          placeholder="Email..."
          placeholderTextColor="#7F8487"
          style={styles.input}
          value={userInfo.email}
          onChangeText={email => handleInput('email', email)}
        />
      </View>

      <View style={styles.inputContainer}>
        <TextInput
          secureTextEntry={true}
          placeholder="Password..."
          placeholderTextColor="#7F8487"
          style={styles.input}
          value={userInfo.password}
          onChangeText={password => handleInput('password', password)}
        />
      </View>

      <View style={styles.inputContainer}>
        <TextInput
          secureTextEntry={true}
          placeholder="Confirm Password..."
          placeholderTextColor="#7F8487"
          style={styles.input}
          value={userInfo.confirmPassword}
          onChangeText={confirmPassword =>
            handleInput('confirmPassword', confirmPassword)
          }
        />
      </View>

      <Button
        style={{borderRadius: 1}}
        title="Sign Up"
        // onPress={handleSignup}
        onPress={handleSignup}
      />

      <Pressable onPress={goToLogin}>
        <Text style={styles.link}>Go to login..</Text>
      </Pressable>

      <Pressable onPress={handleHome}>
        <Text style={styles.link}>Go to Home.</Text>
      </Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    gap: 30,
    paddingVertical: 30,
    paddingHorizontal: 30,
    backgroundColor: '#010101',
  },
  inputContainer: {
    backgroundColor: 'white',
  },
  input: {
    marginLeft: 8,
    fontSize: 20,
    color: 'black',
    fontWeight: '500',
  },
  link: {color: 'lightpink'},
});

export default Signup;
