/**
 * @format
 */

import { AppRegistry } from "react-native";
import App from "./App";
import { name as appName } from "./app.json";
import { RecoilRoot } from "recoil";

// import { Amplify, Auth } from "aws-amplify";
// import awsconfig from "./src/aws-exports";

import { ApolloClient, InMemoryCache, ApolloProvider } from "@apollo/client";

const apolloClient = new ApolloClient({
	cache: new InMemoryCache(),
	uri: "https://p2ntnqst9j.execute-api.ap-south-1.amazonaws.com",
	defaultOptions: {
		watchQuery: {
			nextFetchPolicy: "cache-only",
			fetchPolicy: "cache-and-network",
		},
	},
});

// Amplify.configure(awsconfig);

const recoilApp = () => {
	return (
		<ApolloProvider client={apolloClient}>
			<RecoilRoot>
				<App />
			</RecoilRoot>
		</ApolloProvider>
	);
};

AppRegistry.registerComponent(appName, () => recoilApp);
