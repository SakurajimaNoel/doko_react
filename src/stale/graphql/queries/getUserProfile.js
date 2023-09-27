import { gql } from "@apollo/client";

export const getUserProfile = gql`
	query Query(
		$where: UserWhere
		$friendsWhere2: UserWhere
		$options: PostOptions
	) {
		users(where: $where) {
			bio
			createdOn
			dob
			email
			name
			username
			friends(where: $friendsWhere2) {
				username
				name
				id
			}
			posts(options: $options) {
				id
				content
				caption
				createdOn
				likes
			}
		}
	}
`;

const variables = {
	where: {
		id: "7ca6b20b-3d7f-4712-a2ca-a99551011681",
	},
	friendsWhere2: {
		friendsConnection_ALL: {
			edge: {
				status: "ACCEPTED",
			},
		},
	},
	options: {
		limit: 5,
	},
};
