import {
	ApolloClient,
	InMemoryCache,
	HttpLink,
	ApolloLink,
	from,
} from "@apollo/client";

const httpLink = new HttpLink({
	uri: "https://p2ntnqst9j.execute-api.ap-south-1.amazonaws.com/",
});

const authLink = new ApolloLink((operation, forward) => {
	const awsSignatureHeader = operation.getContext().hasOwnProperty("headers")
		? operation.getContext().headers
		: {};
	operation.setContext({
		headers: {
			...awsSignatureHeader,
			Host: "p2ntnqst9j.execute-api.ap-south-1.amazonaws.com",
		},
	});

	return forward(operation);
});

export const apolloClient = new ApolloClient({
	cache: new InMemoryCache(),
	link: from([authLink, httpLink]),
	defaultOptions: {
		watchQuery: {
			nextFetchPolicy: "cache-only",
			fetchPolicy: "cache-and-network",
		},
	},
});
