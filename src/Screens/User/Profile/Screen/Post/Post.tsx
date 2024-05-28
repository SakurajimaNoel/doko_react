import {
	View,
	Text,
	StyleSheet,
	TextInput,
	ScrollView,
	Pressable,
	Dimensions,
} from "react-native";
import React, { useRef, useState } from "react";
import { Button, Image } from "@rneui/base";
import { images } from "../../../../../assests";
import {
	Asset,
	ImagePickerResponse,
	MediaType,
	launchCamera,
	launchImageLibrary,
} from "react-native-image-picker";

const { width, height } = Dimensions.get("window");

const Post = () => {
	const scrollRef = useRef<ScrollView>(null);
	const [postImages, setPostImages] = useState<Asset[] | null>(null);

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

	return (
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
				/>
			</View>

			{/* create post container */}
			<View style={styles.postContainer}>
				<Button title="Create Post" />
			</View>
		</View>
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
		borderWidth: 1,
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
});

export default Post;
