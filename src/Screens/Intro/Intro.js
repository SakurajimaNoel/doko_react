import { View, Text, StyleSheet, SafeAreaView, Button } from "react-native";
import React from "react";

export default function Intro({ navigation }) {
	const handleAuthNavigation = (toLogin = true) => {
		if (toLogin) {
			// navigate to login screen
		} else {
			// navigate to signup screen
		}
	};

	return (
		<View style={styles.container}>
			<View style={styles.headContainer}>
				<Text style={styles.head}>Hii welcome to dokii</Text>
			</View>

			<View style={styles.buttonContainer}>
				<Button
					onPress={() => handleAuthNavigation()}
					title="Login"
					accessibilityLabel="To navigate to login screen"
				/>

				<Button
					onPress={() => handleAuthNavigation(false)}
					title="Signup"
					accessibilityLabel="To navigate to Signup screen"
				/>
			</View>
		</View>
	);
}

const styles = StyleSheet.create({
	container: {
		margin: 10,
		flex: 1,
	},
	headContainer: {
		flex: 1,
		paddingTop: 10,
	},
	buttonContainer: {
		flex: 3,
		gap: 15,
	},
	head: {
		color: "black",
		fontSize: 24,
		textAlign: "center",
		fontWeight: 500,
	},
});
