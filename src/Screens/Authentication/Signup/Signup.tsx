import { View, Text, StyleSheet, TextInput } from "react-native";
import { Button } from "@rneui/themed";
import React, { useState } from "react";
import { Formik } from "formik";

import { SignupSchema } from "../../../ValidationSchema/Auth/SignupSchema";

// import * as AWS from "aws-sdk";
import { HandleSignupParams, SignupProps } from "./types";
import "react-native-get-random-values";
import { nanoid } from "nanoid";
import UserPool from "../../../users/UserPool";
import { CognitoUserAttribute } from "amazon-cognito-identity-js";

export default function Signup({ navigation }: SignupProps) {
	const [isLoading, setIsLoading] = useState(false);
	const [message, setMessage] = useState("");

	const handleSignup = (userDetails: HandleSignupParams) => {
		setIsLoading(true);
		const { name, email, password } = userDetails;
		// const userId = nanoid().toLowerCase();

		// const userAttributes = [
		// 	{
		// 		Name: "email",
		// 		Value: email,
		// 	},
		// 	{
		// 		Name: "name",
		// 		Value: name,
		// 	},
		// 	{
		// 		Name: "preferred_username",
		// 		Value: userId,
		// 	},
		// ];

		const userAttributes = [
			// new CognitoUserAttribute({
			// 	Name: "email",
			// 	Value: email,
			// }),
			new CognitoUserAttribute({
				Name: "name",
				Value: name,
			}),
		];

		// handle signup logic

		// parameters: username, password, attributes = email(necessary), validatindata? keep null, callbacks
		UserPool.signUp(email, password, userAttributes, null, (err, data) => {
			setIsLoading(false);
			if (err) {
				console.error("cognito error: ", err);
				setMessage(err.message);
				return;
			}
			console.log("cognito data: ", data);
			setMessage(
				"Successfully created account. Check mail to verify account",
			);
		});
	};

	return (
		<View style={styles.container}>
			<View style={styles.headContainer}>
				<Text style={styles.head}>Signup</Text>
			</View>

			<View style={styles.formContainer}>
				<Formik
					validateOnMount={true}
					initialValues={{
						email: "",
						name: "",
						password: "",
						confirmPassword: "",
					}}
					validationSchema={SignupSchema}
					onSubmit={(values) => handleSignup(values)}>
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
									onEndEditing={handleBlur("email")}
								/>
								{touched.email && errors.email && (
									<Text style={styles.errorText}>
										{errors.email}
									</Text>
								)}
							</View>

							<View style={styles.inputContainer}>
								<TextInput
									style={styles.inputStyle}
									value={values.name}
									placeholder="Name..."
									placeholderTextColor="#7F8487"
									onChangeText={handleChange("name")}
									onEndEditing={handleBlur("name")}
								/>
								{touched.name && errors.name && (
									<Text style={styles.errorText}>
										{errors.name}
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
									onEndEditing={handleBlur("password")}
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
								title="Signup"
								loading={isLoading}
								accessibilityLabel="Signup based on submitted credentials"
							/>
						</>
					)}
				</Formik>
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
