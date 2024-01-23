import { View, Text } from "react-native";
import React, { useContext } from "react";
import { ProfileProps } from "./types";
import { useAppSelector } from "../../../hooks/reduxHooks";

import CompleteProfile from "./components/CompleteProfile";
import UserProfile from "./components/UserProfile";
import { UserContext } from "../../../context/userContext";

const Profile = ({ navigation }: ProfileProps) => {
	const auth = useAppSelector((state) => state.auth);
	const user = useContext(UserContext);

	return (
		<View>
			{user?.user?.completeProfile ? (
				<UserProfile />
			) : (
				<CompleteProfile auth={auth} />
			)}
		</View>
	);
};

export default Profile;
