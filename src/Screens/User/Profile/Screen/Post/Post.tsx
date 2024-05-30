import {
	View,
	Text,
	StyleSheet,
	TextInput,
	ScrollView,
	Pressable,
	Dimensions,
} from "react-native";
import React, { useContext, useEffect, useRef, useState } from "react";
import { Button, Image } from "@rneui/base";
import { images } from "../../../../../assests";
import {
	Asset,
	ImagePickerResponse,
	MediaType,
	launchCamera,
	launchImageLibrary,
} from "react-native-image-picker";
import { UserContext } from "../../../../../context/userContext";
import { useMutation } from "@apollo/client";
import { createPost } from "../../../../../Connectors/graphql/mutation/createPost";

import "react-native-get-random-values";
import { nanoid } from "nanoid";
import { getS3Obj } from "../../../../../Connectors/auth/aws";
import { S3 } from "aws-sdk";
import { ManagedUpload } from "aws-sdk/clients/s3";
import { PostProps } from "../../types";

const { width, height } = Dimensions.get("window");

const Post = ({ navigation }: PostProps) => {
	const user = useContext(UserContext);

	const scrollRef = useRef<ScrollView>(null);
	const [postImages, setPostImages] = useState<Asset[] | null>(null);
	const [errorMessage, setErrorMessage] = useState<string | null>(null);
	const [message, setMessage] = useState<string | null>(null);
	const [caption, setCaption] = useState<string>();
	const [imageUpload, setImageUpload] = useState<boolean>(false);

	const [createUserPost, { data, loading, error }] = useMutation(createPost, {
		context: {
			headers: {
				Authorization: "Bearer " + user?.accessToken,
			},
		},
	});

	useEffect(() => {
		if (data) {
			console.log("Profile created");
			setErrorMessage(null);

			setMessage("post created");
			setImageUpload(false);
			navigation.goBack();
		}

		if (error) {
			console.error("error creating post", error);
			setErrorMessage(error.message);
		}
	}, [data, error]);

	const handleGallery = async () => {
		let mediaType = "photo" as MediaType;
		const options = {
			mediaType,
			selectionLimit: 10,
		};

		const result = await launchImageLibrary(options);

		if (result.assets) {
			scrollRef.current?.scrollTo({
				x: 0,
				animated: true,
			});
			setPostImages(result.assets);
		}
	};

	// update graph
	const hanldeUpdateGraph = (keys: string[]) => {
		const variables = {
			input: [
				{
					caption,
					content: keys,
					createdBy: {
						connect: {
							where: {
								node: {
									id: user?.username,
								},
							},
						},
					},
					likes: 0,
				},
			],
		};

		createUserPost({ variables });
	};

	const createPromise = (image: Asset, s3: S3) => {
		return new Promise(async (resolve, reject) => {
			let { uri: picture, fileName, type: contentType } = image;

			if (picture && fileName && contentType) {
				let imageName = fileName;
				let img: string[] = imageName.split(".");
				let imageExtension = img[img.length - 1];

				// Ensure user object is defined
				if (!user || !user.username) {
					reject("Invalid user data");
					return;
				}

				let key = `${
					user?.username
				}/posts/${nanoid()}.${imageExtension}`;
				let bucketName = "dokiuserprofile";

				const response = await fetch(picture);
				const blob = await response.blob();

				let params = {
					Bucket: bucketName,
					Key: key,
					Body: blob,
					ContentType: contentType,
				};

				s3.upload(
					params,
					(err: Error, data: ManagedUpload.SendData) => {
						if (err) {
							console.error("Error uploading image: ", err);
							reject("image can't be uploaded");
						} else {
							console.log(
								"Image uploaded successfully. Location:",
								data.Key,
							);
							resolve(data.Key);
						}
					},
				);
			} else {
				reject("invalid image data");
			}
		});
	};

	// s3 post image uploads
	const handleUploadImage = async () => {
		const s3 = getS3Obj();
		if (!s3) {
			setMessage(null);
			setErrorMessage("Can't create post right now");
			return;
		}
		try {
			let imagePromises = postImages?.map((img) =>
				createPromise(img, s3),
			);
			if (imagePromises) {
				let results = await Promise.allSettled(imagePromises);
				let fulfilledKeys = results
					.filter((result) => result.status === "fulfilled")
					.map((result) => String(result.value));
				console.log("Fulfilled image keys:", fulfilledKeys.length);

				hanldeUpdateGraph(fulfilledKeys);
			}
		} catch (error) {
			console.error("Error handling image uploads:", error);
			setErrorMessage("Error handling image uploads");
		}
	};

	const handleCreatePost = () => {
		if (!caption && (!postImages || postImages.length === 0)) {
			console.log("nothing");
			setErrorMessage("Invalid post details");
			return;
		}

		setImageUpload(true);
		handleUploadImage();
	};

	return (
		<ScrollView>
			<View style={styles.container}>
				{/* image container */}
				<View style={styles.imageContainer}>
					<ScrollView
						ref={scrollRef}
						horizontal
						pagingEnabled
						showsHorizontalScrollIndicator={false}
						contentContainerStyle={{
							flexGrow: 1,
						}}>
						{postImages &&
							postImages.map((image) => {
								return (
									<View key={image.uri} style={styles.image}>
										<Image
											style={styles.image}
											source={{ uri: image.uri }}
										/>
									</View>
								);
							})}

						{(!postImages || postImages.length < 10) && (
							<View style={styles.imageSelect}>
								<Button
									onPress={handleGallery}
									title="Select Images "
									type="clear"
									disabled={imageUpload || loading}
								/>
							</View>
						)}
					</ScrollView>
				</View>

				{/* caption container */}
				<View style={styles.captionContainer}>
					<TextInput
						style={styles.captionText}
						multiline={true}
						numberOfLines={4}
						placeholder="Caption here..."
						placeholderTextColor="#7F8487"
						onChangeText={setCaption}
						editable={!imageUpload && !loading}
					/>
				</View>

				{/* create post container */}
				<View style={styles.postContainer}>
					<Button
						title="Create Post"
						disabled={imageUpload || loading}
						loading={imageUpload || loading}
						loadingProps={{
							color: "#1B75D0",
						}}
						onPress={handleCreatePost}
					/>
				</View>

				<View style={styles.infoContainer}>
					{errorMessage && (
						<Text style={styles.error}>Error: {errorMessage}</Text>
					)}
					{message && (
						<Text style={styles.message}>Success: {message}</Text>
					)}
				</View>
			</View>
		</ScrollView>
	);
};

const styles = StyleSheet.create({
	container: {
		padding: 20,
		flex: 1,
		gap: 10,
	},
	imageContainer: {
		borderWidth: 1,
		height: 300,
	},
	imageParent: {
		width: width - 42,
		height: "100%",
	},

	image: {
		width: width - 42,
		height: "100%",
		resizeMode: "contain",
	},
	imageSelect: {
		width: width - 42,
		justifyContent: "center",
	},
	captionContainer: {},
	captionText: {
		borderWidth: 1,
		padding: 10,
		color: "#413F42",
		fontWeight: "500",
	},
	postContainer: {
		marginTop: 10,
	},
	infoContainer: {
		marginTop: 10,
	},
	error: {
		color: "red",
		fontSize: 12,
		textAlign: "center",
	},
	message: {
		color: "green",
		fontSize: 12,
		textAlign: "center",
	},
});

export default Post;
