import { View, Text, StyleSheet, ActivityIndicator } from "react-native";
import { Button } from "@rneui/themed";
import React, { useState, useEffect } from "react";
import * as Keychain from "react-native-keychain";
import { CognitoUser, CognitoRefreshToken } from "amazon-cognito-identity-js";
import * as AWS from "aws-sdk";
import UserPool from "../../users/UserPool";

import { userTokenDetails } from "../../Connectors/auth/auth";
import { iamAccess } from "../../Connectors/auth/aws";
import { loginUser } from "../../redux/slices/authSlice";
import { useAppDispatch } from "../../hooks/reduxHooks";

import { gql, useQuery } from "@apollo/client";

import NetworkLogger from "react-native-network-logger";
import { IntroProps } from "./types";

export default function Intro({ navigation }: IntroProps) {
	const dispatch = useAppDispatch();
	const [loading, setLoading] = useState(true);

	const handleTokenRefresh = (credentials: Keychain.UserCredentials) => {
		let { username: email, password: refreshToken } = credentials;
		console.log(email);
		console.log(refreshToken);

		const user = new CognitoUser({
			Username: email,
			Pool: UserPool,
		});

		const refreshDetails = new CognitoRefreshToken({
			RefreshToken: refreshToken,
		});

		user.refreshSession(refreshDetails, async (error, result) => {
			setLoading(false);
			if (error) {
				console.log(error);
			} else {
				let userDetails = userTokenDetails(result);
				// for iam access
				// const credentials = iamAccess(userDetails.idToken.token);

				// credentials.get((error) => {
				// 	if (error) {
				// 		console.error(
				// 			"Error fetching AWS credentials: ",
				// 			error,
				// 		);
				// 	} else {
				// 		// Initialize AWS service with the obtained credentials
				// 		const s3 = new AWS.S3();

				// 		// Example: List S3 buckets
				// 		s3.listBuckets((err, data) => {
				// 			if (err) {
				// 				console.error(
				// 					"Error listing S3 buckets: ",
				// 					err,
				// 				);
				// 			} else {
				// 				console.log("S3 buckets: ", data.Buckets);
				// 			}
				// 		});

				// 		// You can use other AWS services similarly with the obtained credentials
				// 	}
				// });

				await Keychain.setGenericPassword(
					userDetails.email,
					userDetails.refreshToken,
				);
				dispatch(loginUser(userDetails));
			}
		});
	};

	useEffect(() => {
		async function fetchRefreshToken() {
			try {
				// Retrieve the credentials
				const credentials = await Keychain.getGenericPassword();

				if (credentials) {
					handleTokenRefresh(credentials);
				} else {
					console.log("No credentials stored");
					setLoading(false);
				}
			} catch (error) {
				console.log("Keychain couldn't be accessed!", error);
				setLoading(false);
			}
		}

		fetchRefreshToken();
	}, []);

	const handleAuthNavigation = (toLogin = true) => {
		if (toLogin) {
			// navigate to login screen
			navigation.navigate("Login");
		} else {
			// navigate to signup screen
			navigation.navigate("Signup");
		}
	};

	return (
		<>
			{loading ? (
				<View style={styles.loadingContainer}>
					<ActivityIndicator size="large" />
				</View>
			) : (
				<View style={styles.container}>
					<View style={styles.headContainer}>
						<Text style={styles.head}>Hii welcome to dokii</Text>
					</View>

					<View style={styles.buttonContainer}>
						<Button
							onPress={() => handleAuthNavigation()}
							title="Login"
							accessibilityLabel="To navigate to login screen"
						/>

						<Button
							onPress={() => handleAuthNavigation(false)}
							title="Signup"
							accessibilityLabel="To navigate to Signup screen"
						/>
					</View>
				</View>
			)}
			{/* //<NetworkLogger /> //no delete */}
		</>
	);
}

const styles = StyleSheet.create({
	loadingContainer: {
		paddingVertical: "50%",
	},
	container: {
		margin: 10,
		flex: 1,
	},
	headContainer: {
		flex: 1,
		paddingTop: 10,
	},
	buttonContainer: {
		flex: 3,
		gap: 15,
	},
	head: {
		color: "black",
		fontSize: 24,
		textAlign: "center",
		fontWeight: "500",
	},
});
