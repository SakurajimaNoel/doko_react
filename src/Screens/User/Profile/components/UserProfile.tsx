import { View, Text, StyleSheet, ScrollView } from "react-native";
import { Button, Image } from "@rneui/base";
import React, { useContext, useEffect, useRef, useState } from "react";
import { UserContext } from "../../../../context/userContext";
import { getS3Obj } from "../../../../Connectors/auth/aws";
import * as AWS from "aws-sdk";
import { UserActionKind } from "../../../../context/types";
import { CompleteUser, UserProfileProps } from "../types";
import { useLazyQuery, useQuery } from "@apollo/client";
import { getCompleteUser } from "../../../../Connectors/graphql/queries/getCompleteUser";
import { images } from "../../../../assests/index";

const UserProfile = ({ navigation }: UserProfileProps) => {
	const user = useContext(UserContext);

	const [getUserDetail, { loading, error, data }] = useLazyQuery(
		getCompleteUser,
		{
			context: {
				headers: {
					Authorization: "Bearer " + user?.accessToken,
				},
			},
			variables: {
				where: {
					id: user?.username,
				},
			},
		},
	);

	const [completeUser, setCompleteUser] = useState<CompleteUser | null>(null);

	const [image, setImage] = useState<string | null>(null);

	useEffect(() => {
		getUserDetail();
	}, [user]);

	useEffect(() => {
		if (data) {
			// data.user[0].friends.length friends
			// data.users[0].posts.length posts

			let user = data.users[0];
			if (!user) return;

			const {
				bio,
				dob,
				email,
				name,
				username,
				profilePicture,
				friends,
				posts,
			} = user;

			setCompleteUser({
				bio,
				dob,
				email,
				name,
				username,
				profilePicture,
				friends,
				posts,
			});
		}
	}, [data]);

	useEffect(() => {
		if (!completeUser || !completeUser.profilePicture) return;

		const s3 = getS3Obj();
		if (!s3) return;

		let bucketName = "dokiuserprofile";
		let key = completeUser.profilePicture;

		const params = {
			Bucket: bucketName,
			Key: key,
			Expires: 180,
		};

		s3.getSignedUrl("getObject", params, (err, url) => {
			if (err) {
				console.error("Error generating signed URL:", err);
				return;
			}

			// Use this signed URL in your React Native component
			setImage(url);
		});
	}, [completeUser, user]);

	const handleEditProfile = () => {
		if (!completeUser) return;

		navigation.navigate("Profile", {
			screen: "EditProfile",
			params: {
				name: completeUser.name,
				bio: completeUser.bio,
				username: completeUser.username,
				profilePicture: image ? image : "",
			},
		});
	};

	if (!user) {
		// handleLogout();
		return (
			<>
				<Text>Not Authenticated</Text>
			</>
		);
	}

	if (loading) {
		return (
			<View>
				<Text style={styles.text}>Loading</Text>
			</View>
		);
	}

	if (error) {
		console.error(error);
		return (
			<View>
				<Text style={styles.text}>Error Loading Profile</Text>
			</View>
		);
	}

	let dob = new Date();
	if (completeUser) {
		dob = new Date(completeUser.dob);
	}

	return (
		<>
			<ScrollView style={styles.container}>
				{/* username */}
				<View>
					<Text style={styles.text}>{completeUser?.username}</Text>
				</View>
				{/* profile info */}
				<View>
					{/* profile picture */}
					<View>
						<Image
							source={image ? { uri: image } : images.profile}
							style={{ width: 200, height: 200 }}
						/>
					</View>

					{/* profile details */}
					<View>
						<Text style={styles.text}>{completeUser?.name}</Text>

						<Text style={styles.text}>
							{dob.toLocaleString("default", {
								day: "numeric",
								month: "short",
							})}
						</Text>
					</View>
				</View>
				{/* bio */}
				<View>
					<Text style={styles.text}>{completeUser?.bio}</Text>
				</View>
				{/* profile options */}
				<View>
					{/* friends */}
					<View>
						<Text style={styles.text}>
							Friends: {completeUser?.friends.length}
						</Text>
					</View>

					{/* posts */}
					<View>
						<Text style={styles.text}>
							Posts: {completeUser?.posts.length}
						</Text>
					</View>

					{/* edit */}
					<View>
						<Button onPress={handleEditProfile} title="Edit" />
					</View>
				</View>

				{/* posts */}
				{completeUser &&
					(completeUser.posts.length > 0 ? (
						<View></View>
					) : (
						<View>
							<Text style={styles.text}>
								Upload your first post to see it here.
							</Text>
						</View>
					))}
			</ScrollView>
		</>
	);
};

const styles = StyleSheet.create({
	text: {
		color: "black",
		fontSize: 16,
		marginVertical: 10,
	},
	space: {
		width: 20,
		height: 20,
	},

	container: {
		paddingHorizontal: 8,
	},
});

export default UserProfile;
