import { View, Text } from "react-native";
import React from "react";
import { ProfileProps } from "./types";
import { useAppSelector } from "../../../hooks/reduxHooks";

import CompleteProfile from "./components/CompleteProfile";
import UserProfile from "./components/UserProfile";

const Profile = ({ navigation }: ProfileProps) => {
	const auth = useAppSelector((state) => state.auth);

	return (
		<View>
			{auth.completeProfile ? (
				<UserProfile />
			) : (
				<CompleteProfile auth={auth} />
			)}
		</View>
	);
};

export default Profile;
