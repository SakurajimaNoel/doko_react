import { View, Text, StyleSheet, TextInput } from "react-native";
import { Button } from "@rneui/themed";
import React, { useState } from "react";
import { Formik } from "formik";

import { userTokenDetails } from "../../../Connectors/auth/auth";
import {
	initCognitoUser,
	getCognitoUser,
} from "../../../Connectors/auth/cognitoUser";
import {
	initAWSCredentials,
	getAWSCredentials,
} from "../../../Connectors/auth/aws";

import { LoginSchema } from "../../../ValidationSchema/Auth/LoginSchema";
import { HandleLoginParams, LoginProps } from "./types";
import {
	AuthenticationDetails,
	CognitoUserSession,
} from "amazon-cognito-identity-js";
import * as AWS from "aws-sdk";

import { loginUser } from "../../../redux/slices/authSlice";
import { useAppDispatch } from "../../../hooks/reduxHooks";

export default function Login({ navigation }: LoginProps) {
	const dispatch = useAppDispatch();

	const [isLoading, setIsLoading] = useState(false);
	const [message, setMessage] = useState("");

	const handleAuthSuccess = async (payload: CognitoUserSession) => {
		let userDetails = userTokenDetails(payload);

		// cognito iam
		// initAWSCredentials(userDetails.idToken);
		// const credentials = getAWSCredentials();
		// AWS.config.credentials = credentials;

		dispatch(loginUser(userDetails));
	};

	const handleLogin = (userCredentials: HandleLoginParams) => {
		setIsLoading(true);

		// handle login logic
		const { email, password } = userCredentials;

		initCognitoUser(email);
		const user = getCognitoUser();

		const authDetails = new AuthenticationDetails({
			Username: email,
			Password: password,
		});

		user?.authenticateUser(authDetails, {
			onSuccess: (result) => {
				setMessage("Successfully authenticated");
				setIsLoading(false);
				console.log("Cognito Signin Success");
				handleAuthSuccess(result);
			},
			onFailure: (err) => {
				setIsLoading(false);
				console.log("Cognito Signin Failure: ", err);
				setMessage(err.message);
			},
			newPasswordRequired: (userAttributes, requiredAttributes) => {
				userAttributes: authDetails;
				requiredAttributes: email;
				let newPassword = password;
				user.completeNewPasswordChallenge(
					newPassword,
					userAttributes,
					this,
				);
			},
		});
	};

	return (
		<View style={styles.container}>
			<View style={styles.headContainer}>
				<Text style={styles.head}>Login</Text>
			</View>

			<View style={styles.formContainer}>
				<Formik
					validateOnMount={true}
					initialValues={{
						email: "rohanverma031@gmail.com",
						password: "R1o2h3a4n5:%%",
					}}
					validationSchema={LoginSchema}
					onSubmit={(values) => handleLogin(values)}>
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

							<Button
								disabled={isLoading || !isValid}
								onPress={handleSubmit}
								title="Login"
								loading={isLoading}
								accessibilityLabel="Login based on submitted credentials"
							/>
						</>
					)}
				</Formik>
				<View>
					<Button
						onPress={() => navigation.navigate("ResetPassword")}
						title="Forgot Password?"
						type="clear"
					/>
				</View>
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
		fontWeight: "500",
	},
});
