import { useMutation } from "@apollo/client";
import { userCreateProfile } from "../../../graphql/mutations/userCreateProfile";
import { View, Text, Button } from "react-native";
import { useState, useRef } from "react";

function CreateUserProfile({ navigation }) {
	const [createProfile, { data, loading, error }] =
		useMutation(userCreateProfile);
	const [profileDetails, setProfileDetails] = useState({
		bio: "using react native application",
		dob: "11-10-2002",
		email: "reactnative@gmail.com",
		id: Math.floor(Math.random() * 100000),
		name: "React Native test",
		profilePicture: "reactnative",
		username: "react",
	});
	const nodesRef = useRef(0);

	if (loading) {
		return (
			<View
				style={{
					flex: 1,
					alignItems: "center",
					justifyContent: "space-between",
					backgroundColor: "#010101",
				}}>
				<Text>Creating user profile {":)"}</Text>
			</View>
		);
	}

	if (error) {
		return (
			<View
				style={{
					flex: 1,
					alignItems: "center",
					justifyContent: "space-between",
					backgroundColor: "#010101",
				}}>
				<Text>Error Creating user profile!! {error.message}</Text>
			</View>
		);
	}

	if (data) {
		nodesRef.current = 1;
	}
	return (
		<View
			style={{
				flex: 1,
				alignItems: "center",
				justifyContent: "space-between",
				backgroundColor: "#010101",
			}}>
			<Button
				title="Create Profile"
				onPress={() =>
					createProfile({
						variables: {
							input: [profileDetails],
						},
					})
				}
			/>
			<Text>Nodes Created: {nodesRef.current}</Text>
		</View>
	);
}

export default CreateUserProfile;
