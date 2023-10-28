import { View, Text, StyleSheet } from "react-native";
import React from "react";
import { ProfilePictureProps } from "../../types";

const ProfilePicture = ({
	handlePrev,
	setUserInfo,
	userInfo,
	handleProfileCreate,
}: ProfilePictureProps) => {
	return (
		<View>
			<Text style={styles.head}>ProfilePicture</Text>
		</View>
	);
};

const styles = StyleSheet.create({
	head: {
		color: "black",
	},
});

export default ProfilePicture;
