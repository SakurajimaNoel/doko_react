import { View, Text, StyleSheet, Image, Button } from "react-native";
import React, { useContext, useEffect, useRef, useState } from "react";
import { UserContext } from "../../../../context/userContext";
import { getAWSCredentials } from "../../../../Connectors/auth/aws";
import * as AWS from "aws-sdk";

const UserProfile = () => {
	const user = useContext(UserContext);
	const [image, setImage] = useState<string | null>(null);
	const s3Ref = useRef<AWS.S3 | null>(null);

	useEffect(() => {
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
				s3Ref.current = s3;

				let bucketName = "dokiuserprofile";
				let key = user?.user?.profilePicture;

				const params = {
					Bucket: bucketName,
					Key: key,
					Expires: 60,
				};

				s3.getSignedUrl("getObject", params, (err, url) => {
					if (err) {
						console.error("Error generating signed URL:", err);
						return;
					}

					// Use this signed URL in your React Native component
					setImage(url);
				});
			}
		});
	});

	const handleDelete = () => {
		const s3 = s3Ref.current;
		if (!s3) return;

		if (!user || !user.user) return;

		let key = user.user.profilePicture;

		if (typeof key !== "string") return;

		const params = {
			Bucket: "dokiuserprofile",
			Key: key,
		};

		// Delete the item from S3
		s3.deleteObject(params, (err, data) => {
			if (err) {
				console.error("Error deleting item:", err);
			} else {
				console.log("Item deleted successfully:", data);

				// @ts-expect-error
				user.setUser((prev) => {
					return {
						...prev,
						profilePicture: "",
					};
				});
			}
		});
	};

	if (!user || !user.user) {
		handleLogout();
		return (
			<>
				<Text>Not Authenticated</Text>
			</>
		);
	}

	return (
		<View>
			<Text style={styles.text}>UserProfile</Text>

			<Text style={styles.text}>{user.user.displayUsername}</Text>

			<Text style={styles.text}>{user.user.email}</Text>

			<Text style={styles.text}>{user.user.name}</Text>

			{image && (
				<>
					<Image
						source={{ uri: image }}
						style={{ width: 200, height: 200 }}
					/>

					<Button
						onPress={handleDelete}
						title="Delete profile picture"
						color="#841584"
					/>
				</>
			)}
		</View>
	);
};

const styles = StyleSheet.create({
	text: {
		color: "black",
		fontSize: 22,
		marginVertical: 10,
	},
});

export default UserProfile;
function handleLogout() {
	throw new Error("Function not implemented.");
}
