import { gql } from "@apollo/client";

// sending friend request
export const userCreateRequest = gql`
	mutation Mutation($where: UserWhere, $update: UserUpdateInput) {
		updateUsers(where: $where, update: $update) {
			info {
				relationshipsCreated
			}
		}
	}
`;

const variables = {
	where: {
		id: "idfirst",
	},
	update: {
		friends: [
			{
				connect: [
					{
						edge: {
							requestedBy: "idfirst",
							status: "PENDING",
						},
						where: {
							node: {
								id: "idsecond",
							},
						},
					},
				],
			},
		],
	},
};
