import { View, Text, StyleSheet } from "react-native";
import React, { useContext, useEffect } from "react";

import { updateUser } from "../../../../Connectors/graphql/mutation/updateUser";
import {
	UserContext,
	UserDispatchContext,
} from "../../../../context/userContext";
import { useMutation } from "@apollo/client";
import { UserActionKind } from "../../../../context/types";

export default function EditProfile() {
	const user = useContext(UserContext);
	const userDispatch = useContext(UserDispatchContext);

	const [updateUserProfile, { data, loading, error }] = useMutation(
		updateUser,
		{
			context: {
				headers: {
					Authorization: "Bearer " + user?.accessToken,
				},
			},
		},
	);

	useEffect(() => {
		if (data) {
			console.log("Profile updated");
			console.log(data);
			// more work on this

			if (!userDispatch) return;

			userDispatch({
				type: UserActionKind.UPDATE,
				payload: {
					name: "",
					username: "",
				},
			});
		}

		if (error) {
			console.error("error updating user profile", error);
		}
	}, [data, error]);

	return (
		<View>
			<Text style={styles.text}>EditProfile</Text>
		</View>
	);
}

const styles = StyleSheet.create({
	text: {
		color: "black",
		fontSize: 22,
		marginVertical: 10,
	},
});
