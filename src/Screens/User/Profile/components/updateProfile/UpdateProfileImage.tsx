import { View, Text, StyleSheet } from "react-native";
import React from "react";
import { UpdateProfileImageProps } from "../../types";
import { Image } from "@rneui/base";

import { images } from "../../../../../assests";

export default function UpdateProfileImage({
	profileImage,
}: UpdateProfileImageProps) {
	return (
		<View>
			<Text style={styles.text}>UpdateProfileImage</Text>
			<Image
				source={
					profileImage.length > 0
						? { uri: profileImage }
						: images.profile
				}
				style={{ width: 200, height: 200 }}
			/>
		</View>
	);
}

const styles = StyleSheet.create({
	text: {
		color: "black",
	},
});
