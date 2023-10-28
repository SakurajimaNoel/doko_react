import { View, Text, StyleSheet } from "react-native";
import React, { useState, useEffect } from "react";
import { CompleteProfileProps, Steps, UserInfo } from "../types";

import Username from "./profileSteps/Username";
import UserDetails from "./profileSteps/UserDetails";
import ProfilePicture from "./profileSteps/ProfilePicture";

const CompleteProfile = ({ auth }: CompleteProfileProps) => {
	const [steps, setSteps] = useState<Steps>(1);
	const [userInfo, setUserInfo] = useState<UserInfo>({
		username: "",
		dob: new Date(),
		bio: "",
		profilePicture: "",
	});

	const handleNext = () => {
		setSteps((prev) => (prev + 1) as Steps);
	};

	const handlePrev = () => {
		setSteps((prev) => (prev - 1) as Steps);
	};

	const handleProfileCreate = () => {};

	const completeProfileStep = () => {
		switch (steps) {
			case 1:
				return (
					<Username
						handleNext={handleNext}
						accessToken={auth.accessToken.token}
						setUserInfo={setUserInfo}
						userName={userInfo.username}
					/>
				);

			case 2:
				return (
					<UserDetails
						handleNext={handleNext}
						handlePrev={handlePrev}
						setUserInfo={setUserInfo}
						userInfo={userInfo}
					/>
				);

			case 3:
				return (
					<ProfilePicture
						handlePrev={handlePrev}
						setUserInfo={setUserInfo}
						userInfo={userInfo}
						handleProfileCreate={handleProfileCreate}
					/>
				);
		}
	};

	return (
		<View style={styles.container}>
			<Text style={styles.head}>Complete Profile</Text>
			<Text style={styles.step}>Step {steps} of 3</Text>

			{completeProfileStep()}
		</View>
	);
};

const styles = StyleSheet.create({
	container: {
		margin: 10,
	},
	head: {
		color: "black",
		fontSize: 22,
		fontWeight: "500",
		textAlign: "center",
	},
	inputContainer: {
		marginTop: 30,
	},
	date: {
		color: "black",
		fontWeight: "500",
	},
	step: {
		color: "black",
		fontWeight: "500",
		fontSize: 18,
		marginBottom: 0,
	},
});

export default CompleteProfile;
