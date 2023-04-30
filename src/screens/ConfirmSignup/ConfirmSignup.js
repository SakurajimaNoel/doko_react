import { useState } from "react";
import {
	View,
	Text,
	Button,
	StyleSheet,
	TextInput,
	Pressable,
} from "react-native";

import { Auth } from "aws-amplify";
import { Hub } from "aws-amplify";

function ConfirmSignup({ route, navigation }) {
	const { email, password } = route.params;

	const [confirmCode, setConfirmCode] = useState();

	const handleInput = value => {
		setConfirmCode(value);
	};

	const goToSignUp = () => {
		navigation.navigate("Signup");
	};

	const handleHome = () => {
		navigation.popToTop();
	};

	async function signIn() {
		try {
			const user = await Auth.signIn(email, password);

			navigation.navigate("CreateProfile");
		} catch (error) {
			console.log("error signing in", error);
		}
	}

	async function confirmSignUp() {
		try {
			await Auth.confirmSignUp(email, confirmCode);
			await signIn();
		} catch (error) {
			console.log("error confirming sign up", error);
		}
	}

	return (
		<View style={styles.container}>
			<View style={styles.inputContainer}>
				<TextInput
					placeholder="Confirmation Code..."
					placeholderTextColor="#7F8487"
					style={styles.input}
					value={confirmCode}
					onChangeText={code => handleInput(code)}
				/>
			</View>

			<Button
				style={{ borderRadius: 1 }}
				title="Confirm Code"
				onPress={confirmSignUp}
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

export default ConfirmSignup;
