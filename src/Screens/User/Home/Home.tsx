import { View, Text, StyleSheet } from "react-native";
import React from "react";
import { HomeProps } from "./types";
import { Button } from "@rneui/themed";
import { useAppDispatch, useAppSelector } from "../../../hooks/reduxHooks";
import { logoutUser } from "../../../redux/slices/authSlice";
import * as Keychain from "react-native-keychain";
import * as AWS from "aws-sdk";
import { getAWSCredentials } from "../../../Connectors/auth/aws";

const Home = ({ navigation }: HomeProps) => {
	const dispatch = useAppDispatch();
	const user = useAppSelector((state) => state.auth);

	const handleLogout = async () => {
		await Keychain.resetGenericPassword();
		dispatch(logoutUser());
	};

	const handleTrial = () => {
		const credentials = getAWSCredentials();

		credentials?.get((error) => {
			if (error) {
				console.error("Error fetching AWS credentials: ", error);
			} else {
				// Initialize AWS service with the obtained credentials
				const s3 = new AWS.S3();

				// Example: List S3 buckets
				s3.listBuckets((err, data) => {
					if (err) {
						console.error("Error listing S3 buckets: ", err);
					} else {
						console.log("S3 buckets: ", data.Buckets);
					}
				});

				// You can use other AWS services similarly with the obtained credentials
			}
		});
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
			<Button
				onPress={handleTrial}
				title="trial"
				accessibilityLabel="Logout"
				// type="clear"
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
