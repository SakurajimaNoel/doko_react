import { gql } from "@apollo/client";

export const getUserIncomingReq = gql`
	query Query(
		$where: UserWhere
		$friendsWhere2: UserWhere
		$directed: Boolean
	) {
		users(where: $where) {
			friends(where: $friendsWhere2, directed: $directed) {
				id
				name
			}
		}
	}
`;

const variables = {
	where: {
		id: "idsecond",
	},
	friendsWhere2: {
		friendsConnection_ALL: {
			NOT: {
				edge: {
					requestedBy: "idsecond",
				},
			},
			edge: {
				status: "PENDING",
			},
		},
	},
	directed: null,
};
