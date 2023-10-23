import { View, Text, StyleSheet } from "react-native";
import { Button } from "@rneui/themed";
import React from "react";

import { gql, useQuery } from "@apollo/client";
import { getUserProfile } from "../../stale/graphql/queries/getUserProfile";

import NetworkLogger from "react-native-network-logger";
import { IntroProps } from "./types";

const tempquery = gql`
	query Users {
		users {
			id
		}
	}
`;

export default function Intro({ navigation }: IntroProps) {
	const handleAuthNavigation = (toLogin = true) => {
		if (toLogin) {
			// navigate to login screen
			navigation.navigate("Login");
		} else {
			// navigate to signup screen
			navigation.navigate("Signup");
		}
	};

	//temp fr testing******************************************************************************************************************************/
	// const token  = "eyJraWQiOiJXV1NWOFwvbEVwYjNtZ29RZmplUGVKaVU3YUNtQzBBdFlhRGdLV1J6QXpnOD0iLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiI2MDBhNDc3Ny1kZTJhLTRiZWUtYjNmYS01Y2RjZTU1MWY0NzAiLCJpc3MiOiJodHRwczpcL1wvY29nbml0by1pZHAuYXAtc291dGgtMS5hbWF6b25hd3MuY29tXC9hcC1zb3V0aC0xXzd5OVJLYkkzaiIsImNsaWVudF9pZCI6IjI3NXAycGZydnFoZG5kcWFuNjg2bjltdnZhIiwib3JpZ2luX2p0aSI6ImVkNGY2ZWU5LWM3MzAtNDA5OS1hMjg5LWFjYmZhNzU2MTMyYiIsImV2ZW50X2lkIjoiOTE3YmU5NTMtZDFkZC00NDA0LThhYTctN2FiYjFmYjk4MWUxIiwidG9rZW5fdXNlIjoiYWNjZXNzIiwic2NvcGUiOiJhd3MuY29nbml0by5zaWduaW4udXNlci5hZG1pbiIsImF1dGhfdGltZSI6MTY5Njc0OTQ0NywiZXhwIjoxNjk2NzUzMDQ3LCJpYXQiOjE2OTY3NDk0NDcsImp0aSI6IjczMGJlODc2LWQ0ZjAtNDU3Yy1hOGVmLTFjYjUwZmM0ODc3ZSIsInVzZXJuYW1lIjoiYW1pdCJ9.R9uz-zeGs5ATF0PD-QqNP0wzfov5KVdQda-XLD400Q75KKysx3gkhmlRMm4axTOP4GBotBitE6PIzWV9DkzfxX_odqYtZ2UP2Yqxvx2KmwWLvic0d8YPJH2ByGx10cY9RCNI02APBiF244okNzc03LfFrvTH1awYiUxPl1CwL_hFgdDK3GCyLz3TV0Emi3DHUozSf2CqUmfAZvg1EzjmK_8ITkeCoEsvuoMcR_D_ge0SI7N3V2Ub3h9AjDIpT0GJCez7WTSY7aX-DKtE2N9C_ttbbNVWzI1uEzgehGWFRI8yhw01qjDj9sqGDQ2GoiKfQWkOjUnIC1YPTOWedeeR8A"
	// const {loading, error, data} = useQuery(tempquery,
	// 	{
	// 		context:{
	// 			headers:{
	// 				'Authorization': "Bearer " + token,
	// 			}
	// 		}

	// 	},

	// );

	// if(loading) console.log("Loading");
	// if(error) console.error("API error", error.message);
	// if(data) console.log(data);
	//************************************************************************************************************************************** */
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
		//<NetworkLogger /> //no delete
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
		fontWeight: "500",
	},
});
