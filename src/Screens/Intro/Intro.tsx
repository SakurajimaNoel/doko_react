import { View, Text, StyleSheet, ActivityIndicator } from "react-native";
import { Button } from "@rneui/themed";
import React, { useState, useEffect } from "react";
import { CognitoUserSession } from "amazon-cognito-identity-js";
import * as AWS from "aws-sdk";
import UserPool from "../../users/UserPool";
import { initCognitoUser } from "../../Connectors/auth/cognitoUser";
import {
	initAWSCredentials,
	getAWSCredentials,
} from "../../Connectors/auth/aws";

import { userTokenDetails } from "../../Connectors/auth/auth";
import { loginUser } from "../../redux/slices/authSlice";
import { useAppDispatch } from "../../hooks/reduxHooks";

import { gql, useQuery } from "@apollo/client";

import NetworkLogger from "react-native-network-logger";
import { IntroProps, HandleUserSession } from "./types";

export default function Intro({ navigation }: IntroProps) {
	const dispatch = useAppDispatch();
	const [loading, setLoading] = useState(true);

	const handleUserSession: HandleUserSession = (session) => {
		let userDetails = userTokenDetails(session);
		initCognitoUser(userDetails.email);

		// cognito iam
		initAWSCredentials(userDetails.idToken);
		const credentials = getAWSCredentials();
		AWS.config.credentials = credentials;

		dispatch(loginUser(userDetails));
	};

	useEffect(() => {
		UserPool.storage.sync(function (err: Error, result: string) {
			if (err) {
			} else if (result === "SUCCESS") {
				var cognitoUser = UserPool.getCurrentUser();

				if (cognitoUser != null) {
					cognitoUser.getSession(function (
						err: Error | null,
						session: CognitoUserSession,
					) {
						if (err) {
							console.log("getSession Error ", err.message);
							setLoading(false);
							return;
						}

						if (session.isValid()) {
							handleUserSession(session);
							console.log(
								session.getAccessToken().getExpiration(),
							);
						}
						setLoading(false);
					});
				} else {
					setLoading(false);
				}
			}
		});
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
