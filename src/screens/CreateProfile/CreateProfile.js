import { StyleSheet, Image, ScrollView } from "react-native";
import { useState, useCallback, useEffect } from "react";
import { useRecoilValue } from "recoil";
import { userState } from "../../recoil/atoms/user";
import "react-native-get-random-values";
import { nanoid } from "nanoid";
import {
	Layout,
	Button,
	Input,
	Text,
	Datepicker,
	Icon,
	Modal,
	Card,
} from "@ui-kitten/components";
import * as ImagePicker from "react-native-image-picker";
import { images } from "../../assests";

import { login } from "../../backend connectors/auth/auth";

// aws
import { API, graphqlOperation, Storage } from "aws-amplify";
//import * as mutations from "../../graphql/mutations";
//import * as queries from "../../graphql/queries";

const user = {
	bio: "this is rohannn",
	dob: "2002-10-12",
	email: "vermarohan031@gmail.com",
	friends: null,
	id: "1l42rcm392giebgt3l1i49pf88",
	name: "rohan",
	posts: null,
	profilePicture: "IfjAqZRxjXG7jmRNJqOBz",
	username: "Agjdhd",
};

const TextLabel = ({ children }) => {
	return (
		<Text style={{ marginBottom: 5 }} category="h6">
			{children}
		</Text>
	);
};

const CalendarIcon = (props) => <Icon {...props} name="calendar" />;

const CreateProfile = ({ navigation }) => {
	const [pickerResponse, setPickerResponse] = useState(null);
	const [visible, setVisible] = useState(false);
	const [userInput, setUserInput] = useState({
		userName: "asdf",
		dob: new Date(),
		bio: "this is rohannn",
		profilePicture: "",
	});
	const userDetails = useRecoilValue(userState);

	useEffect(() => {
		const uri = pickerResponse?.assets && pickerResponse.assets[0].uri;
		if (uri) {
			setVisible(false);
			setUserInput((prev) => ({
				...prev,
				profilePicture: uri,
			}));
		}
	}, [pickerResponse]);

	const onImageLibraryPress = useCallback(() => {
		const options = {
			selectionLimit: 1,
			mediaType: "photo",
			includeBase64: false,
		};
		ImagePicker.launchImageLibrary(options, setPickerResponse);
	}, []);

	const onCameraPress = useCallback(() => {
		const options = {
			saveToPhotos: false,
			mediaType: "photo",
			includeBase64: false,
		};
		ImagePicker.launchCamera(options, setPickerResponse);
	}, []);

	const handleInput = (type, value) => {
		setUserInput((prev) => {
			return {
				...prev,
				[type]: value,
			};
		});
	};

	async function createProfile(profileDetails) {
		try {
			if (userInput.profilePicture) {
				const response = await fetch(userInput.profilePicture);
				const blob = await response.blob();
				const key = nanoid();
				await Storage.put(key, blob, {
					// contentType: "image/jpeg", // contentType is optional
				});

				profileDetails = { ...profileDetails, profilePicture: key };
			}

			console.log(profileDetails);
			const profile = await API.graphql({
				query: mutations.createProfile,
				variables: profileDetails,
			});

			console.log("Successfully created profile");
			console.log(profile);
		} catch (error) {
			console.log("appsync error: failed to create user profile");
			console.log(error);
		}
	}

	const handleSubmit = async () => {
		// let userDetails = {
		// 	id: nanoid(),
		// 	name: "amit69",
		// 	email: "amit69@amit69.com",
		// }; // remove after navigation change

		let dob = userInput.dob;
		dob.setDate(dob.getDate() + 1);

		dob = dob.toISOString();
		dob = dob.substr(0, 10);

		const profileDetails = {
			id: userDetails?.id,
			name: userDetails?.name,
			email: userDetails?.email,
			username: userInput.userName,
			dob,
			bio: userInput.bio,
		};

		await createProfile(profileDetails);
	};

	return (
		<Layout level="3" style={styles.container}>
			<Image
				style={styles.image}
				source={
					userInput.profilePicture
						? { uri: userInput.profilePicture }
						: images.img
				}
			/>
			<Button
				appearance="ghost"
				style={{
					marginVertical: 5,
				}}
				onPress={() => setVisible(true)}>
				Upload Profile Picture
			</Button>
			<Modal
				animationType="fade"
				visible={visible}
				backdropStyle={styles.backdrop}
				onBackdropPress={() => setVisible(false)}>
				<Card style={styles.modal}>
					<Button
						accessoryLeft={<Icon name="camera-outline" />}
						style={styles.modalButton}
						onPress={onCameraPress}
						appearance="outline"
						status="control">
						Open Camera
					</Button>
					<Button
						accessoryLeft={<Icon name="image-outline" />}
						appearance="outline"
						status="control"
						style={styles.modalButton}
						onPress={onImageLibraryPress}>
						Open gallery
					</Button>
				</Card>
			</Modal>

			<Input
				value={userInput.userName}
				onChangeText={(string) => handleInput("userName", string)}
				placeholder="User Name..."
				label={<TextLabel>User Name</TextLabel>}
				size="medium"
			/>

			<Input
				value={userInput.bio}
				onChangeText={(string) => handleInput("bio", string)}
				placeholder="Bio..."
				label={<TextLabel>Bio</TextLabel>}
				multiline={true}
				textStyle={styles.inputTextStyle}
			/>

			<Datepicker
				label={<TextLabel>Date of Birth</TextLabel>}
				placeholder="Pick DOB..."
				min={new Date(null)}
				date={userInput.dob}
				onSelect={(nextDate) => handleInput("dob", nextDate)}
				accessoryRight={CalendarIcon}
			/>
			<Text>{userInput?.dob?.toDateString()}</Text>

			<Button style={styles.button} onPress={handleSubmit}>
				Complete profile
			</Button>
		</Layout>
	);
};

const styles = StyleSheet.create({
	container: {
		flex: 1,
		paddingVertical: 20,
		paddingHorizontal: 10,
	},
	inputTextStyle: {
		minHeight: 64,
	},
	button: {
		marginTop: 30,
		// marginBottom: 15,
	},
	image: {
		marginTop: 10,
		width: 390,
		height: 300,
		borderRadius: 100,
	},
	backdrop: {
		backgroundColor: "rgba(0, 0, 0, 0.8)",
	},
	modal: {
		width: 250,
		height: 200,
		flex: 1,
		justifyContent: "space-evenly",
		borderRadius: 20,
		rowGap: 10,
	},
	modalButton: {
		marginBottom: 20,
	},
});

export default CreateProfile;
