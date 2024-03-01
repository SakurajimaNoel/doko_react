import { View, Text, StyleSheet } from "react-native";
import React, { useContext, useEffect, useState } from "react";
import {
	ProfileImageDetails,
	ProfileImageModalProps,
	UpdateProfileImageProps,
} from "../../../../types";
import { Button, Image } from "@rneui/base";

import { images } from "../../../../../../../assests";
import { getS3Obj } from "../../../../../../../Connectors/auth/aws";
import {
	UserContext,
	UserDispatchContext,
} from "../../../../../../../context/userContext";
import { UserActionKind } from "../../../../../../../context/types";
import {
	ImagePickerResponse,
	MediaType,
	launchCamera,
	launchImageLibrary,
} from "react-native-image-picker";
import { ManagedUpload } from "aws-sdk/clients/s3";
import { useMutation } from "@apollo/client";
import { updateProfileImage } from "../../../../../../../Connectors/graphql/mutation/updateProfileImage";

import { Overlay } from "@rneui/base";

function ProfileImageModal({
	toggleModal,
	openModal,
	handleDelete,
	setError,
	setMessage,
	navigation,
}: ProfileImageModalProps) {
	const user = useContext(UserContext);
	const userDispatch = useContext(UserDispatchContext);

	const [userUpload, setUserUpload] = useState<string | null>(null);
	const [profileImageDetails, setProfileImageDetails] =
		useState<ProfileImageDetails | null>(null);

	const [updating, setUpdating] = useState(false);

	const [updateImage, { loading, data, error: updateError }] = useMutation(
		updateProfileImage,
		{
			context: {
				headers: {
					Authorization: "Bearer " + user?.accessToken,
				},
			},
		},
	);

	useEffect(() => {
		setUpdating(false);

		if (data) {
			if (!data) return;

			setError(null);
			setMessage("Successfully updated profile picture");
			let key = data.updateUsers.users[0].profilePicture;

			if (!userDispatch) return;

			userDispatch({
				type: UserActionKind.UPDATE,
				payload: {
					profilePicture: key,
				},
			});

			navigation.goBack();
		}

		if (updateError) {
			setMessage(null);
			setError(updateError.message);
		}
	}, [data, updateError]);

	const updateGraph = (key: string) => {
		if (!user) return;

		let variables = {
			where: {
				id: user.username,
			},
			update: {
				profilePicture: key,
			},
		};

		updateImage({ variables });
	};

	const uploadProfileImage = async () => {
		if (!userUpload || !profileImageDetails) {
			setMessage(null);
			setError("No image selected");
			return;
		}

		const s3 = getS3Obj();
		if (!s3) {
			setMessage(null);
			setError("Can't upload image right now");
			return;
		}

		setUpdating(true);

		const profilePicture = profileImageDetails.profilePicture;
		let key = `${user?.username}/profile.${profileImageDetails.imageExtension}`;

		let bucketName = "dokiuserprofile";

		const response = await fetch(profilePicture);
		const blob = await response.blob();

		let params = {
			Bucket: bucketName,
			Key: key,
			Body: blob,
			ContentType: profileImageDetails.imageType,
		};

		handleDelete(false);
		s3.upload(params, (err: Error, data: ManagedUpload.SendData) => {
			if (err) {
				console.error("Error uploading image: ", err);
				setError("Error updating profile image");
				setMessage(null);
				setUpdating(false);
			} else {
				console.log("Image uploaded successfully. Location:", data.Key);

				updateGraph(key);
			}
		});
	};

	const handleState = (result: ImagePickerResponse) => {
		if (result.assets) {
			let profile = result.assets[0].uri;
			let { fileName, type } = result.assets[0];

			if (profile && fileName && type) {
				let imageName = fileName;
				let img: string[] = imageName.split(".");
				let imageExtension = img[img.length - 1];

				let imageType: string = type;
				let profilePicture: string = profile;

				setUserUpload(profilePicture);
				setProfileImageDetails({
					profilePicture,
					imageExtension,
					imageType,
				});
			}
		}
	};

	const handleCamera = async () => {
		let mediaType = "photo" as MediaType;
		const options = {
			mediaType,
		};

		const result = await launchCamera(options);
		handleState(result);
	};

	const handleGallery = async () => {
		let mediaType = "photo" as MediaType;
		const options = {
			mediaType,
		};

		const result = await launchImageLibrary(options);
		handleState(result);
	};

	return (
		<Overlay
			isVisible={openModal}
			onBackdropPress={() => {
				if (updating) return;

				toggleModal();
			}}
			overlayStyle={styles.modalContainer}
			backdropStyle={styles.modalBackdrop}>
			<Text style={styles.modalTextHead}>Update Profile Picture</Text>

			{/* image select options */}
			<View style={styles.actionContainer}>
				<Button
					title="Camera"
					icon={{
						name: "camera",
						type: "font-awesome",
						size: 18,
						color: "white",
					}}
					iconContainerStyle={{
						marginRight: 10,
					}}
					titleStyle={{
						fontWeight: "700",
					}}
					buttonStyle={styles.buttonStyle}
					containerStyle={styles.actionItemContainer}
					onPress={handleCamera}
				/>

				<Button
					title="Files"
					icon={{
						name: "folder",
						type: "font-awesome",
						size: 18,
						color: "white",
					}}
					iconContainerStyle={{ marginRight: 10 }}
					titleStyle={{
						fontWeight: "700",
					}}
					buttonStyle={styles.buttonStyle}
					containerStyle={styles.actionItemContainer}
					onPress={handleGallery}
				/>
			</View>

			{/* image placeholder */}
			<View style={styles.imageContainer}>
				<Image
					style={styles.image}
					source={userUpload ? { uri: userUpload } : images.profile}
				/>
			</View>

			{/* profile image options */}
			<View style={styles.options}>
				<Button
					type="outline"
					title="Cancel"
					onPress={toggleModal}
					containerStyle={styles.optionsButton}
					disabled={updating}
				/>

				<Button
					title="Update"
					containerStyle={styles.optionsButton}
					disabled={updating || !userUpload}
					loading={updating}
					onPress={uploadProfileImage}
				/>
			</View>
		</Overlay>
	);
}

