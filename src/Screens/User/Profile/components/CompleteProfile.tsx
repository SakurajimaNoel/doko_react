import { View, Text, StyleSheet } from "react-native";
import React, { useState, useEffect, useContext } from "react";
import { Steps, UserInfo } from "../types";
import * as AWS from "aws-sdk";

import Username from "./profileSteps/Username";
import UserDetails from "./profileSteps/UserDetails";
import ProfilePicture from "./profileSteps/ProfilePicture";
import { getAWSCredentials } from "../../../../Connectors/auth/aws";
import { needsRefresh, refreshTokens } from "../../../../Connectors/auth/auth";
import { ManagedUpload } from "aws-sdk/clients/s3";
import {
	UserContext,
	UserDispatchContext,
} from "../../../../context/userContext";
import { useMutation } from "@apollo/client";
import { createUser } from "../../../../Connectors/graphql/mutation/createUser";
import { UserActionKind } from "../../../../context/types";

const CompleteProfile = () => {
	const user = useContext(UserContext);
	const userDispatch = useContext(UserDispatchContext);

	const [steps, setSteps] = useState<Steps>(1);
	const [userInfo, setUserInfo] = useState<UserInfo>({
		username: "",
		dob: new Date(),
		bio: "",
		profilePicture: "",
		imageExtension: "",
		imageType: "",
	});

	const [createUserProfile, { data, loading, error }] = useMutation(
		createUser,
		{
			context: {
				headers: {
					Authorization: "Bearer " + user?.accessToken,
				},
			},
		},
	);

	useEffect(() => {
		if (data) {
			console.log("Profile created");
			console.log(data);

			if (!userDispatch) return;

			userDispatch({
				type: UserActionKind.UPDATE,
				payload: {
					displayUsername: userInfo.username,
					completeProfile: true,
					profilePicture: `${userInfo.username}/profile.${userInfo.imageExtension}`,
				},
			});
		}

		if (error) {
			console.error("error completing user profile");
		}
	}, [data, error]);

	const handleNext = () => {
		setSteps((prev) => (prev + 1) as Steps);
	};

	const handlePrev = () => {
		setSteps((prev) => (prev - 1) as Steps);
	};

	const handleProfileCreate = async () => {
		if (!user) return;

		let key = "";

		// handle token expiry
		if (needsRefresh(user.expireAt)) {
			const tokens = await refreshTokens(user.refreshToken);
			if (JSON.stringify(tokens) !== "{}") {
				// dispatch(updateTokens(tokens));
				// token refreshing
			} else {
				console.error("can't refresh tokens");
				return;
			}
		}

		// upload image
		// handle no image case too
		if (userInfo.profilePicture) {
			const profilePicture = userInfo.profilePicture;
			const credentials = getAWSCredentials();
			key = `${user.username}/profile.${userInfo.imageExtension}`;

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

					console.log(key);
					const response = await fetch(profilePicture);
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

								// create node in neo4j
								let variables = {
									input: [
										{
											id: user.username,
											username: userInfo.username,
											email: user.email,
											bio: userInfo.bio,
											dob: userInfo.dob,
											name: user.name,
											profilePicture: key,
										},
									],
								};

								createUserProfile({
									variables,
								});
							}
						},
					);
				}
			});
		} else {
		}
	};

	const completeProfileStep = () => {
		// const user = userDetails?.user;

		if (!user) return;

		switch (steps) {
			case 1:
				return (
					<Username
						handleNext={handleNext}
						accessToken={user.accessToken}
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

	if (loading) {
		return (
			<View>
				<Text style={styles.head}>Completing profile....</Text>
			</View>
		);
	}

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
