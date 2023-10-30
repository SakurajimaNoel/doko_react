import { View, Text, StyleSheet, ActivityIndicator } from "react-native";
import { Button } from "@rneui/themed";
import React, { useState, useEffect } from "react";
import * as Keychain from "react-native-keychain";
import { CognitoRefreshToken } from "amazon-cognito-identity-js";

import {
	initCognitoUser,
	getCognitoUser,
} from "../../Connectors/auth/cognitoUser";

import { userTokenDetails } from "../../Connectors/auth/auth";
import { loginUser } from "../../redux/slices/authSlice";
import { useAppDispatch } from "../../hooks/reduxHooks";

import { gql, useQuery } from "@apollo/client";

import NetworkLogger from "react-native-network-logger";
import { IntroProps } from "./types";

export default function Intro({ navigation }: IntroProps) {
	const dispatch = useAppDispatch();
	const [loading, setLoading] = useState(true);

	const handleTokenRefresh = (credentials: Keychain.UserCredentials) => {
		let { username, password: refreshToken } = credentials;

		initCognitoUser(username);
		const user = getCognitoUser();

		const refreshDetails = new CognitoRefreshToken({
			RefreshToken: refreshToken,
		});

		user?.refreshSession(refreshDetails, async (error, result) => {
			if (error) {
				console.log(error);
			} else {
				let userDetails = userTokenDetails(result);

				await Keychain.setGenericPassword(
					userDetails.email,
					userDetails.refreshToken,
				);
				setLoading(false);
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
					// console.log("No credentials stored");
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
