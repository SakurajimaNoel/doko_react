import {
	View,
	Text,
	Button,
	StyleSheet,
	TextInput,
	Pressable,
} from "react-native";

import { Auth, Hub } from "aws-amplify";
import { useState } from "react";

// recoil state manangement
import { useSetRecoilState } from "recoil";
import { userState } from "../../recoil/atoms/user";

// encrypted storage
import EncryptedStorage from "react-native-encrypted-storage";

function Login({ navigation }) {
	const [userCredentials, setUserCredentials] = useState({
		email: "vermarohan031@gmail.com",
		password: "6s4UPYN6@P]W8[p8",
	});

	const setUser = useSetRecoilState(userState);

	const handleInput = (type, value) => {
		setUserCredentials(prev => {
			return { ...prev, [type]: value };
		});
	};

	// handle login using aws
	const handleLogin = async () => {
		console.log(userCredentials);
		try {
			const user = await Auth.signIn(
				userCredentials.email,
				userCredentials.password,
			);

			let userObj = {
				id: user.pool.clientId,
				email: user.attributes.email,
				name: user.attributes.name,
			};

			setUser(userObj);

			try {
				await EncryptedStorage.setItem(
					"userCredentials",
					JSON.stringify(userObj),
				);
				console.log("Saved data in encrypted storage");
			} catch (error) {
				console.log("Error saving user info, ", error);
			}
		} catch (error) {
			console.log("error signing in: ", error);
		}
	};

	const goToSignUp = () => {
		navigation.navigate("Signup");
	};

	const handleHome = () => {
		navigation.popToTop();
	};

	return (
		<View style={styles.container}>
			<View style={styles.inputContainer}>
				<TextInput
					placeholder="Email..."
					placeholderTextColor="#7F8487"
					style={styles.input}
					value={userCredentials.email}
					onChangeText={email => handleInput("email", email)}
				/>
			</View>

			<View style={styles.inputContainer}>
				<TextInput
					secureTextEntry={true}
					placeholder="Password..."
					placeholderTextColor="#7F8487"
					style={styles.input}
					value={userCredentials.password}
					onChangeText={password => handleInput("password", password)}
				/>
			</View>

			<Button
				style={{ borderRadius: 1 }}
				title="Login"
				onPress={handleLogin}
			/>

			<Pressable onPress={goToSignUp}>
				<Text style={styles.link}>Go to sign up..</Text>
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
		backgroundColor: "#010101",
	},
	inputContainer: {
		backgroundColor: "white",
	},
	input: {
		marginLeft: 8,
		fontSize: 20,
		color: "black",
		fontWeight: "500",
	},
	link: { color: "lightpink" },
});

export default Login;
