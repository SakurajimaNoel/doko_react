/**
 * @format
 */

import { AppRegistry } from "react-native";
import App from "./App";
import { name as appName } from "./app.json";
import { apolloClient } from "./src/Connectors/Apollo-client/apollo";

// import { Amplify, Auth } from "aws-amplify";
// import awsconfig from "./src/aws-exports";
// import { startNetworkLogging } from "react-native-network-logger";

import { ApolloProvider } from "@apollo/client";
// import { setContext } from "@apollo/client/link/context";

//startNetworkLogging();   //for network logging, dont delete

// Amplify.configure(awsconfig);

const Application = () => {
	return (
		<ApolloProvider client={apolloClient}>
			<App />
		</ApolloProvider>
	);
};

AppRegistry.registerComponent(appName, () => Application);
