import { View, Text, StyleSheet, TextInput } from "react-native";
import React, { useState, useEffect } from "react";
import { Button } from "@rneui/themed";
import { UsernameProps } from "../../types";
import { useLazyQuery } from "@apollo/client";
import { getUsername } from "../../../../../Connectors/graphql/queries/getUsername";

const Username = ({
	handleNext,
	accessToken,
	setUserInfo,
	userName,
}: UsernameProps) => {
	const [username, setUsername] = useState<string>(userName);
	const [err, setErr] = useState<string>("");
	const [getUsers, { loading, error, data }] = useLazyQuery(getUsername, {
		context: {
			headers: {
				Authorization: "Bearer " + accessToken,
			},
		},
	});

	const handleUsername = () => {
		if (username.length === 0 || typeof username !== "string") return;

		let variables = {
			where: {
				username,
			},
		};

		getUsers({ variables });
	};

	useEffect(() => {
		if (data) {
			let validUsername: boolean = data?.users.length === 0;

			if (!validUsername) {
				setErr("Username already in use");
			} else {
				setErr("");
				setUserInfo((prev) => ({ ...prev, username }));
				handleNext();
			}
		}
		if (error) {
			console.log("Error, ", error.message);
			setErr(error.message);
		}
	}, [data, error]);

	return (
		<View style={styles.container}>
			<Text style={styles.head}>Username</Text>

			<TextInput
				style={styles.inputStyle}
				value={username}
				placeholder="username..."
				placeholderTextColor="#7F8487"
				onChangeText={setUsername}
			/>
			{err.length > 0 && <Text style={styles.error}>{err}</Text>}

			<Button
				disabled={loading || username.length === 0}
				onPress={handleUsername}
				title="Next"
				loading={loading}
				accessibilityLabel="Move to next page to fill details"
			/>
		</View>
	);
};

const styles = StyleSheet.create({
	container: {
		padding: 10,
	},
	head: {
		color: "black",
		fontSize: 20,
		fontWeight: "500",
		marginBottom: 15,
	},
	inputStyle: {
		height: 40,
		borderWidth: 1,
		padding: 10,
		color: "#111",
		fontWeight: "500",
		marginBottom: 15,
	},
	error: {
		color: "red",
		marginTop: -10,
		marginBottom: 15,
		paddingLeft: 5,
	},
});

export default Username;
