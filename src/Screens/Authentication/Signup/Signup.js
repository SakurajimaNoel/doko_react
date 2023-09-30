import { View, Text, StyleSheet, TextInput, Button } from "react-native";
import React from "react";
import { Formik } from "formik";

import { SignupSchema } from "../../../ValidationSchema/Auth/SignupSchema";

import UserPool from "../../../users/UserPool";


export default function Signup() {
	const handleSignup = (values) => {
		let email = values.email;
		let name = values.name;
		let password = values.password;


		// handle signup logic
		//parameters: username, password, attributes = email(necessary), validatindata? keep null, callbacks
		
		UserPool.signUp(name, password, [{Name: "email", Value: email}], null, (err, data) =>{
			if(err){
				console.error("cognito error: ", err);
			}
			console.log("cognito data: ", data);
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
								disabled={!isValid}
								onPress={handleSubmit}
								title="Signup"
								accessibilityLabel="Signup based on submitted credentials"
							/>
						</>
					)}
				</Formik>
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
		flex: 1,
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
});
