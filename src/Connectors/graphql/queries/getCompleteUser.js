import { gql } from "@apollo/client";

export const getCompleteUser = gql`
	query Query($where: UserWhere) {
		users(where: $where) {
			bio
			dob
			email
			name
			username
			profilePicture
			friends {
				id
				name
				username
				profilePicture
			}
			posts {
				id
				content
				caption
				likes
			}
		}
	}
`;

const variables = {
	where: {
		id: "2dc9b259-bf9e-4225-a32f-c8b58a77bc4a",
	},
};
