import { StyleSheet, Text, View } from "react-native";
import React from "react";
import { PostItemProps } from "../../types";

const PostItem = ({ route, navigation }: PostItemProps) => {
	return (
		<View>
			<Text style={styles.text}>{route.params.id}</Text>
			<Text style={styles.text}>{route.params.caption}</Text>
			<Text style={styles.text}>{route.params.content.length}</Text>
			<Text style={styles.text}>{route.params.likes}</Text>
		</View>
	);
};

export default PostItem;

const styles = StyleSheet.create({
	text: {
		color: "black",
	},
});
