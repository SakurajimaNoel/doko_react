import { View, Text, StyleSheet } from "react-native";
import React, { useContext, useEffect } from "react";
import { HomeProps } from "./types";
import { Button } from "@rneui/themed";
import * as Keychain from "react-native-keychain";
import { refreshTokens, logout } from "../../../Connectors/auth/auth";
import { UserContext, UserDispatchContext } from "../../../context/userContext";

import { useLazyQuery } from "@apollo/client";
import { getInitialUser } from "../../../Connectors/graphql/queries/getInitialUser";
import {
	Payload,
	ProfileStatusKind,
	UserActionKind,
} from "../../../context/types";

const Home = ({ navigation }: HomeProps) => {
	const user = useContext(UserContext);
	const userDispatch = useContext(UserDispatchContext);

	const handleLogout = async () => {
		await Keychain.resetGenericPassword();
		if (!userDispatch) {
			logout();
			return;
		}

		userDispatch({ type: UserActionKind.ERASE, payload: null });
		logout();
	};

	const [getUser, { loading, error, data }] = useLazyQuery(getInitialUser, {
		context: {
			headers: {
				Authorization: "Bearer " + user?.accessToken,
			},
		},
	});

	useEffect(() => {
		if (!getUser) return;
		if (!user) return;

		let variables = {
			where: {
				id: user.username,
			},
		};

		getUser({ variables });
	}, [getUser, user]);

	useEffect(() => {
		if (data) {
			let completeProfile: boolean = data.users.length === 1;

			let profileStatus: ProfileStatusKind = completeProfile
				? ProfileStatusKind.COMPLETE
				: ProfileStatusKind.INCOMPLETE;

			let payload: Payload;

			if (completeProfile) {
				let userData = data.users[0];

				if (!userData) return;

				let displayUsername = userData.username;
				let profilePicture = userData.profilePicture;
				let name = userData.name;

				payload = {
					displayUsername,
					profilePicture,
					profileStatus,
					name,
				};
			} else {
				payload = {
					profileStatus,
				};
			}

			if (!userDispatch) return;

			userDispatch({ type: UserActionKind.INIT, payload });
		}

		if (error) {
			console.error("Error, ", error.message);
			// handleLogout();
		}
	}, [data, error]);

	// token refreshing
	useEffect(() => {
		let time = 50; // in mins

		const refreshTokenInterval = setInterval(async () => {
			if (!user) return;
			if (!userDispatch) return;

			const tokens = await refreshTokens(user.refreshToken);

			if (JSON.stringify(tokens) !== "{}") {
				let payload = {
					...tokens,
				};

				userDispatch({
					type: UserActionKind.TOKEN,
					payload,
				});
			} else {
				console.error("can't refresh tokens");
				return;
			}
		}, time * 60 * 1000);

		return () => clearInterval(refreshTokenInterval);
	}, []);

	if (loading) {
		return <Text style={styles.text}>Loading user details...</Text>;
	}

	if (!user) {
		handleLogout();
		return (
			<>
				<Text>Not Authenticated</Text>
			</>
		);
	}

	if (error) {
		<View>
			<Text style={styles.text}>{`Hii ${user.name}`}</Text>

			<Text style={styles.text}>Can't fetch user profile right now</Text>

			{user.profileStatus === ProfileStatusKind.INCOMPLETE && (
				<Text style={styles.text}>Incomplete profile</Text>
			)}

			<Button
				onPress={handleLogout}
				title="Logout"
				accessibilityLabel="Logout"
				type="clear"
			/>
		</View>;
	}

	return (
		<View>
			<Text style={styles.text}>{`Hii ${user.name}`}</Text>

			{user.profileStatus === ProfileStatusKind.INCOMPLETE && (
				<Text style={styles.text}>Incomplete profile</Text>
			)}

			<Button
				onPress={handleLogout}
				title="Logout"
				accessibilityLabel="Logout"
				type="clear"
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
