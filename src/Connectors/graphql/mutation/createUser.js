import { gql } from "@apollo/client";

export const createUser = gql`
	mutation Mutation($input: [UserCreateInput!]!) {
		createUsers(input: $input) {
			info {
				nodesCreated
			}
		}
	}
`;

const variables = {
	input: [
		{
			id: "asdfwfewqfadsf",
			username: "asdfwqfasvadfga",
			email: "awasadfa@gmail.com",
			bio: "",
			dob: "2002-11-11",
			name: "asdfjkl;",
			profilePicture: "awsurl",
		},
	],
};
