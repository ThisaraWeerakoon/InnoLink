import ballerina/persist;
import ballerina/http;
import ballerina/sql;
import ballerina/jwt;
import ballerina/uuid;
import ballerina/time;
import ballerina/io;
@http:ServiceConfig{
    cors: {
        allowOrigins: ["*"],
        allowCredentials: true
    }
}
service /api/handshakes on socialMediaListener{


    # /api/handshakes/getbyid/{id}
    # A resource for getting handshake by id
    # + 
    # + return - handshake or error
    resource function get getbyid/[string id](string jwt) returns json|http:NotFound|error {
        
        // Validate the JWT token
        jwt:Payload|error validationResult = jwt:validate(jwt, validatorConfig);
    
        if (validationResult is jwt:Payload) {
            // JWT validation succeeded
            handshakes|persist:Error handshake = innolinkdb->/handshakes/[id];
            if handshake is handshakes {
                json responseBody = {"handshake_object": handshake};
                return responseBody;
            }
            else{
                return <http:NotFound>{body: {message: "handshake not found"}};
            }
        } else {
            // JWT validation failed, return the error
            return validationResult;
        }
    };

    #/api/handshakes/getAcceptedHandshakeUsersById
    # A resource for getting all handshakers by userId
    # + userId - user id
    # + return - json object containing handhshake count and handshaker user objects
    resource function get getAcceptedHandshakeUsersById(string userId,string jwt) returns json|http:BadRequest|error {
        
        // Validate the JWT token
        jwt:Payload|error validationResult = jwt:validate(jwt, validatorConfig);
    
        if (validationResult is jwt:Payload) {
            // JWT validation succeeded

            // Fetch the handshaked users using another stored procedure call
            sql:ParameterizedQuery selectQueryUsers = `CALL get_handshaked_users_details(${userId});`;
            stream<users, persist:Error?> handshakeStream = innolinkdb->queryNativeSQL(selectQueryUsers);

            // Convert users[] array to json array
            users[]|error result = from var handshake in handshakeStream select handshake;
            if result is error {
                return <http:BadRequest>{body: {message: "Failed to retrieve handshakes"}};
            }
            
            json[] handshakedUsersJson = [];
            foreach var user in result {
                json userJson = user.toJson();
                handshakedUsersJson.push(userJson);
            }

            // Return the JSON response with both the handshake count and the handshaked users
            json responseBody = {
                "handshake_count": result.length(), 
                "handshaked_user_objects": handshakedUsersJson
            };
            return responseBody;
        } else {
            // JWT validation failed, return the error
            return validationResult;
        }
    };

    #api/handshakes/add
    # A reource for adding a new handshake connection
    # + handshakerId - person who send handshaking request
    # + handshakeeId - person who recerives the handshaking request
    # + return - postId or error
    resource function post add(string handshakerId, string handshakeeId, string jwt) returns json|http:BadRequest|http:InternalServerError|error {

        // Validate the JWT token
        jwt:Payload|error validationResult = jwt:validate(jwt, validatorConfig);

        if (validationResult is jwt:Payload) {
            // JWT validation succeeded
        
            // Check if the handshakerId already handshaked the handshakeeId 
            sql:ParameterizedQuery selectQuery = `SELECT * FROM handshakes WHERE (handshakerId = ${handshakerId} AND handshakeeId = ${handshakeeId}) OR (handshakerId = ${handshakeeId} AND handshakeeId = ${handshakerId})`;
            stream<handshakes, persist:Error?> handshakeStream = innolinkdb->queryNativeSQL(selectQuery);

            handshakes[]|error result = from var handshake in handshakeStream select handshake;
            if result is handshakes[] {
                if result.length() > 0 {
                    // Follower is already following this user, return a BadRequest
                    return <http:BadRequest>{body: {message: "User is already handshaked the specified user"}};
                }
            } else {
                return <http:BadRequest>{body: {message: "Error while checking existing handshake relationship"}};
            }
            // If not already handshaked, proceed to add the new handshake relationship
            handshakes handshake = {
                id: uuid:createRandomUuid(),
                handshakerId: handshakerId,
                handshakeeId: handshakeeId,
                status: PENDING,
                created_at: time:utcNow()
            };

            string[]|persist:Error insertResult = innolinkdb->/handshakes.post([handshake]);
            if insertResult is string[] {
                sql:ParameterizedQuery selectInsertedQuery = `SELECT * FROM handshakes WHERE id = ${insertResult[0]}`;
                stream<handshakes, persist:Error?> insertedHandshakeStream = innolinkdb->queryNativeSQL(selectInsertedQuery);
                handshakes[]|error insertedHandshakes = from var insertedHandshake in insertedHandshakeStream select insertedHandshake;
                if insertedHandshakes is handshakes[] {
                    json reponseBody = {"handshake_id": insertResult[0],"handshake_object":insertedHandshakes[0]};
                    return reponseBody;

                } else {
                    return <http:BadRequest>{body: {message: "Error while checking existing handshake relationship"}};
                }

            }
            if insertResult is persist:ConstraintViolationError {
                return <http:BadRequest>{body: {message: "Invalid handshake details"}};
            }
            return http:INTERNAL_SERVER_ERROR;
        } else {
            // JWT validation failed, return the error
            return validationResult;
        }
    };
    
    #api/handshakes/updateStatus
    # A resource for updating the status of a handshake
    # + handshakeId - ID of the handshake
    # + newStatus - 'ACCEPTED' or 'REJECTED'
    resource function put updateStatus/[string handshakeId]( string newStatus, string jwt) returns json|http:BadRequest|http:InternalServerError|error {
        
        // Validate the JWT token
        jwt:Payload|error validationResult = jwt:validate(jwt, validatorConfig);
        
        if (validationResult is jwt:Payload) {
            // Validate new status
            if newStatus != "ACCEPTED" && newStatus != "REJECTED" {
                return <http:BadRequest>{body: {message: "Invalid status value"}};
            }
    
            // Update the handshake status in the database
            handshakesUpdate update = {"status":newStatus};
            handshakes|persist:Error updatedHandshake=innolinkdb->/handshakes/[handshakeId].put(update);
            io:println(updatedHandshake);
            if updatedHandshake is handshakes {
                json reponseBody = {"updated_handshake_object": updatedHandshake};
                return reponseBody;
            }
            if updatedHandshake is persist:ConstraintViolationError {
                string violationMessage = updatedHandshake.message();// Get the violation message
                return <http:BadRequest>{body: {message: string `Constraint violation: ${violationMessage}`}};

            }
            return http:INTERNAL_SERVER_ERROR;        
            
        } else {
            // JWT validation failed
            return validationResult;
        }
    };
}
    








 

//     #api/follows/delete/{id}
//     # A resource for deleting a follow connection by id
//     # + id - follow id
//     # + return - http response or error
//     resource function delete delete/[string id](string jwt) returns follows|http:NotFound|error{
        
//         // Validate the JWT token
//         jwt:Payload|error validationResult = jwt:validate(jwt, validatorConfig);
    
//         if (validationResult is jwt:Payload) {
//             // JWT validation succeeded
//             follows|persist:Error follow = innolinkdb->/follows/[id].delete;
//             if follow is follows {
//                 return follow;
//             }
//             else{
//                 return <http:NotFound>{body: {message: "follow not found"}};
//             }


//         } else {
//             // JWT validation failed, return the error
//             return validationResult;
//         }
//     }
// }