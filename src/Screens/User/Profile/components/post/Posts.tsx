import {
	ActivityIndicator,
	Pressable,
	StyleSheet,
	Text,
	View,
} from "react-native";
import React, { useEffect, useState } from "react";
import { Post, PostsProps } from "../../types";
import { Button, Image } from "@rneui/base";
import { images } from "../../../../../assests/index";
import { getS3PresignedUrl } from "../../../../../Connectors/helpers/s3";

const LIMIT = 10;

const Posts = ({ navigation, posts, allow }: PostsProps) => {
	const [visiblePosts, setVisiblePosts] = useState(() =>
		posts.slice(0, LIMIT),
	);
	const [postImages, setPostImages] = useState<string[]>([]);

	useEffect(() => {
		if (!allow) return;
		(async function () {
			let promises = visiblePosts.map((post) => {
				return createPromise(post.content[0]);
			});

			if (promises) {
				let imageUrls = await Promise.allSettled(promises);
				let urls: string[] = [];

				imageUrls.forEach((url) => {
					if (url.status === "fulfilled") {
						urls.push(url.value as string);
					} else urls.push("");
				});

				setPostImages(urls);
			}
		})();
	}, [allow]);

	const createPromise = (key: string) => {
		return new Promise(async (resolve, reject) => {
			try {
				const url = await getS3PresignedUrl(key);
				resolve(url);
			} catch (err) {
				reject("can't generate image url");
			}
		});
	};

	const addPostsImages = async (posts: Post[]) => {
		let promises = posts.map((post) => createPromise(post.content[0]));

		if (promises) {
			let imageUrls = await Promise.allSettled(promises);
			let urls: string[] = [];

			imageUrls.forEach((url) => {
				if (url.status === "fulfilled") {
					urls.push(url.value as string);
				} else {
					console.log("getting empty urls");
					urls.push("");
				}
			});

			setPostImages((prev) => [...prev, ...urls]);
		}
	};

	const loadMore = () => {
		let morePosts = posts.slice(
			visiblePosts.length,
			visiblePosts.length + LIMIT,
		);
		addPostsImages(morePosts);
		setVisiblePosts((prev) => [...prev, ...morePosts]);
	};

	const handlePostItem = (post: Post) => {
		navigation.navigate("Profile", {
			screen: "PostItem",
			params: {
				id: post.id,
				caption: post.caption,
				content: post.content,
				likes: post.likes,
			},
		});
	};

	return (
		<>
			<View style={styles.postParent}>
				{visiblePosts.map((post, ind) => {
					let url = postImages[ind];
					return (
						<View style={styles.postContainer} key={post.id}>
							<Image
								style={styles.postImage}
								source={url ? { uri: url } : images.profile}
								onPress={() => handlePostItem(post)}
								onLongPress={() => {
									console.log(url);
								}}
							/>
						</View>
					);
				})}
			</View>

			{posts.length > visiblePosts.length && (
				<View style={styles.loadMore}>
					<Button type="clear" onPress={loadMore}>
						Load more
					</Button>
				</View>
			)}
		</>
	);
};

export default Posts;

const styles = StyleSheet.create({
	postParent: {
		flexDirection: "row",
		flexWrap: "wrap",
		gap: 0,
		marginVertical: 10,
	},
	postImage: {
		width: "100%",
		height: "100%",
	},
	postContainer: {
		// marginVertical: 10,
		height: 125,
		width: "33.3%",
		borderWidth: 1.5,

		justifyContent: "space-between",
		borderColor: "#FF9B50",
	},
	postText: {
		color: "black",
	},
	loadMore: {
		marginVertical: 10,
	},
});
