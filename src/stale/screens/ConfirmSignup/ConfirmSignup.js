import { useState } from "react";
import { View, Text, StyleSheet, TextInput, Pressable } from "react-native";
import { Button } from "@ui-kitten/components";

import { Auth } from "aws-amplify";
import { Hub } from "aws-amplify";

function ConfirmSignup({ route, navigation }) {
	const { email } = route.params;

	const [confirmCode, setConfirmCode] = useState();

	const handleInput = (value) => {
		setConfirmCode(value);
	};

	async function resendConfirmationCode() {
		try {
			await Auth.resendSignUp(email);
			console.log("code resent successfully");
		} catch (err) {
			console.log("error resending code: ", err);
		}
	}

	async function confirmSignUp() {
		try {
			await Auth.confirmSignUp(email, confirmCode);
			navigation.navigate("CreateProfile");
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
					onChangeText={(code) => handleInput(code)}
				/>
			</View>

			<Button style={{ borderRadius: 1 }} onPress={confirmSignUp}>
				Confirm Code
			</Button>

			<Button onPress={resendConfirmationCode} appearance="ghost">
				Resend confirmation code
			</Button>
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
