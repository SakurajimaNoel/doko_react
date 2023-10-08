/**
 * @format
 */

import { AppRegistry } from "react-native";
import App from "./App";
import { name as appName } from "./app.json";

// import { Amplify, Auth } from "aws-amplify";
// import awsconfig from "./src/aws-exports";
import { startNetworkLogging } from "react-native-network-logger";

import { ApolloClient, InMemoryCache, ApolloProvider, createHttpLink, HttpLink, ApolloLink, operationName, from } from "@apollo/client";
import { setContext } from '@apollo/client/link/context';


//startNetworkLogging();   //for network logging, dont delete


const httpLink = new HttpLink({uri: "https://p2ntnqst9j.execute-api.ap-south-1.amazonaws.com/"});

const authLink = new ApolloLink((operation, forward) =>{
	const awsSignatureHeader = operation.getContext().hasOwnProperty("headers") ? operation.getContext().headers : {}
	operation.setContext({
		headers:{
			...awsSignatureHeader,
			'Host': "p2ntnqst9j.execute-api.ap-south-1.amazonaws.com"
		}
	});

	return forward(operation);
})


const apolloClient = new ApolloClient({
	cache: new InMemoryCache(),
	link: from([authLink,httpLink]),
	defaultOptions: {
		watchQuery: {
			nextFetchPolicy: "cache-only",
			fetchPolicy: "cache-and-network",
		},
	},
});



// Amplify.configure(awsconfig);

const Application = () => {
	return (
		<ApolloProvider client={apolloClient}>
			<App />
		</ApolloProvider>
	);
};

AppRegistry.registerComponent(appName, () => Application);
