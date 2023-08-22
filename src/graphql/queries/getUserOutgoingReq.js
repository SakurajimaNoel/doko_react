import { gql } from "@apollo/client";

export const getUserOutgoingReq = gql`
	query Query($where: UserWhere, $friendsWhere2: UserWhere) {
		users(where: $where) {
			friends(where: $friendsWhere2) {
				id
				name
			}
		}
	}
`;

const variables = {
	where: {
		id: "idfirst",
	},
	friendsWhere2: {
		friendsConnection_ALL: {
			edge: {
				requestedBy: "idfirst",
				status: "PENDING",
			},
		},
	},
};
