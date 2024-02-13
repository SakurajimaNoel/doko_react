import { View, Text } from "react-native";
import React, { useContext } from "react";
import { ProfileProps } from "./types";

import CompleteProfile from "./components/CompleteProfile";
import UserProfile from "./components/UserProfile";
import { UserContext } from "../../../context/userContext";

const Profile = ({ navigation }: ProfileProps) => {
	const user = useContext(UserContext);

	const editProfile = () => {
		//@ts-ignore
		navigation.navigate("EditProfile");
	};

	return (
		<View>
			{user?.completeProfile ? (
				<UserProfile navigateEditProfile={editProfile} />
			) : (
				<CompleteProfile />
			)}
		</View>
	);
};

export default Profile;
