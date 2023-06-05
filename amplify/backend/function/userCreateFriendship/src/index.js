/**
 * @type {import('@types/aws-lambda').APIGatewayProxyHandler}
 */

const neo4j = require("neo4j-driver");

const uri = "neo4j+s://a385299d.databases.neo4j.io";
const user = "neo4j";
const password = "CF0T52k5tLfOachns14qdQBTFXVvT-3uMp4-29Simpo";

const createUserFriendship = async (driver, friendshipDetails) => {
	const session = driver.session({ database: "neo4j" });

	try {
		const writeQuery = `MATCH
        (user:Person {id: "${friendshipDetails?.userId}"}) WITH user
        MATCH
        (friend:Person {id: "${friendshipDetails?.friendId}"})
        MERGE (user)-[r:isFriend]-(friend)        
        
        RETURN r
        `;

		// update number of friends
		const updateQuery = `
        MATCH
        (user:Person {id: "${friendshipDetails?.userId}"}) WITH user
        MATCH
        (friend:Person {id: "${friendshipDetails?.friendId}"})
        SET user.friends = +user.friends + 1
        SET friend.friends = +friend.friends + 1
        `;

		// delete sendFriendRequest relation
		const deleteQuery = `Match 
        (a:Person {id: "${friendshipDetails?.userId}"})-[r:sendFriendRequest]-(b:Person {id:"${friendshipDetails?.friendId}"})
        delete r;`;

		const writeResult = await session.executeWrite((tx) =>
			tx.run(writeQuery),
		);

		if (writeResult.summary.counters._stats.relationshipsCreated) {
			const deleteResult = await session.executeWrite((tx) =>
				tx.run(deleteQuery),
			);

			const updateFriends = await session.executeWrite((tx) =>
				tx.run(updateQuery),
			);

			if (updateFriends.summary.counters._stats.propertiesSet)
				return true;
		}

		return false;
	} catch (error) {
		console.error(`Something went wrongs: ${error}`);
	} finally {
		// Close down the session if you're not using it anymore.
		await session.close();
	}
};

exports.handler = async (event) => {
	const driver = neo4j.driver(uri, neo4j.auth.basic(user, password));

	try {
		const res = await createUserFriendship(driver, event.arguments);

		if (res) {
			return res;
		} else {
			throw "can't add friend";
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
		body: JSON.stringify("Can't create friendship!"),
	};
};
