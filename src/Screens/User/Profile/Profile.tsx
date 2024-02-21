import { View, Text } from "react-native";
import React, { useContext } from "react";
import { ProfileProps } from "./types";

import CompleteProfile from "./components/CompleteProfile";
import UserProfile from "./components/UserProfile";
import { UserContext } from "../../../context/userContext";

const Profile = ({ navigation }: ProfileProps) => {
	const user = useContext(UserContext);

	const editProfile = () => {
		if (!user) return;

		navigation.navigate("Profile", {
			screen: "EditProfile",
			params: {
				name: user.name,
				bio: "",
				username: user.displayUsername ? user.displayUsername : "",
			},
		});
	};

	return (
		<View>
			{user?.completeProfile ? (
				<UserProfile navigation={navigation} />
			) : (
				<CompleteProfile />
			)}
		</View>
	);
};

export default Profile;
