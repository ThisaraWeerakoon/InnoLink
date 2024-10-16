import ballerina/persist;
import ballerina/http;
import ballerina/sql;
import ballerina/jwt;
import ballerina/time;
import ballerina/uuid;

@http:ServiceConfig{
    cors: {
        allowOrigins: ["*"]
    }
}
service /api/follows on socialMediaListener{


    # /api/follows/getbyid/{id}
    # A resource for getting follow by id
    # + 
    # + return - follow or error
    resource function get getbyid/[string id](string jwt) returns follows|http:NotFound|error {
        
        // Validate the JWT token
        jwt:Payload|error validationResult = jwt:validate(jwt, validatorConfig);
    
        if (validationResult is jwt:Payload) {
            // JWT validation succeeded
            follows|persist:Error follow = innolinkdb->/follows/[id];
            if follow is follows {
                return follow;
            }
            else{
                return <http:NotFound>{body: {message: "follow not found"}};
            }
        } else {
            // JWT validation failed, return the error
            return validationResult;
        }



    };

    #/api/follows/getallbyfollower
    # A resource for getting all followees by follower_id
    # + followerId - follower id
    # + return - http response or posts
    resource function get getallbyfollower(string followerId,string jwt) returns follows[]|http:BadRequest|error {
        
        // Validate the JWT token
        jwt:Payload|error validationResult = jwt:validate(jwt, validatorConfig);
    
        if (validationResult is jwt:Payload) {
            // JWT validation succeeded
            sql:ParameterizedQuery selectQuery = `SELECT * FROM follows WHERE followerId = ${followerId}`;

            stream<follows, persist:Error?> followStream = innolinkdb->queryNativeSQL(selectQuery);

            follows[]|error result = from var follow in followStream select follow;
            if result is error {
                return <http:BadRequest>{body: {message: string `Failed to retrieve follows:`}};
            }
            return result;
        } else {
            // JWT validation failed, return the error
            return validationResult;
        }


    };


    #/api/follows/getallbyfollowee
    # A resource for getting all followers by followee_id
    # + followerId - followee id
    # + return - http response or posts
    resource function get getallbyfollowee(string followingId,string jwt) returns follows[]|http:BadRequest|error {
        
        // Validate the JWT token
        jwt:Payload|error validationResult = jwt:validate(jwt, validatorConfig);
    
        if (validationResult is jwt:Payload) {
            // JWT validation succeeded
            sql:ParameterizedQuery selectQuery = `SELECT * FROM follows WHERE followingId = ${followingId}`;

            stream<follows, persist:Error?> followStream = innolinkdb->queryNativeSQL(selectQuery);

            follows[]|error result = from var follow in followStream select follow;
            if result is error {
                return <http:BadRequest>{body: {message: string `Failed to retrieve follows:`}};
            }
            return result;
        } else {
            // JWT validation failed, return the error
            return validationResult;
        }
    };

    #api/follows/add
    # A reource for adding a new follow connection
    # + followerId - person who follows someone
    # + followingId - person who is been followed by a follower
    # + return - postId or error
    resource function post add(string followerId, string followingId, string jwt) returns string|http:BadRequest|http:InternalServerError|error {

        // Validate the JWT token
        jwt:Payload|error validationResult = jwt:validate(jwt, validatorConfig);

        if (validationResult is jwt:Payload) {
            // JWT validation succeeded
        
            // Check if the followerId already follows the followingId
            sql:ParameterizedQuery selectQuery = `SELECT * FROM follows WHERE followerId = ${followerId} AND followingId = ${followingId}`;
            stream<follows, persist:Error?> followStream = innolinkdb->queryNativeSQL(selectQuery);

            follows[]|error result = from var follow in followStream select follow;
            if result is follows[] {
                if result.length() > 0 {
                    // Follower is already following this user, return a BadRequest
                    return <http:BadRequest>{body: {message: "User is already following the specified user"}};
                }
            } else {
                return <http:BadRequest>{body: {message: "Error while checking existing follow relationship"}};
            }

            // If not already following, proceed to add the new follow relationship
            follows follow = {
                id: uuid:createRandomUuid(),
                followerId: followerId,
                followingId: followingId,
                created_at: time:utcNow()
            };

            string[]|persist:Error insertResult = innolinkdb->/follows.post([follow]);
            if insertResult is string[] {
                return insertResult[0];
            }
            if insertResult is persist:ConstraintViolationError {
                return <http:BadRequest>{body: {message: "Invalid post details"}};
            }

            return http:INTERNAL_SERVER_ERROR;
        } else {
            // JWT validation failed, return the error
            return validationResult;
        }
    };
 

    #api/follows/delete/{id}
    # A resource for deleting a follow connection by id
    # + id - follow id
    # + return - http response or error
    resource function delete delete/[string id](string jwt) returns follows|http:NotFound|error{
        
        // Validate the JWT token
        jwt:Payload|error validationResult = jwt:validate(jwt, validatorConfig);
    
        if (validationResult is jwt:Payload) {
            // JWT validation succeeded
            follows|persist:Error follow = innolinkdb->/follows/[id].delete;
            if follow is follows {
                return follow;
            }
            else{
                return <http:NotFound>{body: {message: "follow not found"}};
            }


        } else {
            // JWT validation failed, return the error
            return validationResult;
        }
    }
}