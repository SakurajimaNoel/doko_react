import { View, Text, StyleSheet, TextInput } from "react-native";
import { Button } from "@rneui/themed";
import React, { useState } from "react";
import { Formik } from "formik";

import {
	ResetPasswordSchema,
	ConfirmResetPasswordSchema,
} from "../../../ValidationSchema/Auth/ResetPasswordSchema";
import { CognitoUser } from "amazon-cognito-identity-js";
import UserPool from "../../../users/UserPool";

export default function ResetPassword() {
	const [isConfirmPassword, setIsConfirmPassword] = useState(false);
	const [isLoading, setIsLoading] = useState(false);
	const [message, setMessage] = useState("");

	const handleForgotPassword = (values) => {
		let email = values.email;
		let name = "rohan";
		setIsLoading(true);

		// handle sending reset code
		const user = new CognitoUser({
			Username: name,
			Pool: UserPool,
		});

		user.forgotPassword({
			onSuccess: (result) => {
				console.log(result);
				setIsLoading(false);
				setIsConfirmPassword(true);
				setMessage("Code sent successfully");
			},
			onError: (err) => {
				console.log(err);
				setIsLoading(false);
				setMessage("Error sending code");
			},
		});
	};

	const handleConfirmForgotPassword = (values) => {
		let verificationCode = values.resetCode;
		let newPassword = values.password;
		let name = "rohan";
		setIsLoading(true);

		console.log(verificationCode);

		// handle changing password
		const user = new CognitoUser({
			Username: name,
			Pool: UserPool,
		});

		user.confirmPassword(verificationCode, newPassword, {
			onSuccess: (data) => {
				setIsLoading(false);
				console.log(data);
				setMessage("Successfully changed password");
			},
			onFailure: (err) => {
				setIsLoading(false);
				console.log(err);
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
					<Formik // for sending code
						validateOnMount={true}
						initialValues={{
							email: "",
						}}
						validationSchema={ResetPasswordSchema}
						onSubmit={(values) => handleForgotPassword(values)}>
						{({
							values,
							errors,
							isValid,
							touched,
							handleChange,
							handleBlur,
							handleSubmit,
						}) => (
							<>
								<View style={styles.inputContainer}>
									<TextInput
										style={styles.inputStyle}
										value={values.email}
										placeholder="Email..."
										placeholderTextColor="#7F8487"
										onChangeText={handleChange("email")}
										onBlur={handleBlur("email")}
									/>
									{touched.email && errors.email && (
										<Text style={styles.errorText}>
											{errors.email}
										</Text>
									)}
								</View>

								<Button
									disabled={isLoading || !isValid}
									onPress={handleSubmit}
									title="Send Reset Code"
									loading={isLoading}
									accessibilityLabel="Send password reset code to the valid given email"
								/>
							</>
						)}
					</Formik>
				) : (
					<Formik
						validateOnMount={true}
						initialValues={{
							resetCode: "",
							password: "",
							confirmPassword: "",
						}}
						validationSchema={ConfirmResetPasswordSchema}
						onSubmit={(values) =>
							handleConfirmForgotPassword(values)
						}>
						{({
							values,
							errors,
							isValid,
							touched,
							handleChange,
							handleBlur,
							handleSubmit,
						}) => (
							<>
								<View style={styles.inputContainer}>
									<TextInput
										style={styles.inputStyle}
										value={values.resetCode}
										placeholder="Reset Code..."
										placeholderTextColor="#7F8487"
										onChangeText={handleChange("resetCode")}
										onBlur={handleBlur("resetCode")}
										keyboardType="numeric"
									/>
									{touched.resetCode && errors.resetCode && (
										<Text style={styles.errorText}>
											{errors.resetCode}
										</Text>
									)}
								</View>

								<View style={styles.inputContainer}>
									<TextInput
										secureTextEntry={true}
										style={styles.inputStyle}
										value={values.password}
										placeholder="Password..."
										placeholderTextColor="#7F8487"
										onChangeText={handleChange("password")}
										onBlur={handleBlur("password")}
									/>
									{touched.password && errors.password && (
										<Text style={styles.errorText}>
											{errors.password}
										</Text>
									)}
								</View>

								<View style={styles.inputContainer}>
									<TextInput
										secureTextEntry={true}
										style={styles.inputStyle}
										value={values.confirmPassword}
										placeholder="Confirm Password..."
										placeholderTextColor="#7F8487"
										onChangeText={handleChange(
											"confirmPassword",
										)}
										onBlur={handleBlur("confirmPassword")}
									/>
									{touched.confirmPassword &&
										errors.confirmPassword && (
											<Text style={styles.errorText}>
												{errors.confirmPassword}
											</Text>
										)}
								</View>

								<Button
									disabled={isLoading || !isValid}
									onPress={handleSubmit}
									title="Reset Password"
									loading={isLoading}
									accessibilityLabel="Reset password based on submitted credentials"
								/>
							</>
						)}
					</Formik>
				)}
			</View>

			<View style={styles.message}>
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
		fontWeight: 500,
	},
	formContainer: {
		gap: 20,
		padding: 12,
	},
	inputStyle: {
		height: 40,
		borderWidth: 1,
		padding: 10,
		color: "#111",
		fontWeight: "500",
	},
	inputContainer: {
		marginBottom: 12,
	},
	errorText: {
		color: "red",
	},
	button: {
		margin: 10,
	},
	message: {
		padding: 12,
	},
	messageText: {
		color: "black",
		fontWeight: 500,
	},
});
