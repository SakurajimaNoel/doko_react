import { View, Text, StyleSheet } from "react-native";
import React from "react";
import { HomeProps } from "./types";
import { Button } from "@rneui/themed";
import { useAppDispatch, useAppSelector } from "../../../hooks/reduxHooks";
import { logoutUser, updateTokens } from "../../../redux/slices/authSlice";
import * as Keychain from "react-native-keychain";
import * as AWS from "aws-sdk";
import { getAWSCredentials } from "../../../Connectors/auth/aws";
import { getCognitoUser } from "../../../Connectors/auth/cognitoUser";
import { CognitoRefreshToken } from "amazon-cognito-identity-js";
import { userTokens, needsRefresh } from "../../../Connectors/auth/auth";

const Home = ({ navigation }: HomeProps) => {
	const dispatch = useAppDispatch();
	const user = useAppSelector((state) => state.auth);

	const handleLogout = async () => {
		await Keychain.resetGenericPassword();
		dispatch(logoutUser());
	};

	const handleTrial = () => {
		const credentials = getAWSCredentials();

		credentials?.get((error) => {
			if (error) {
				console.error("Error fetching AWS credentials: ", error);
			} else {
				var accessKeyId = credentials.accessKeyId;
				var secretAccessKey = credentials.secretAccessKey;
				var sessionToken = credentials.sessionToken;

				// console.log(accessKeyId);
				// console.log(secretAccessKey);
				// console.log(sessionToken);
			}
		});

		if (needsRefresh(user.expireAt)) {
			console.log("refresh tokens here");
		} else {
			console.log("no need to refresh now");
		}
		return;

		const updateAttributes = [
			{
				Name: "preferred_username",
				Value: user.awsUsername,
				// Value: "rohan",
			},
		];
		const cognitoUser = getCognitoUser();

		cognitoUser?.updateAttributes(updateAttributes, (err, result) => {
			if (err) {
				console.log("Error updating user attributes ", err);
			} else {
				console.log("Successfully updated user attributes ", result);
			}
		});

		// refreshing token
		const refreshDetails = new CognitoRefreshToken({
			RefreshToken: user.refreshToken,
		});

		cognitoUser?.refreshSession(refreshDetails, async (error, result) => {
			if (error) {
				console.log(error);
			} else {
				let userDetails = userTokens(result);

				dispatch(updateTokens(userDetails));
			}
		});
	};

	return (
		<View>
			<Text style={styles.text}>{`Hii ${user.name}`}</Text>

			{!user.completeProfile && (
				<Text style={styles.text}>Incomplete profile</Text>
			)}

			<Button
				onPress={handleLogout}
				title="Logout"
				accessibilityLabel="Logout"
				type="clear"
			/>
			<Button
				onPress={handleTrial}
				title="trial"
				accessibilityLabel="Logout"
				// type="clear"
			/>
		</View>
	);
};

const styles = StyleSheet.create({
	text: {
		color: "black",
	},
});

export default Home;
