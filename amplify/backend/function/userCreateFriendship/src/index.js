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
        RETURN user.friends
        `;
		// delete sendFriendRequest relation

		const deleteQuery = `Match 
        (a:Person {id: "${friendshipDetails?.userId}"})-[r:sendFriendRequest]-(b:Person {id:"${friendshipDetails?.friendId}"})
        delete r;`;

		const writeResult = await session.executeWrite((tx) =>
			tx.run(writeQuery),
		);

		const deleteResutl = await session.executeWrite((tx) =>
			tx.run(deleteQuery),
		);
	} catch (error) {
		console.error(`Something went wrong: ${error}`);
	} finally {
		// Close down the session if you're not using it anymore.
		await session.close();
	}
};

exports.handler = async (event) => {
	const driver = neo4j.driver(uri, neo4j.auth.basic(user, password));

	try {
		await createUserFriendship(driver, event.arguments);
		return event?.arguments;
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