export default function UpdateProfileImage({
	profileImage,
	navigation,
}: UpdateProfileImageProps) {
	const user = useContext(UserContext);
	const userDispatch = useContext(UserDispatchContext);

	const [openModal, setOpenModal] = useState<boolean>(false);

	const [deleting, setDeleting] = useState<boolean>(false);
	const [error, setError] = useState<string | null>(null);
	const [message, setMessage] = useState<string | null>(null);

	const [updateImage, { loading, data, error: updateError }] = useMutation(
		updateProfileImage,
		{
			context: {
				headers: {
					Authorization: "Bearer " + user?.accessToken,
				},
			},
		},
	);

	useEffect(() => {
		setDeleting(false);

		if (data) {
			if (!data) return;

			setError(null);
			setMessage("Successfully deleted profile picture");

			if (!userDispatch) return;

			userDispatch({
				type: UserActionKind.UPDATE,
				payload: {
					profilePicture: "",
				},
			});

			navigation.goBack();
		}

		if (updateError) {
			setMessage(null);
			setError(updateError.message);
		}
	}, [data, updateError]);

	const updateGraph = () => {
		if (!user) return;

		let variables = {
			where: {
				id: user.username,
			},
			update: {
				profilePicture: "",
			},
		};

		updateImage({ variables });
	};

	const toogleModal = () => {
		setOpenModal((prev) => !prev);
	};

	const handleDelete = (show = true) => {
		const s3 = getS3Obj();
		if (!s3) return;

		if (!user) return;

		if (show) setDeleting(true);

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

				if (show) {
					setDeleting(false);
					setMessage(null);
					setError(err.message);
				}
			} else {
				console.log("Item deleted successfully:", data);

				if (show) {
					setError(null);
					setMessage("Successfully removed profile photo");

					updateGraph();
				}
			}
		});
	};

	return (
		<View style={styles.container}>
			<View style={styles.contentContainer}>
				<Image
					source={
						profileImage.length > 0
							? { uri: profileImage }
							: images.profile
					}
					style={styles.img}
				/>

				<View style={styles.buttonContainer}>
					<Button
						title="Update Profile Picture"
						type="outline"
						containerStyle={styles.button}
						disabled={deleting}
						onPress={toogleModal}
					/>

					<Button
						title="Remove Profile Picture"
						type="outline"
						titleStyle={{
							color: "red",
						}}
						containerStyle={{
							...styles.button,
						}}
						buttonStyle={{
							borderColor: "red",
						}}
						onPress={() => handleDelete()}
						loading={deleting}
						disabled={deleting}
						loadingProps={{
							color: "red",
						}}
					/>
				</View>
			</View>

			{error && <Text style={styles.error}>Error: {error}</Text>}
			{message && <Text style={styles.message}>Success: {message}</Text>}

			<ProfileImageModal
				toggleModal={toogleModal}
				openModal={openModal}
				handleDelete={handleDelete}
				setError={setError}
				setMessage={setMessage}
				navigation={navigation}
			/>
		</View>
	);
}

const styles = StyleSheet.create({
	container: {
		backgroundColor: "hsla(0, 100%, 0%, 0.2)",
		padding: 10,
		borderRadius: 5,
		marginBottom: 20,
	},
	contentContainer: {
		flex: 1,
		flexDirection: "row",
		gap: 20,
		marginBottom: 10,
		justifyContent: "center",
	},
	buttonContainer: {
		flex: 1,
		justifyContent: "center",
		gap: 10,
	},
	img: {
		width: 100,
		height: 100,
		borderRadius: 100 / 2,
	},
	button: {},
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
	modalContainer: {
		backgroundColor: "hsla(0, 100%, 100%, 1)",
		width: "90%",
		// aspectRatio: "4/5",
	},
	modalBackdrop: {
		backgroundColor: "hsla(0, 100%, 0%, 0.7)",
	},
	modalTextHead: {
		color: "black",
		fontSize: 20,
		fontWeight: "bold",
	},
	actionContainer: {
		flexDirection: "row",
		justifyContent: "space-evenly",
		marginVertical: 10,
	},
	actionItemContainer: {
		width: 150,
		marginHorizontal: 50,
		marginVertical: 10,
	},
	buttonStyle: {
		backgroundColor: "hsla(210, 100%, 50%, 0.7)",
		borderColor: "transparent",
		borderWidth: 0,
		borderRadius: 30,
	},

	imageContainer: {
		alignItems: "center",
	},
	image: {
		width: 250,
		height: 250,
		borderRadius: 250 / 2,
	},
	options: {
		marginTop: 20,
		flexDirection: "row",
		justifyContent: "space-between",
	},
	optionsButton: {
		width: "40%",
	},
});
