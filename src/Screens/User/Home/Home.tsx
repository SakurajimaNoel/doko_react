import { View, Text, StyleSheet } from "react-native";
import React, { useContext, useEffect } from "react";
import { HomeProps } from "./types";
import { Button } from "@rneui/themed";
import { useAppDispatch, useAppSelector } from "../../../hooks/reduxHooks";
import { logoutUser, updateTokens } from "../../../redux/slices/authSlice";
import * as Keychain from "react-native-keychain";
import * as AWS from "aws-sdk";
import { getAWSCredentials } from "../../../Connectors/auth/aws";
import { getCognitoUser } from "../../../Connectors/auth/cognitoUser";
import { CognitoRefreshToken } from "amazon-cognito-identity-js";
import {
	needsRefresh,
	refreshTokens,
	logout,
} from "../../../Connectors/auth/auth";
import { UserContext } from "../../../context/userContext";

import { useLazyQuery } from "@apollo/client";
import { getInitialUser } from "../../../Connectors/graphql/queries/getInitialUser";

const Home = ({ navigation }: HomeProps) => {
	const dispatch = useAppDispatch();
	// const user = useAppSelector((state) => state.auth);
	const user = useContext(UserContext);

	const handleLogout = async () => {
		await Keychain.resetGenericPassword();
		// dispatch(logoutUser());
		user?.setUser(null);
		logout();
	};

	if (!user) {
		handleLogout();
		return (
			<>
				<Text>Not Authenticated</Text>
			</>
		);
	}

	if (!user.user) {
		handleLogout();
		return (
			<>
				<Text>Not Authenticated</Text>
			</>
		);
	}

	const [getUser, { loading, error, data }] = useLazyQuery(getInitialUser, {
		context: {
			headers: {
				Authorization: "Bearer " + user.user.accessToken,
			},
		},
	});

	useEffect(() => {
		if (!getUser) return;
		if (!user.user) return;

		let variables = {
			where: {
				id: user.user?.username,
			},
		};

		getUser({ variables });
	}, [getUser, user]);

	if (loading) {
		return <Text style={styles.text}>Loading user details...</Text>;
	}

	useEffect(() => {
		if (data) {
			let completeProfile: boolean = data.users.length !== 1;

			if (completeProfile) {
				let user = data.users[0];

				if (!user) return;

				let displayUsername = user.username;
				let profilePicture = user.profilePicture;

				//@ts-ignore
				user.setUser((prev) => {
					return {
						...prev,
						displayUsername,
						profilePicture,
						completeProfile,
					};
				});
			} else {
				//@ts-ignore
				user.setUser((prev) => {
					return { ...prev, completeProfile };
				});
			}
		}

		if (error) {
			console.error("Error, ", error.message);
			handleLogout();
		}
	}, [data, error]);

	const handleTrial = async () => {
		if (!user.user) return;

		if (needsRefresh(user.user.expireAt)) {
			// refreshing token
			const tokens = await refreshTokens(user.user.refreshToken);
			if (JSON.stringify(tokens) !== "{}") {
				dispatch(updateTokens(tokens));
			} else {
				console.error("can't refresh tokens");
				return;
			}
		}
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

		if (needsRefresh(user.user.expireAt)) {
			console.log("refresh tokens here");
		} else {
			console.log("no need to refresh now");
		}
		return;

		// const updateAttributes = [
		// 	{
		// 		Name: "preferred_username",
		// 		Value: user.awsUsername,
		// 		// Value: "rohan",
		// 	},
		// ];
		// const cognitoUser = getCognitoUser();

		// cognitoUser?.updateAttributes(updateAttributes, (err, result) => {
		// 	if (err) {
		// 		console.log("Error updating user attributes ", err);
		// 	} else {
		// 		console.log("Successfully updated user attributes ", result);
		// 	}
		// });
	};

	return (
		<View>
			<Text style={styles.text}>{`Hii ${user.user.name}`}</Text>

			{!user.user.completeProfile && (
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
