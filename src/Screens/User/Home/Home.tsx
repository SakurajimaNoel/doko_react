import { View, Text } from "react-native";
import React from "react";
import { HomeProps } from "./types";
import { Button } from "@rneui/themed";
import { useAppDispatch } from "../../../hooks/reduxHooks";
import { toggle } from "../../../redux/slices/authSlice";

const Home = ({ navigation }: HomeProps) => {
	const dispatch = useAppDispatch();

	const handleAuthChange = () => {
		dispatch(toggle());
	};

	return (
		<View>
			<Text>Home</Text>

			<Button
				onPress={handleAuthChange}
				title="Auth Change"
				accessibilityLabel="auth change"
				type="clear"
			/>
		</View>
	);
};

export default Home;
