import { View, Text, StyleSheet, TextInput } from "react-native";
import { Button } from "@rneui/themed";
import React, { useState } from "react";
import { Formik } from "formik";

import { LoginSchema } from "../../../ValidationSchema/Auth/LoginSchema";
import { HandleLoginParams, LoginProps } from "./types";
import {
	CognitoUser,
	AuthenticationDetails,
	CognitoUserSession,
} from "amazon-cognito-identity-js";
import * as AWS from "aws-sdk";
import UserPool from "../../../users/UserPool";

AWS.config.region = "ap-south-1";

import { loginUser } from "../../../redux/slices/authSlice";
import { useAppDispatch } from "../../../hooks/reduxHooks";
import { useAppSelector } from "../../../hooks/reduxHooks";

export default function Login({ navigation }: LoginProps) {
	const dispatch = useAppDispatch();
	const auth = useAppSelector((state) => state.auth);

	const [isLoading, setIsLoading] = useState(false);
	const [message, setMessage] = useState("");

	const handleAuthSuccess = (payload: CognitoUserSession) => {
		let decodedAccess = payload.getAccessToken().decodePayload();
		let decodedId = payload.getIdToken().decodePayload();

		// accesstoken
		let accessToken = {
			token: payload.getAccessToken().getJwtToken(),
			expTime: payload.getAccessToken().getExpiration(),
			issuedAt: payload.getAccessToken().getIssuedAt(),
		};
		console.log(accessToken.token);

		// idToken
		let idToken = {
			token: payload.getIdToken().getJwtToken(),
			expTime: payload.getIdToken().getExpiration(),
			issuedAt: payload.getIdToken().getIssuedAt(),
		};

		let refreshToken = payload.getRefreshToken().getToken();
		let name = decodedId.name ? decodedId.name : "dokiii";
		let username = decodedId.preferred_username;
		let email = decodedId.email;
		let awsUsername = decodedAccess.username;
		let completeProfile = awsUsername !== username;

		let userDetails = {
			accessToken,
			idToken,
			refreshToken,
			name,
			username,
			email,
			completeProfile,
			awsUsername,
		};

		dispatch(loginUser(userDetails));
	};

	const handleLogin = (userCredentials: HandleLoginParams) => {
		setIsLoading(true);

		// handle login logic
		const { email, password } = userCredentials;

		const user = new CognitoUser({
			Username: email,
			Pool: UserPool,
		});

		const authDetails = new AuthenticationDetails({
			Username: email,
			Password: password,
		});

		user.authenticateUser(authDetails, {
			onSuccess: (result) => {
				setMessage("Successfully authenticated");
				setIsLoading(false);
				console.log("Cognito Signin Success");
				handleAuthSuccess(result);
				// var jwtToken = result.getAccessToken().getJwtToken();
				// console.log("JWT Token: " + jwtToken); // get bearer token here
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
