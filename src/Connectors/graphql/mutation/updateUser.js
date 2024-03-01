import { gql } from "@apollo/client";

export const updateUser = gql`
	mutation Mutation($where: UserWhere, $update: UserUpdateInput) {
		updateUsers(where: $where, update: $update) {
			users {
				bio
				name
				username
			}
		}
	}
`;

const variables = {
	where: {
		id: "asdfwfewqfadsf",
	},
	update: {
		bio: "updated by rohan",
		name: "saini bhaii",
		username: "saini_boy",
	},
};
