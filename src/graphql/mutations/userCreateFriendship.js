import { gql } from "@apollo/client";

// wrong
export const userCreateFriendship = gql`
	mutation Mutation($where: UserWhere, $friendsWhere2: UserWhere) {
		updateUsers(where: $where) {
			users {
				friends(where: $friendsWhere2) {
					name
					profilePicture
					username
					id
				}
			}
		}
	}
`;

const variables = {
	where: {
		id: "7ca6b20b-3d7f-4712-a2ca-a99551011681",
	},
	friendsWhere2: {
		friendsConnection_SINGLE: {
			edge: {
				NOT: {
					requestedBy: "7ca6b20b-3d7f-4712-a2ca-a99551011681",
				},
				status: "PENDING",
			},
		},
	},
};
