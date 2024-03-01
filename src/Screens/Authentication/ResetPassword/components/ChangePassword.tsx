import { View, Text, StyleSheet, TextInput } from "react-native";
import React from "react";
import { ConfirmResetPasswordSchema } from "../../../../ValidationSchema/Auth/ResetPasswordSchema";
import { Formik } from "formik";
import { Button } from "@rneui/themed";
import { ChangePasswordProps } from "../types";

const ChangePassword = ({
	handleConfirmForgotPassword,
	isLoading,
}: ChangePasswordProps) => {
	return (
		<Formik
			validateOnMount={true}
			initialValues={{
				resetCode: "",
				password: "",
				confirmPassword: "",
			}}
			validationSchema={ConfirmResetPasswordSchema}
			onSubmit={(values) => handleConfirmForgotPassword(values)}>
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
							onChangeText={handleChange("confirmPassword")}
							onBlur={handleBlur("confirmPassword")}
						/>
						{touched.confirmPassword && errors.confirmPassword && (
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
	);
};

const styles = StyleSheet.create({
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
});

export default ChangePassword;
