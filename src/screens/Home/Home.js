import { View, Text, Button } from "react-native";
import { Auth } from "aws-amplify";
import { useEffect } from "react";
import { useSetRecoilState } from "recoil";
import { userState } from "../../recoil/atoms/user";

function Home({ navigation }) {
	const setUserDetails = useSetRecoilState(userState);

	useEffect(() => {
		Auth.currentAuthenticatedUser()
			.then(user => {
				setUserDetails({
					id: user.pool.clientId,
					email: user.attributes.email,
					name: user.attributes.name,
				});
			})
			.catch(err => {
				console.log(err);
				navigation.navigate("Login");
			});
	}, []);

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
				title="Login"
				onPress={() => navigation.navigate("Login")}
			/>

			<Button
				title="Profile"
				onPress={() => navigation.navigate("Profile")}
			/>

			<Button
				title="Signup"
				onPress={() => navigation.navigate("Signup")}
			/>
		</View>
	);
}

export default Home;
