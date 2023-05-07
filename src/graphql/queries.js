/* eslint-disable */
// this is an auto generated file. This will be overwritten

export const getProfile = /* GraphQL */ `
  query GetProfile($id: ID!) {
    getProfile(id: $id) {
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
export const getRequests = /* GraphQL */ `
  query GetRequests($myId: ID!, $incoming: Boolean!) {
    getRequests(myId: $myId, incoming: $incoming) {
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
