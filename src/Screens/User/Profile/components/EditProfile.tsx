import { View, Text, StyleSheet } from "react-native";
import React from "react";

export default function EditProfile() {
	return (
		<View>
			<Text style={styles.text}>EditProfile</Text>
		</View>
	);
}

const styles = StyleSheet.create({
	text: {
		color: "black",
		fontSize: 22,
		marginVertical: 10,
	},
});
