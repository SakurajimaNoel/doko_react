import { View, Text, StyleSheet } from "react-native";
import React, { useState, useEffect } from "react";
import { CompleteProfileProps, Steps, UserInfo } from "../types";
import * as AWS from "aws-sdk";

import Username from "./profileSteps/Username";
import UserDetails from "./profileSteps/UserDetails";
import ProfilePicture from "./profileSteps/ProfilePicture";
import { getAWSCredentials } from "../../../../Connectors/auth/aws";
import { needsRefresh, refreshTokens } from "../../../../Connectors/auth/auth";
import { useAppDispatch, useAppSelector } from "../../../../hooks/reduxHooks";
import { updateTokens } from "../../../../redux/slices/authSlice";
import { ManagedUpload } from "aws-sdk/clients/s3";

const CompleteProfile = ({ auth }: CompleteProfileProps) => {
	const dispatch = useAppDispatch();
	const user = useAppSelector((state) => state.auth);
	const [steps, setSteps] = useState<Steps>(3);
	const [userInfo, setUserInfo] = useState<UserInfo>({
		username: "",
		dob: new Date(),
		bio: "",
		profilePicture: "",
		imageExtension: "",
		imageType: "",
	});

	const handleNext = () => {
		setSteps((prev) => (prev + 1) as Steps);
	};

	const handlePrev = () => {
		setSteps((prev) => (prev - 1) as Steps);
	};

	const handleProfileCreate = async () => {
		// handle token expiry
		if (needsRefresh(user.expireAt)) {
			const tokens = await refreshTokens(user.refreshToken);
			if (JSON.stringify(tokens) !== "{}") {
				dispatch(updateTokens(tokens));
			} else {
				console.error("can't refresh tokens");
				return;
			}
		}

		// upload image
		const credentials = getAWSCredentials();
		credentials?.get(async (error) => {
			if (error) {
				console.error("Error fetching AWS credentials: ", error);
			} else {
				var accessKeyId = credentials.accessKeyId;
				var secretAccessKey = credentials.secretAccessKey;
				var sessionToken = credentials.sessionToken;

				const s3 = new AWS.S3({
					accessKeyId,
					secretAccessKey,
					sessionToken,
					region: "ap-south-1",
				});

				let bucketName = "dokiuserprofile";
				let key = `trial/a.${userInfo.imageExtension}`;

				console.log(key);
				const response = await fetch(userInfo.profilePicture);
				const blob = await response.blob();

				let params = {
					Bucket: bucketName,
					Key: key,
					Body: blob,
					ContentType: userInfo.imageType,
				};

				s3.upload(
					params,
					(err: Error, data: ManagedUpload.SendData) => {
						if (err) {
							console.error("Error uploading image: ", err);
						} else {
							console.log(data);
							console.log(
								"Image uploaded successfully. Location:",
								data.Key,
							);
						}
					},
				);
			}
		});
		// update username in aws

		// create node in neo4j
	};

	const completeProfileStep = () => {
		switch (steps) {
			case 1:
				return (
					<Username
						handleNext={handleNext}
						accessToken={auth.accessToken}
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
