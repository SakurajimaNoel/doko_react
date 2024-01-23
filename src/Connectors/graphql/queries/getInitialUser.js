import { gql } from "@apollo/client";

export const getInitialUser = gql`
	query Query($where: UserWhere) {
		users(where: $where) {
			name
			username
			profilePicture
		}
	}
`;

const variables = {
	where: {
		id: "2dc9b259-bf9e-4225-a32f-c8b58a77bc4a",
	},
};
