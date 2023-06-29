import {
	View,
	Text,
	Button,
	StyleSheet,
	TextInput,
	Pressable,
} from "react-native";

import { Auth } from "aws-amplify";
import { login } from "../../backend connectors/auth/auth";
import { useState, useEffect } from "react";

// recoil state manangement
import { useSetRecoilState } from "recoil";
import { userState } from "../../recoil/atoms/user";


function Login({ navigation }) {
	const [userCredentials, setUserCredentials] = useState({
		email: "vermarohan031@gmail.com",
		password: "6s4UPYN6@P]W8[p8",
	});

	const setUser = useSetRecoilState(userState);

	useEffect(() => {
		Auth.currentAuthenticatedUser({ bypassCache: true })
			.then((user) => {
				setUser({
					id: user.pool.clientId,
					email: user.attributes.email,
					name: user.attributes.name,
					isAuth: true,
				});

				navigation.navigate("Home");
			})
			.catch((err) => {
				console.log(err);
			});
	}, []);

	const handleInput = (type, value) => {
		setUserCredentials((prev) => {
			return { ...prev, [type]: value };
		});
	};

	// handle login using aws
	const handleLogin = async () => {
		try {
			const user = await login(
				userCredentials.email,
				userCredentials.password,
			);

			setUser({
				id: user.pool.clientId,
				email: user.attributes.email,
				name: user.attributes.name,
				isAuth: true,
			});

			navigation.navigate("Home");
		} catch (error) {
			console.log("error signing in: ", error);
			let err = error.toString();
			err = err.split(":");

			if (err[0] === "UserNotConfirmedException")
				navigation.navigate("ConfirmSignup", {
					email: userCredentials.email,
				});
		}
	};

	const goToSignUp = () => {
		navigation.navigate("Signup");
	};


	return (
		<View style={styles.container}>
			<View style={styles.inputContainer}>
				<TextInput
					placeholder="Email..."
					placeholderTextColor="#7F8487"
					style={styles.input}
					value={userCredentials.email}
					onChangeText={(email) => handleInput("email", email)}
				/>
			</View>

			<View style={styles.inputContainer}>
				<TextInput
					secureTextEntry={true}
					placeholder="Password..."
					placeholderTextColor="#7F8487"
					style={styles.input}
					value={userCredentials.password}
					onChangeText={(password) =>
						handleInput("password", password)
					}
				/>
			</View>

			<Button
				style={{ borderRadius: 1 }}
				title="Login"
				onPress={handleLogin}
				//onPress={queryTest}
			/>

			<Pressable onPress={goToSignUp}>
				<Text style={styles.link}>Go to sign up..</Text>
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
