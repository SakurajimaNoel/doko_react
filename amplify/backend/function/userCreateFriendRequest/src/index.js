/**
 * @type {import('@types/aws-lambda').APIGatewayProxyHandler}
 */

const neo4j = require('neo4j-driver');

const uri = 'neo4j+s://a385299d.databases.neo4j.io';
const user = 'neo4j';
const password = 'CF0T52k5tLfOachns14qdQBTFXVvT-3uMp4-29Simpo';

const userSendFriendRequest = async (driver, requestDetails) => {
  const session = driver.session({database: 'neo4j'});

  try {
    const readQuery = `RETURN EXISTS( (:Person {id:"${requestDetails?.senderId}" })-[:sendFriendRequest]-(:Person {id: "${requestDetails?.receiverId}"}) ) as friendReq`;
    const readResult = await session.executeRead(tx => tx.run(readQuery));

    const friendReq = readResult.records[0].get('friendReq');

    if (!friendReq) {
      const writeQuery = `MATCH (user:Person {id:"${requestDetails?.senderId}" }) WITH user MATCH (friend:Person {id: "${requestDetails?.receiverId}"}) MERGE(user)-[r:sendFriendRequest]->(friend);`;
      const writeResult = await session.executeWrite(tx => tx.run(writeQuery));

      const res = writeResult.summary.counters._stats.relationshipsCreated;

      return res > 0 ? true : false;
    }

    return true;
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
    const res = await userSendFriendRequest(driver, event.arguments);

    return res;
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
    body: JSON.stringify("Can't send Friend Request!"),
  };
};
