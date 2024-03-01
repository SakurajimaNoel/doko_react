import { View, Text } from "react-native";
import React, { useContext } from "react";
import { ProfileProps } from "./types";

import CompleteProfile from "./components/CompleteProfile";
import UserProfile from "./components/UserProfile";
import { UserContext } from "../../../context/userContext";
import { ProfileStatusKind } from "../../../context/types";

const Profile = ({ navigation }: ProfileProps) => {
	const user = useContext(UserContext);

	if (!user) {
		return (
			<View>
				<Text style={{ color: "black" }}>Not authenticated</Text>
			</View>
		);
	}

	if (user.profileStatus === ProfileStatusKind.PENDING) {
		return (
			<View>
				<Text style={{ color: "black" }}>Loading</Text>
			</View>
		);
	}

	return (
		<View>
			{user.profileStatus === ProfileStatusKind.COMPLETE ? (
				<UserProfile navigation={navigation} />
			) : (
				<CompleteProfile />
			)}
		</View>
	);
};

export default Profile;
