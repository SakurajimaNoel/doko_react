import { StyleSheet, Image, ScrollView } from "react-native";
import { useState, useCallback } from "react";
import { useRecoilValue } from "recoil";
import { userState } from "../../recoil/atoms/user";
import {
	Layout,
	Button,
	Input,
	Text,
	Datepicker,
	Icon,
} from "@ui-kitten/components";
import * as ImagePicker from "react-native-image-picker";
import { images } from "../../assests";

// aws
import { API, graphqlOperation } from "aws-amplify";
import * as mutations from "../../graphql/mutations";
import * as queries from "../../graphql/queries";

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
	const [userInput, setUserInput] = useState({
		userName: "asdf",
		dob: new Date(),
		bio: "this is rohannn",
	});
	const userDetails = useRecoilValue(userState);

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
			saveToPhotos: true,
			mediaType: "photo",
			includeBase64: false,
		};
		ImagePicker.launchCamera(options, setPickerResponse);
	}, []);

	const uri = pickerResponse?.assets && pickerResponse.assets[0].uri;
	console.log(pickerResponse);

	const handleInput = (type, value) => {
		setUserInput((prev) => {
			return {
				...prev,
				[type]: value,
			};
		});
	};

	async function createProfile(profileDetails) {
		console.log(profileDetails);
		try {
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
		var month = userInput.dob.getUTCMonth() + 1; //months from 1-12
		var day = userInput.dob.getUTCDate() + 1;
		var year = userInput.dob.getUTCFullYear();
		const dob =
			year +
			"-" +
			(month < 10 ? `0${month}` : month) +
			"-" +
			(day < 10 ? `0${day}` : day);
		const profileDetails = {
			id: userDetails.id,
			name: userDetails.name,
			email: userDetails.email,
			username: userInput.userName,
			dob,
			bio: userInput.bio,
		};
		await createProfile(profileDetails);
	};

	return (
		<ScrollView>
			<Layout level="3" style={styles.container}>
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

				<Button style={styles.button} onPress={onCameraPress}>
					Open Camera
				</Button>
				<Button style={styles.button} onPress={onImageLibraryPress}>
					Open gallery
				</Button>

				<Image
					style={styles.image}
					source={uri ? { uri } : images.img}
				/>

				<Button style={styles.button} onPress={handleSubmit}>
					Complete profile
				</Button>
			</Layout>
		</ScrollView>
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
	},
	image: {
		marginTop: 30,
		width: 390,
		height: 300,
	},
});

export default CreateProfile;
