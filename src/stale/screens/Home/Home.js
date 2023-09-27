import { View, Text, Button } from "react-native";
// import { Auth } from "aws-amplify";
// import { useEffect } from "react";
// import { useSetRecoilState } from "recoil";
// import { userState } from "../../recoil/atoms/user";

function Home({ navigation }) {
	// const setUserDetails = useSetRecoilState(userState);

	return (
		<View
			style={{
				flex: 1,
				alignItems: "center",
				justifyContent: "space-between",
				backgroundColor: "#010101",
			}}>
			<Text>Welcome to Dokii!!</Text>

			<Button
				title="Create Profile"
				onPress={() => navigation.navigate("CreateUserProfile")}
			/>

			<Button
				title="Send Req"
				onPress={() => navigation.navigate("SendFriendRequest")}
			/>

			<Button
				title="View Req"
				onPress={() => navigation.navigate("ViewFriendRequest")}
			/>
		</View>
	);
}

export default Home;
