/* Amplify Params - DO NOT EDIT
	ENV
	REGION
Amplify Params - DO NOT EDIT */

/**
 * @type {import('@types/aws-lambda').APIGatewayProxyHandler}
 */
exports.handler = async (event) => {
    
        const neo4j = require('neo4j-driver');
    
        const uri = 'neo4j+s://a385299d.databases.neo4j.io';
        const user = 'neo4j';
        const password = 'CF0T52k5tLfOachns14qdQBTFXVvT-3uMp4-29Simpo';
        
        // To learn more about the driver: https://neo4j.com/docs/javascript-manual/current/client-applications/#js-driver-driver-object
        const driver = neo4j.driver(uri, neo4j.auth.basic(user, password));
    
        try {
            const person1Name = 'Alice';
            const person2Name = 'David';
            
            switch (event.field){
                case 'createProfile':
                    const personName = event.arguments.name;
                    await createFriendship(driver, personName, person2Name);
                    return event.arguments
                default:
                    throw new Error('Unknown field, unable to resolve ' + event.field)
            }

            
    
           // await findPerson(driver, person1Name);
           // await findPerson(driver, person2Name);
        } catch (error) {
            console.error(`Something went wrong: ${error}`);
        } finally {
            // Don't forget to close the driver connection when you're finished with it.
            await driver.close();
        }
    
        async function createFriendship (driver, person1Name, person2Name) {
    
            // To learn more about sessions: https://neo4j.com/docs/javascript-manual/current/session-api/
            const session = driver.session({ database: 'neo4j' });
    
            try {
                // To learn more about the Cypher syntax, see: https://neo4j.com/docs/cypher-manual/current/
                // The Reference Card is also a good resource for keywords: https://neo4j.com/docs/cypher-refcard/current/
                const writeQuery = `MERGE (p1:Person { name: $person1Name })
                                    MERGE (p2:Person { name: $person2Name })
                                    MERGE (p1)-[:KNOWS]->(p2)
                                    RETURN p1, p2`;
    
                // Write transactions allow the driver to handle retries and transient errors.
                const writeResult = await session.executeWrite(tx =>
                    tx.run(writeQuery, { person1Name, person2Name })
                );
    
                // Check the write results.
                writeResult.records.forEach(record => {
                    const person1Node = record.get('p1');
                    const person2Node = record.get('p2');
                    console.info(`Created friendship between: ${person1Node.properties.name}, ${person2Node.properties.name}`);
                });
    
            } catch (error) {
                console.error(`Something went wrong: ${error}`);
            } finally {
                // Close down the session if you're not using it anymore.
                await session.close();
            }
        }
    
        async function findPerson(driver, personName) {
    
            const session = driver.session({ database: 'neo4j' });
    
            try {
                const readQuery = `MATCH (p:Person)
                                WHERE p.name = $personName
                                RETURN p.name AS name`;
                
                const readResult = await session.executeRead(tx =>
                    tx.run(readQuery, { personName })
                );
    
                readResult.records.forEach(record => {
                    console.log(`Found person: ${record.get('name')}`)
                });
            } catch (error) {
                console.error(`Something went wrong: ${error}`);
            } finally {
                await session.close();
            }
        }
    
    
    console.log(`EVENT: ${JSON.stringify(event)}`);
    return {
        statusCode: 200,
    //  Uncomment below to enable CORS requests
    //  headers: {
    //      "Access-Control-Allow-Origin": "*",
    //      "Access-Control-Allow-Headers": "*"
    //  }, 
        body: JSON.stringify('Hello from Lambda!'),
    };
};
