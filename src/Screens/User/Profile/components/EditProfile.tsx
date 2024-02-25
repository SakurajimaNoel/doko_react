import { View, Text, StyleSheet, TextInput, ScrollView } from "react-native";
import React, { useContext, useEffect, useRef, useState } from "react";

import { updateUser } from "../../../../Connectors/graphql/mutation/updateUser";
import {
	UserContext,
	UserDispatchContext,
} from "../../../../context/userContext";
import { useLazyQuery, useMutation } from "@apollo/client";
import { UserActionKind } from "../../../../context/types";
import { EditProfileProps } from "../types";
import UpdateProfileImage from "./updateProfile/UpdateProfileImage";

import { useDebounce } from "use-debounce";
import { getUsername } from "../../../../Connectors/graphql/queries/getUsername";
import { Button } from "@rneui/base";

export default function EditProfile({ route, navigation }: EditProfileProps) {
	const [userDetail, setUserDetails] = useState({
		bio: route.params.bio,
		name: route.params.name,
	});

	const [username, setUsername] = useState(route.params.username);
	const [debounceUsername] = useDebounce(username, 500);
	const [usernameError, setUsernameError] = useState<string | null>(null);

	const user = useContext(UserContext);
	const userDispatch = useContext(UserDispatchContext);

	const run = useRef<number>(0);

	const [
		updateUserProfile,
		{
			data: updateProfileData,
			loading: updateProfileLoading,
			error: updateProfileError,
		},
	] = useMutation(updateUser, {
		context: {
			headers: {
				Authorization: "Bearer " + user?.accessToken,
			},
		},
	});

	const [
		getUsers,
		{ loading: userLoading, error: userError, data: userData },
	] = useLazyQuery(getUsername, {
		context: {
			headers: {
				Authorization: "Bearer " + user?.accessToken,
			},
		},
	});

	const handleUsername = () => {
		if (run.current === 1) return;
		if (username.length === 0 || typeof username !== "string") return;

		let variables = {
			where: {
				username,
			},
		};

		getUsers({ variables });
	};

	useEffect(() => {
		run.current++;
		handleUsername();
	}, [debounceUsername]);

	useEffect(() => {
		let data = userData;
		let error = userError;

		if (data) {
			let validUsername: boolean = data?.users.length === 0;

			if (!validUsername) {
				setUsernameError("Username already in use");
			} else {
				setUsernameError(null);
			}
		}
		if (error) {
			console.log("Error, ", error.message);
			setUsernameError(error.message);
		}
	}, [userData, userError]);

	useEffect(() => {
		if (updateProfileData) {
			console.log("Profile updated");
			const { username: validUsername, name } =
				updateProfileData.updateUsers.users;

			if (!userDispatch) return;

			userDispatch({
				type: UserActionKind.UPDATE,
				payload: {
					name: name,
					displayUsername: validUsername,
				},
			});
			navigation.navigate("ProfileInfo");
		}

		if (updateProfileError) {
			console.error("error updating user profile", updateProfileError);
		}
	}, [updateProfileData, updateProfileError]);

	const updateProfile = () => {
		if (!user) return;

		let variables = {
			where: {
				id: user.username,
			},
			update: {
				bio: userDetail.bio,
				name: userDetail.name,
				username,
			},
		};

		updateUserProfile({ variables });
	};

	// if (updateProfileLoading) {
	// 	return (
	// 		<View>
	// 			<Text style={styles.text}>Updating user profile</Text>
	// 		</View>
	// 	);
	// }

	let valid = false;
	{
		let { bio, username: un, name } = route.params;

		valid ||= bio !== userDetail.bio;
		valid ||= name !== userDetail.name;

		if (valid) {
			valid = !usernameError;
		} else {
			valid = un !== username && !usernameError;
		}
	}

	return (
		<ScrollView style={styles.container}>
			<UpdateProfileImage profileImage={route.params.profilePicture} />

			{/* userinfo */}
			<View>
				{/* name */}
				<View style={styles.detailContainer}>
					<Text style={styles.detailHead}>Name</Text>

					<TextInput
						style={styles.inputStyle}
						numberOfLines={4}
						onChangeText={(text) => {
							return setUserDetails((prev) => {
								return {
									...prev,
									name: text,
								};
							});
						}}
						value={userDetail.name}
						placeholder="name..."
						placeholderTextColor="#7F8487"
					/>
				</View>

				{/* username */}
				<View style={styles.detailContainer}>
					<Text style={styles.detailHead}>Username</Text>

					<TextInput
						style={styles.inputStyle}
						numberOfLines={4}
						onChangeText={setUsername}
						value={username}
						placeholder="username..."
						placeholderTextColor="#7F8487"
					/>

					{usernameError && (
						<Text style={styles.error}>{usernameError}</Text>
					)}
				</View>

				{/* bio */}
				<View style={styles.detailContainer}>
					<Text style={styles.detailHead}>Bio</Text>

					<TextInput
						style={styles.detailInput}
						multiline={true}
						numberOfLines={4}
						onChangeText={(text) => {
							return setUserDetails((prev) => {
								return {
									...prev,
									bio: text,
								};
							});
						}}
						value={userDetail.bio}
						placeholder="Bio here..."
						placeholderTextColor="#7F8487"
					/>
				</View>

				<Button
					disabled={!valid || updateProfileLoading}
					onPress={updateProfile}
					title="Update"
					loading={updateProfileLoading}
					accessibilityLabel="Update profile"
					containerStyle={{ marginTop: 20 }}
				/>
			</View>
		</ScrollView>
	);
}

const styles = StyleSheet.create({
	container: {
		padding: 10,
		flex: 1,
		gap: 10,
	},
	text: {
		color: "black",
		fontSize: 22,
		marginVertical: 10,
	},
	detailInput: {
		borderWidth: 1,
		padding: 10,
		color: "#413F42",
		fontWeight: "500",
	},
	inputStyle: {
		height: 40,
		borderWidth: 1,
		padding: 10,
		color: "#111",
		fontWeight: "500",
		marginBottom: 15,
	},
	detailContainer: {
		// padding: 10,
		marginBottom: 10,
	},
	detailHead: {
		color: "black",
		fontSize: 18,
		marginBottom: 10,
		fontWeight: "500",
	},
	error: {
		color: "red",
		marginTop: -10,
		marginBottom: 15,
		paddingLeft: 5,
	},
});
