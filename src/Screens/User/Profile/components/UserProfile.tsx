import { View, Text, StyleSheet, ScrollView, Pressable } from "react-native";
import { Button, Image } from "@rneui/base";
import React, { useContext, useEffect, useRef, useState } from "react";
import { UserContext } from "../../../../context/userContext";
import { getS3Obj } from "../../../../Connectors/auth/aws";
import { CompleteUser, Post, UserProfileProps } from "../types";
import { useLazyQuery, useQuery } from "@apollo/client";
import { getCompleteUser } from "../../../../Connectors/graphql/queries/getCompleteUser";
import { images } from "../../../../assests/index";
import { getS3PresignedUrl } from "../../../../Connectors/helpers/s3";
import Posts from "./post/Posts";

const UserProfile = ({ navigation }: UserProfileProps) => {
	const user = useContext(UserContext);
	const [refresh, setRefresh] = useState<boolean>(false);
	const [allow, setAllow] = useState(false);

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
		console.log("refetching user profile data");
		getUserDetail();
	}, [user, refresh]);

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

		(async function () {
			try {
				const url = await getS3PresignedUrl(
					completeUser.profilePicture,
				);
				setImage(url);
				setAllow(true);
			} catch (err) {
				return;
			}
		})();
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

	const handleFriends = () => {
		if (!completeUser) return;

		navigation.navigate("Profile", {
			screen: "Friends",
		});
	};

	const handleNewPost = () => {
		if (!completeUser) return;

		navigation.navigate("Profile", {
			screen: "CreatePost",
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

	// let posts: React.ReactElement[] = [];
	// completeUser?.posts.forEach(async (post) => {
	// 	const url = await getS3PresignedUrl(post.content[0]);

	// 	const element = (
	// 		<Pressable
	// 			style={styles.postContainer}
	// 			key={post.id}
	// 			onPress={() => handlePostItem(post)}>
	// 			<Image style={styles.postImage} source={{ uri: url }} />
	// 		</Pressable>
	// 	);

	// 	posts.push(element);
	// });

	return (
		<>
			<ScrollView
				style={styles.container}
				contentContainerStyle={{
					paddingBottom: 20,
				}}>
				{/* username */}
				<View style={styles.usernameContainer}>
					<Text style={styles.username}>
						{completeUser?.username}
					</Text>
				</View>

				{/* profile info */}
				<View style={styles.profileInfoContainer}>
					{/* profile picture */}

					<Image
						source={image ? { uri: image } : images.profile}
						style={styles.profilePhoto}
					/>

					{/* profile details */}
					<View style={styles.profileDetails}>
						<Text style={styles.text}>{completeUser?.name}</Text>

						<Text style={styles.text}>
							Birthday 🎂:{" "}
							{dob.toLocaleString("default", {
								day: "numeric",
								month: "short",
							})}
						</Text>
					</View>
				</View>

				{/* bio */}
				<View style={styles.bioContainer}>
					<Text style={styles.bio}>{completeUser?.bio}</Text>
				</View>

				{/* profile options */}
				<View style={styles.profileOptions}>
					{/* friends */}

					<Button
						title={`Friends: ${completeUser?.friends.length}`}
						type="clear"
						containerStyle={styles.button}
						onPress={handleFriends}
					/>

					{/* posts */}
					<View style={styles.postCount}>
						<Text style={styles.profileOptionsText}>
							{`Posts: ${completeUser?.posts.length}`}
						</Text>
					</View>

					{/* edit */}
					<Button
						onPress={handleEditProfile}
						title="Edit "
						containerStyle={styles.button}
					/>
				</View>

				{/* create post */}
				<View style={styles.newPostContainer}>
					<Button
						onPress={handleNewPost}
						title="Create New Post "
						type="outline"
						containerStyle={styles.newPostButton}
					/>

					<Button
						onPress={() => {
							setRefresh((prev) => !prev);
						}}
						title="Refresh"
						type="clear"
						containerStyle={styles.newPostButton}
					/>
				</View>

				{/* posts */}
				{completeUser &&
					(completeUser.posts.length > 0 ? (
						// <View style={styles.postParent}>
						// 	{completeUser.posts.map((post) => {
						// 		return (
						// 			<Pressable
						// 				style={styles.postContainer}
						// 				key={post.id}
						// 				onPress={() => handlePostItem(post)}>
						// 				<Image
						// 					style={styles.postImage}
						// 					source={
						// 						image
						// 							? { uri: image }
						// 							: images.profile
						// 					}
						// 				/>
						// 			</Pressable>
						// 		);
						// 	})}
						// </View>
						<Posts
							navigation={navigation}
							posts={completeUser.posts}
							allow={allow}
						/>
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
		fontSize: 18,
	},

	container: {
		paddingHorizontal: 10,
	},

	usernameContainer: {
		marginVertical: 20,
	},
	username: {
		fontSize: 28,
		fontWeight: "600",
		color: "black",
		textAlign: "center",
	},

	profileInfoContainer: {
		flexDirection: "row",
		gap: 20,
		alignItems: "center",
	},
	profilePhoto: {
		width: 125,
		height: 125,
		borderRadius: 125 / 2,
	},
	profileDetails: {
		flex: 1,
		gap: 10,
	},

	bioContainer: {
		marginVertical: 20,
	},
	bio: {
		fontSize: 16,
		color: "black",
	},

	profileOptions: {
		marginBottom: 20,
		flexDirection: "row",
		gap: 20,

		justifyContent: "space-between",
	},

	button: {
		flex: 1,
	},
	profileOptionsText: {
		color: "black",

		fontSize: 18,
	},
	postCount: {
		alignItems: "center",
		justifyContent: "center",
		flex: 1,
	},
	newPostContainer: {
		marginTop: 5,
		marginBottom: 15,
		flexDirection: "row",
		justifyContent: "center",
		gap: 20,
	},
	newPostButton: {
		marginHorizontal: 1,
	},
});

export default UserProfile;
