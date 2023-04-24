/* eslint-disable */
// this is an auto generated file. This will be overwritten

export const createProfile = /* GraphQL */ `
  mutation CreateProfile(
    $id: ID!
    $name: String!
    $username: String!
    $email: AWSEmail!
    $dob: AWSDate!
  ) {
    createProfile(
      id: $id
      name: $name
      username: $username
      email: $email
      dob: $dob
    ) {
      id
      name
      username
      email
      dob
      bio
      friends
      posts
    }
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
