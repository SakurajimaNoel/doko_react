import { gql } from "@apollo/client";

export const createPost = gql`
	mutation Mutation($input: [PostCreateInput!]!) {
		createPosts(input: $input) {
			info {
				nodesCreated
				relationshipsCreated
			}
		}
	}
`;

const variables = {
	input: [
		{
			caption: "rohan's second post",
			content: ["rohan'spost.png", "rohanrohan.png"],
			createdBy: {
				connect: {
					where: {
						node: {
							id: "idfirst",
						},
					},
				},
			},
			likes: 0,
		},
	],
};
