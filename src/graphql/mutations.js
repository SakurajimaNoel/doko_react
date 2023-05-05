/* eslint-disable */
// this is an auto generated file. This will be overwritten

export const createProfile = /* GraphQL */ `
  mutation CreateProfile(
    $id: ID!
    $name: String!
    $username: String!
    $email: AWSEmail!
    $dob: AWSDate!
    $bio: String!
  ) {
    createProfile(
      id: $id
      name: $name
      username: $username
      email: $email
      dob: $dob
      bio: $bio
    )
  }
`;
export const createFriendship = /* GraphQL */ `
  mutation CreateFriendship($userId: ID!, $friendId: ID!) {
    createFriendship(userId: $userId, friendId: $friendId)
  }
`;
export const createFriendRequest = /* GraphQL */ `
  mutation CreateFriendRequest($senderId: ID!, $receiverId: ID!) {
    createFriendRequest(senderId: $senderId, receiverId: $receiverId)
  }
`;
