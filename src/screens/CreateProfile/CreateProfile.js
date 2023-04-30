import { View, Text } from "react-native";
import { useState } from "react";
import { useRecoilValue } from "recoil";
import { userState } from "../../recoil/atoms/user";

const CreateProfile = ({ navigation }) => {
	const [userInput, setUserInput] = useState({
		userName: "",
		dob: "",
		bio: "",
	});

	const userDetails = useRecoilValue(userState);

	return (
		<View>
			<Text>Create Profile!!</Text>
		</View>
	);
};

// const styles = StyleSheet.create({
// 	container: {
// 		flex: 1,
// 		gap: 30,
// 		paddingVertical: 30,
// 		paddingHorizontal: 30,
// 		backgroundColor: "#010101",
// 	},
// 	inputContainer: {
// 		backgroundColor: "white",
// 	},
// 	input: {
// 		marginLeft: 8,
// 		fontSize: 20,
// 		color: "black",
// 		fontWeight: "500",
// 	},
// 	link: { color: "lightpink" },
// });

export default CreateProfile;
