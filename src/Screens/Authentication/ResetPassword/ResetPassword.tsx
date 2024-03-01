import { View, Text, StyleSheet, TextInput } from "react-native";
import React, { useState } from "react";

import {
	initCognitoUser,
	getCognitoUser,
} from "../../../Connectors/auth/cognitoUser";

import SendCode from "./components/SendCode";
import ChangePassword from "./components/ChangePassword";

import {
	ResetPasswordProps,
	HandleConfirmPasswordParams,
	HandleForgotPasswordParams,
} from "./types";

export default function ResetPassword({ navigation }: ResetPasswordProps) {
	const [isConfirmPassword, setIsConfirmPassword] = useState(false);
	const [isLoading, setIsLoading] = useState(false);
	const [message, setMessage] = useState("");

	const handleForgotPassword = (values: HandleForgotPasswordParams) => {
		let email = values.email;
		setIsLoading(true);

		// handle sending reset code
		initCognitoUser(email);
		const user = getCognitoUser();

		user?.forgotPassword({
			onSuccess: (result) => {
				console.log(result);
				setIsLoading(false);
				setIsConfirmPassword(true);
				setMessage("Code sent successfully");
			},
			onFailure: (err) => {
				console.error(err);
				setIsLoading(false);
				setMessage("Error sending code");
			},
		});
	};

	const handleConfirmForgotPassword = (
		values: HandleConfirmPasswordParams,
	) => {
		let verificationCode = values.resetCode;
		let newPassword = values.password;
		setIsLoading(true);

		// handle changing password
		const user = getCognitoUser();

		user?.confirmPassword(verificationCode, newPassword, {
			onSuccess: (data) => {
				setIsLoading(false);
				console.log(data);
				setMessage("Successfully changed password");
			},
			onFailure: (err) => {
				setIsLoading(false);
				console.error(err);
				setMessage("Error changing password");
			},
		});
	};

	return (
		<View style={styles.container}>
			<View style={styles.headContainer}>
				<Text style={styles.head}>Reset Password</Text>
			</View>

			<View style={styles.formContainer}>
				{!isConfirmPassword ? (
					<SendCode
						handleForgotPassword={handleForgotPassword}
						isLoading={isLoading}
					/>
				) : (
					<ChangePassword
						handleConfirmForgotPassword={
							handleConfirmForgotPassword
						}
						isLoading={isLoading}
					/>
				)}
			</View>

			<View style={styles.messageContainer}>
				<Text style={styles.messageText}>{message}</Text>
			</View>
		</View>
	);
}

const styles = StyleSheet.create({
	container: {
		margin: 10,
		flex: 1,
	},
	headContainer: {
		paddingTop: 10,
		marginBottom: 20,
	},
	head: {
		color: "black",
		fontSize: 24,
		textAlign: "center",
		fontWeight: "500",
	},
	formContainer: {
		gap: 20,
		padding: 12,
	},
	messageContainer: {
		padding: 12,
	},
	messageText: {
		color: "black",
		fontWeight: "500",
	},
});
