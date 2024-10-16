import ballerina/persist;
import ballerina/http;
import ballerina/sql;
import ballerina/jwt;
import ballerina/time;
import ballerina/uuid;


@http:ServiceConfig{
    cors: {
        allowOrigins: ["*"],
        allowCredentials: true
    }
}

service /api/comments on socialMediaListener{

    # /api/comments/getallbypost
    # A resource for getting all comments for a post
    # + postId - the id of the post
    # + return - comments[] with all comments for the post or error
    resource function get getallbypost(string postId,string jwt) returns comments[]|http:BadRequest|error {
        // Validate the JWT token
        jwt:Payload|error validationResult = jwt:validate(jwt, validatorConfig);
    
        if (validationResult is jwt:Payload) {
            // JWT validation succeeded
            sql:ParameterizedQuery selectQuery = `SELECT * FROM comments WHERE postId = ${postId}`;

            stream<comments, persist:Error?> commentStream = innolinkdb->queryNativeSQL(selectQuery);

            comments[]|error result = from var comment in commentStream select comment;
            if result is error {
                return <http:BadRequest>{body: {message: string `Failed to retrieve comments:`}};
            }
            return result;
        } else {
            // JWT validation failed, return the error
            return validationResult;
        }

    }

    # /api/comments/getbyid/{id}
    # A resource for getting comment by comment_id
    # + 
    # + return - comment or error
    resource function get getbyid/[string id](string jwt) returns comments|http:NotFound|error {
        
        // Validate the JWT token
        jwt:Payload|error validationResult = jwt:validate(jwt, validatorConfig);
    
        if (validationResult is jwt:Payload) {
            // JWT validation succeeded
            comments|persist:Error comment = innolinkdb->/comments/[id];
            if comment is comments {
                return comment;
            }
            else{
                return <http:NotFound>{body: {message: "comment not found"}};
            }
        } else {
            // JWT validation failed, return the error
            return validationResult;
        }
    };

    #/api/comments/getallbyuser
    # A resource for getting all comments by user id
    # + userId - user id
    # + return - http response or likes
    resource function get getallbyuser(string userId,string jwt) returns comments[]|http:BadRequest|error {
        
        // Validate the JWT token
        jwt:Payload|error validationResult = jwt:validate(jwt, validatorConfig);
    
        if (validationResult is jwt:Payload) {
            // JWT validation succeeded
            sql:ParameterizedQuery selectQuery = `SELECT * FROM comments WHERE userId = ${userId}`;

            stream<comments, persist:Error?> commentStream = innolinkdb->queryNativeSQL(selectQuery);

            comments[]|error result = from var comment in commentStream select comment;
            if result is error {
                return <http:BadRequest>{body: {message: string `Failed to retrieve comment`}};
            }
            return result;
        } else {
            // JWT validation failed, return the error
            return validationResult;
        }
    };

    #api/comments/add
    # A reource for adding a comment
    # + userId - user who comments
    # + postId - for which post user comments
    # + content - content to be commented
    # + return - commentId or error
    resource function post add(string userId,string postId,string content,string jwt) returns string|http:BadRequest|http:InternalServerError|error {

        // Validate the JWT token
        jwt:Payload|error validationResult = jwt:validate(jwt, validatorConfig);
    
        if (validationResult is jwt:Payload) {
            // JWT validation succeeded
            comments comment = {
                id: uuid:createRandomUuid(),
                userId: userId,
                postId: postId,
                content:content,
                created_at: time:utcNow()
            };
            string[]|persist:Error result = innolinkdb->/comments.post([comment]);
            if result is string[] {
                return result[0];
            }
            if result is persist:ConstraintViolationError {
                return <http:BadRequest>{body: {message: string `Invalid comment`}};
            }
            return http:INTERNAL_SERVER_ERROR;
        }
        else {
            // JWT validation failed, return the error
            return validationResult;
        }   
    };   

    #api/comments/delete/{id}
    # A resource for deleting a comment by id
    # + id - comment_id
    # + return - http response or error
    resource function delete delete/[string id](string jwt) returns comments|http:NotFound|error{
        
        // Validate the JWT token
        jwt:Payload|error validationResult = jwt:validate(jwt, validatorConfig);
    
        if (validationResult is jwt:Payload) {
            // JWT validation succeeded
            comments|persist:Error comment = innolinkdb->/comments/[id].delete;
            if comment is comments {
                return comment;
            }
            else{
                return <http:NotFound>{body: {message: "comment not found"}};
            }


        } else {
            // JWT validation failed, return the error
            return validationResult;
        }
    }

    
}