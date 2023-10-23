import { View, Text, StyleSheet } from "react-native";
import React from "react";
import { HomeProps } from "./types";
import { Button } from "@rneui/themed";
import { useAppDispatch, useAppSelector } from "../../../hooks/reduxHooks";
import { logoutUser } from "../../../redux/slices/authSlice";

const Home = ({ navigation }: HomeProps) => {
	const dispatch = useAppDispatch();
	const user = useAppSelector((state) => state.auth);

	const handleLogout = () => {
		dispatch(logoutUser());
	};

	return (
		<View>
			<Text style={styles.text}>{`Hii ${user.username}`}</Text>

			{!user.completeProfile && (
				<Text style={styles.text}>Incomplete profile</Text>
			)}

			<Button
				onPress={handleLogout}
				title="Logout"
				accessibilityLabel="Logout"
				type="clear"
			/>
		</View>
	);
};

const styles = StyleSheet.create({
	text: {
		color: "black",
	},
});

export default Home;
