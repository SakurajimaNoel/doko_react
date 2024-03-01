import { View, Text, StyleSheet, TextInput } from "react-native";
import React from "react";
import { ResetPasswordSchema } from "../../../../ValidationSchema/Auth/ResetPasswordSchema";
import { Formik } from "formik";
import { Button } from "@rneui/themed";
import { SendCodeProps } from "../types";

const SendCode = ({ handleForgotPassword, isLoading }: SendCodeProps) => {
	return (
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
							<Text style={styles.errorText}>{errors.email}</Text>
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

export default SendCode;
