import { gql } from "@apollo/client";

export const userCreateProfile = gql`
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
			bio: "null",
			dob: "null",
			email: "null",
			id: "null",
			name: "null",
			profilePicture: "null",
			username: "null",
		},
	],
};
