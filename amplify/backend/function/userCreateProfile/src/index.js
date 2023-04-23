/* Amplify Params - DO NOT EDIT
	ENV
	REGION
Amplify Params - DO NOT EDIT */

/**
 * @type {import('@types/aws-lambda').APIGatewayProxyHandler}
 */

const neo4j = require('neo4j-driver');

const uri = 'neo4j+s://a385299d.databases.neo4j.io';
const user = 'neo4j';
const password = 'CF0T52k5tLfOachns14qdQBTFXVvT-3uMp4-29Simpo';

// create user profile
const createUserProfile = async (userDetails, driver) => {
  const session = driver.session({database: 'neo4j'});

  try {
    const writeQuery = `MERGE (a:Person {
          id: "${userDetails?.id}", 
          name: "${userDetails?.name}", 
          username: "${userDetails?.username}", 
          email: "${userDetails?.email}", 
          dob: "${userDetails?.dob}", 
          bio: '',
          posts: "0",
          friends: "0"})
          return a`;

    const writeResult = await session.executeWrite(tx => tx.run(writeQuery));
  } catch (error) {
    console.error(`Something went wrong: ${error}`);
  } finally {
    // Close down the session if you're not using it anymore.
    await session.close();
  }
};

exports.handler = async event => {
  const driver = neo4j.driver(uri, neo4j.auth.basic(user, password));

  try {
    await createUserProfile(event.arguments, driver);
    return event.arguments;
  } catch (error) {
    console.error(`Something went wrong: ${error}`);
  } finally {
    await driver.close();
  }

  return {
    statusCode: 500,
    //  Uncomment below to enable CORS requests
    //  headers: {
    //      "Access-Control-Allow-Origin": "*",
    //      "Access-Control-Allow-Headers": "*"
    //  },
    body: JSON.stringify("Can't create new user!"),
  };
};
