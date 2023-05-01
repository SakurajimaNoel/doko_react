import { StyleSheet } from "react-native";
import { useState } from "react";
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

// aws
import { API } from "aws-amplify";
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
	const [userInput, setUserInput] = useState({
		userName: "",
		dob: new Date(),
		bio: "",
	});
	const userDetails = useRecoilValue(userState);

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
			await API.graphql({
				query: mutations.createProfile,
				variables: {
					input: profileDetails,
				},
			});

			console.log("Successfully created profile");
		} catch (error) {
			console.log("appsync error: failed to create user profile");
			console.log(error);
		}
	}

	const handleSubmit = async () => {
		const profileDetails = {
			id: userDetails.id,
			name: userDetails.name,
			email: userDetails.email,
			userName: userInput.userName,
			dob: userInput.dob.toLocaleTimeString(),
			bio: userInput.bio,
		};

		await createProfile(profileDetails);
	};

	return (
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
	},
});

export default CreateProfile;
