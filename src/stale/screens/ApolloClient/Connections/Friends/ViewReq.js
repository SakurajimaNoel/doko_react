import { useQuery } from "@apollo/client";
import { getUserIncomingReq } from "../../../../graphql/queries/getUserIncomingReq";
import { getUserOutgoingReq } from "../../../../graphql/queries/getUserOutgoingReq";
import { View, StyleSheet } from "react-native";
import { useState, useRef, useEffect } from "react";
import { Button, Input, Text, Layout } from "@ui-kitten/components";

const TextLabel = ({ children }) => {
	return (
		<Text style={{ marginBottom: 5 }} category="h6">
			{children}
		</Text>
	);
};

const IncomingReq = ({ id }) => {
	const { data, loading, error } = useQuery(getUserIncomingReq, {
		variables: {
			where: {
				id: id,
			},
			friendsWhere2: {
				friendsConnection_ALL: {
					NOT: {
						edge: {
							requestedBy: id,
						},
					},
					edge: {
						status: "PENDING",
					},
				},
			},
			directed: null,
		},
	});
	const [users, setUsers] = useState([]);

	useEffect(() => {
		if (data) {
			console.log(data);
			let requests = data?.users[0]?.friends;
			if (requests) setUsers(requests);
			else setUsers([]);
		}
	}, [data]);

	if (loading) {
		return (
			<Layout level="2" style={styles.container}>
				<Text>Fetching Incoming Requests {":)"}</Text>
			</Layout>
		);
	}

	if (error) {
		return (
			<Layout level="2" style={styles.container}>
				<Text>Error getting incoming request!! {error.message}</Text>
			</Layout>
		);
	}

	const req = users.map((reqData) => {
		let reqId = reqData.id;
		let name = reqData.name;

		return (
			<Layout level="2" key={reqId} style={styles.subContainer}>
				<Text>Id: {reqId}</Text>
				<Text>Name: {name}</Text>
			</Layout>
		);
	});

	return (
		<Layout level="1" style={styles.reqContainer}>
			<Text>Incoming Request:</Text>
			{req}
		</Layout>
	);
};

const OutgoingReq = ({ id }) => {
	const { data, loading, error } = useQuery(getUserOutgoingReq, {
		variables: {
			where: {
				id: id,
			},
			friendsWhere2: {
				friendsConnection_ALL: {
					edge: {
						requestedBy: id,
						status: "PENDING",
					},
				},
			},
		},
	});
	const [users, setUsers] = useState([]);

	useEffect(() => {
		if (data) {
			console.log(data);
			let requests = data?.users[0]?.friends;
			if (requests) setUsers(requests);
			else setUsers([]);
		}
	}, [data]);

	if (loading) {
		return (
			<Layout level="1" style={styles.container}>
				<Text>Fetching outgoing Request {":)"}</Text>
			</Layout>
		);
	}

	if (error) {
		return (
			<Layout level="2" style={styles.container}>
				<Text>Error getting outgoing request!! {error.message}</Text>
			</Layout>
		);
	}

	const req = users.map((reqData) => {
		let reqId = reqData.id;
		let name = reqData.name;

		return (
			<Layout level="2" key={reqId} style={styles.subContainer}>
				<Text>Id: {reqId}</Text>
				<Text>Name: {name}</Text>
			</Layout>
		);
	});

	return (
		<Layout level="1" style={styles.reqContainer}>
			<Text>Outgoing Request:</Text>
			{req}
		</Layout>
	);
};

function ViewReq({ navigation }) {
	const [id, setId] = useState("90465");
	const [userInput, setUserInput] = useState("90465");
	const showRef = useRef(false);

	return (
		<Layout level="3" style={styles.container}>
			<Input
				value={userInput}
				onChangeText={(newId) => setUserInput(newId)}
				placeholder="My Id..."
				label={<TextLabel>My Id</TextLabel>}
				size="medium"
			/>

			<Button
				style={{
					marginVertical: 5,
				}}
				onPress={() => setId(userInput)}>
				Get Req
			</Button>

			<IncomingReq id={id} />
			<OutgoingReq id={id} />
		</Layout>
	);
}

const styles = StyleSheet.create({
	container: {
		flex: 1,
		paddingVertical: 20,
		paddingHorizontal: 10,
	},
	subContainer: {
		marginVertical: 5,
		padding: 10,
	},
	reqContainer: {
		padding: 10,
		margin: 10,
	},
});

export default ViewReq;
