import { useMutation } from "@apollo/client";
import { userCreateRequest } from "../../../../graphql/mutations/userSendRequest";
import { View, StyleSheet } from "react-native";
import { useState, useRef } from "react";
import { Button, Input, Text, Layout } from "@ui-kitten/components";

const TextLabel = ({ children }) => {
	return (
		<Text style={{ marginBottom: 5 }} category="h6">
			{children}
		</Text>
	);
};

function SendReq({ navigation }) {
	const [sendFriendReq, { data, error, loading }] =
		useMutation(userCreateRequest);

	const [userInput, setUserInput] = useState({
		myId: "",
		friendId: "",
	});

	const relationRef = useRef(0);

	const handleInput = (value, isFriend = false) => {
		setUserInput((prev) => {
			if (isFriend) {
				return { ...prev, friendId: value };
			} else return { ...prev, myId: value };
		});
	};

	const handleSendReq = () => {
		const variables = {
			where: {
				id: userInput.myId,
			},
			update: {
				friends: [
					{
						connect: [
							{
								edge: {
									requestedBy: userInput.myId,
									status: "PENDING",
								},
								where: {
									node: {
										id: userInput.friendId,
									},
								},
							},
						],
					},
				],
			},
		};

		sendFriendReq({ variables: variables });
	};

	if (loading) {
		return (
			<View
				style={{
					flex: 1,
					alignItems: "center",
					justifyContent: "space-between",
					backgroundColor: "#010101",
				}}>
				<Text>Sending Request {":)"}</Text>
			</View>
		);
	}

	if (error) {
		return (
			<View
				style={{
					flex: 1,
					alignItems: "center",
					justifyContent: "space-between",
					backgroundColor: "#010101",
				}}>
				<Text>Error Sending request!! {error.message}</Text>
			</View>
		);
	}

	if (data) {
		relationRef.current = data?.updateUsers?.info?.relationshipsCreated;
	}

	return (
		<Layout level="3" style={styles.container}>
			<Input
				value={userInput.myId}
				onChangeText={(string) => handleInput(string)}
				placeholder="My Id..."
				label={<TextLabel>My Id</TextLabel>}
				size="medium"
			/>

			<Input
				value={userInput.friendId}
				onChangeText={(string) => handleInput(string, true)}
				placeholder="Friend Id..."
				label={<TextLabel>Friend Id</TextLabel>}
				size="medium"
			/>

			<Button
				style={{
					marginVertical: 5,
				}}
				onPress={handleSendReq}>
				Send Req
			</Button>

			<Text>RelationshipCreated: {relationRef.current}</Text>
		</Layout>
	);
}

const styles = StyleSheet.create({
	container: {
		flex: 1,
		paddingVertical: 20,
		paddingHorizontal: 10,
	},
});

export default SendReq;
