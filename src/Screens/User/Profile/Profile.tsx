import { View, Text } from "react-native";
import React, { useContext } from "react";
import { ProfileProps } from "./types";

import CompleteProfile from "./components/CompleteProfile";
import UserProfile from "./components/UserProfile";
import { UserContext } from "../../../context/userContext";

const Profile = ({ navigation }: ProfileProps) => {
	const user = useContext(UserContext);

	return (
		<View>
			{user?.user?.completeProfile ? (
				<UserProfile />
			) : (
				<CompleteProfile />
			)}
		</View>
	);
};

export default Profile;
