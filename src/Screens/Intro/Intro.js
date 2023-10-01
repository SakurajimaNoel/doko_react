import { View, Text, StyleSheet, SafeAreaView, Button } from "react-native";
import React from "react";

import { useQuery } from "@apollo/client";
import { getUserProfile } from "../../stale/graphql/queries/getUserProfile";

export default function Intro({ navigation }) {

	const handleAuthNavigation = (toLogin = true) => {
		if (toLogin) {
			// navigate to login screen
			navigation.navigate("Login");
		} else {
			// navigate to signup screen
			navigation.navigate("Signup");
		}
	};

	const {loading, error, data} = useQuery(getUserProfile,
		{
			variables: {
				where: {
					id: "7ca6b20b-3d7f-4712-a2ca-a99551011681",
				},
				friendsWhere2: {
					friendsConnection_ALL: {
						edge: {
							status: "ACCEPTED",
						},
					},
				},
				options: {
					limit: 5,
				},
			}
			
		});
	if(loading) console.log("Loading");
	if(error) console.error("API error", error.message);
	if(data) console.log(data);



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
