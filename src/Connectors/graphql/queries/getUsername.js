import { gql } from "@apollo/client";

export const getUsername = gql`
	query Query($where: UserWhere) {
		users(where: $where) {
			name
			id
		}
	}
`;

const variables = {
	where: {
		username: "rohan",
	},
};
