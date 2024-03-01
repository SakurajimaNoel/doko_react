import { gql } from "@apollo/client";

export const updateProfileImage = gql`
	mutation Mutation($where: UserWhere, $update: UserUpdateInput) {
		updateUsers(where: $where, update: $update) {
			users {
				profilePicture
			}
		}
	}
`;

const variables = {
	where: {
		id: "asdfwfewqfadsf",
	},
	update: {
		profilePicture: "awsurl",
	},
};
