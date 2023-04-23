/**
 * @type {import('@types/aws-lambda').APIGatewayProxyHandler}
 */

const neo4j = require('neo4j-driver');

const uri = 'neo4j+s://a385299d.databases.neo4j.io';
const user = 'neo4j';
const password = 'CF0T52k5tLfOachns14qdQBTFXVvT-3uMp4-29Simpo';

const getUserDetails = async (driver, userDetails) => {
  const session = driver.session({database: 'neo4j'});

  try {
    const readQuery = `MATCH (user:Person {id: "${userDetails?.id}"})
    RETURN user`;

    const readResult = await session.executeRead(tx => tx.run(readQuery));

    return readResult.records[0].get('user').properties;
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
    const user = await getUserDetails(driver, event.arguments);

    if (user) {
      return user;
    } else {
      throw "Can't get user!";
    }
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
    body: JSON.stringify("Can't get user details!"),
  };
};
