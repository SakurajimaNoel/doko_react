import { View, Text, StyleSheet } from "react-native";
import React, { useContext } from "react";
import { UpdateProfileImageProps } from "../../types";
import { Button, Image } from "@rneui/base";

import { images } from "../../../../../assests";
import { getS3Obj } from "../../../../../Connectors/auth/aws";
import {
	UserContext,
	UserDispatchContext,
} from "../../../../../context/userContext";
import { UserActionKind } from "../../../../../context/types";

export default function UpdateProfileImage({
	profileImage,
}: UpdateProfileImageProps) {
	const user = useContext(UserContext);
	const userDispatch = useContext(UserDispatchContext);

	const handleDelete = () => {
		const s3 = getS3Obj();
		if (!s3) return;

		if (!user) return;

		let key = user.profilePicture;

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

				if (!userDispatch) return;

				userDispatch({
					type: UserActionKind.UPDATE,
					payload: {
						profilePicture: "",
					},
				});
			}
		});
	};

	return (
		<View style={styles.container}>
			<Text style={styles.text}>UpdateProfileImage</Text>
			<Image
				source={
					profileImage.length > 0
						? { uri: profileImage }
						: images.profile
				}
				style={{ width: 200, height: 200 }}
			/>

			<Button
				title="Delete Profile Picture"
				type="clear"
				titleStyle={{
					color: "red",
				}}
				containerStyle={{
					borderWidth: 1,
					borderColor: "red",
				}}
			/>
		</View>
	);
}

const styles = StyleSheet.create({
	container: {
		flex: 1,
		gap: 10,
		marginBottom: 10,
	},
	text: {
		color: "black",
	},
});
