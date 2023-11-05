import { View, Text, StyleSheet, Pressable, Image } from "react-native";
import { Button, Icon } from "@rneui/base";
// import { Icon } from "@rneui/themed";
import React, { useState } from "react";
import {
	HandleSteps,
	ImageMetaDetails,
	ProfileModalProps,
	ProfilePictureProps,
} from "../../types";
import {
	ImagePickerResponse,
	MediaType,
	launchCamera,
	launchImageLibrary,
} from "react-native-image-picker";
import Modal from "react-native-modal";
import { images } from "../../../../../assests";

const ProfileModal = ({
	openModal,
	setOpenModal,
	handleCamera,
	handleGallery,
}: ProfileModalProps) => {
	const handleClose = () => {
		setOpenModal(false);
	};

	return (
		<>
			<Modal
				style={styles.modal}
				isVisible={openModal}
				onBackdropPress={handleClose}
				backdropTransitionOutTiming={0}>
				<View style={styles.modalHeadContainer}>
					<Text style={styles.modalHeadText}>
						Select or take new picture
					</Text>
				</View>

				<View style={styles.actionContainer}>
					<Button
						title="Camera"
						icon={{
							name: "camera",
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
			</Modal>
		</>
	);
};

const ProfilePicture = ({
	handlePrev,
	setUserInfo,
	userInfo,
	handleProfileCreate,
}: ProfilePictureProps) => {
	const [openModal, setOpenModal] = useState<boolean>(false);
	const [userUpload, setUserUpload] = useState<string>(
		userInfo.profilePicture,
	);
	const [imageMetaDetails, setImageMetaDetails] = useState<ImageMetaDetails>({
		name: "",
		type: "",
	});

	const handleOpen = () => {
		setOpenModal(true);
	};

	const handleSteps: HandleSteps = (prev = true) => {
		// state update
		if (prev) handlePrev();
		else handleProfileCreate();
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

				setUserInfo((prev) => ({
					...prev,
					profilePicture,
					imageExtension,
					imageType,
				}));

				setUserUpload(profilePicture);
			}
			setOpenModal(false);
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
		<View style={styles.container}>
			<Text style={styles.head}>ProfilePicture</Text>

			<View style={styles.uploadProfileContainer}>
				<Button
					title="Upload Profile Picture"
					onPress={handleOpen}
					type="clear"
				/>

				<Image
					style={styles.image}
					source={
						userUpload.length > 0
							? { uri: userUpload }
							: images.profile
					}
				/>

				<ProfileModal
					openModal={openModal}
					setOpenModal={setOpenModal}
					handleCamera={handleCamera}
					handleGallery={handleGallery}
				/>
			</View>

			<View style={styles.buttonContainer}>
				<Button
					onPress={() => handleSteps()}
					title="Previous"
					type="outline"
					accessibilityLabel="Move to prevoius form step"
					containerStyle={{
						width: 100,
					}}
				/>

				<Button
					onPress={() => handleSteps(false)}
					title="Complete Profile"
					accessibilityLabel="Move to next page to fill details"
					containerStyle={{
						width: 150,
					}}
				/>
			</View>
		</View>
	);
};

const styles = StyleSheet.create({
	container: {
		padding: 10,
	},
	head: {
		color: "black",
		fontSize: 20,
		fontWeight: "500",
	},
	uploadProfileContainer: {
		padding: 10,
		marginBottom: 10,
	},
	image: {
		marginTop: 10,
		width: 350,
		height: 350,
		borderRadius: 350 / 2,
	},
	modal: {
		backgroundColor: "#F1EFEF",
		margin: 0,
		marginTop: "170%",
		flex: 1,
		justifyContent: "flex-start",
		gap: 20,
		paddingVertical: 10,
		paddingHorizontal: 15,
	},
	actionContainer: {
		flexDirection: "row",
		justifyContent: "space-evenly",
	},
	actionItemContainer: {
		width: 150,
		marginHorizontal: 50,
		marginVertical: 10,
	},
	buttonStyle: {
		backgroundColor: "rgba(90, 154, 230, 1)",
		borderColor: "transparent",
		borderWidth: 0,
		borderRadius: 30,
	},
	modalHeadContainer: {},
	modalHeadText: {
		color: "#A8A196",
		fontSize: 18,
		fontWeight: "500",
	},
	buttonContainer: {
		padding: 10,
		flexDirection: "row",
		justifyContent: "space-between",
	},
});

export default ProfilePicture;
