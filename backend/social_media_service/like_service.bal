import ballerina/persist;
import ballerina/http;
import ballerina/sql;
import ballerina/jwt;
import ballerina/time;
import ballerina/uuid;
import ballerina/io;
service /api/likes on socialMediaListener{

    # /api/likes/getallbypost
    # A resource for getting all active likes for a post
    # + postId - the id of the post
    # + return - likes[] with all likes for the post or error
    resource function get getallbypost(string postId,string jwt) returns likes[]|http:BadRequest|error {
        // Validate the JWT token
        jwt:Payload|error validationResult = jwt:validate(jwt, validatorConfig);
    
        if (validationResult is jwt:Payload) {
            // JWT validation succeeded
            sql:ParameterizedQuery selectQuery = `SELECT * FROM likes WHERE postId = ${postId} AND active = 1`;

            stream<likes, persist:Error?> likeStream = innolinkdb->queryNativeSQL(selectQuery);

            likes[]|error result = from var like in likeStream select like;
            io:println(result);
            if result is error {
                return <http:BadRequest>{body: {message: string `Failed to retrieve likes:`}};
            }
            return result;
        } else {
            // JWT validation failed, return the error
            return validationResult;
        }

    }

    # /api/posts/getbyid/{id}
    # A resource for getting posts by id
    # + 
    # + return - post or error
    resource function get getbyid/[string id](string jwt) returns posts|http:NotFound|error {
        
        // Validate the JWT token
        jwt:Payload|error validationResult = jwt:validate(jwt, validatorConfig);
    
        if (validationResult is jwt:Payload) {
            // JWT validation succeeded
            posts|persist:Error post = innolinkdb->/posts/[id];
            if post is posts {
                return post;
            }
            else{
                return <http:NotFound>{body: {message: "post not found"}};
            }
        } else {
            // JWT validation failed, return the error
            return validationResult;
        }



    };

    #/api/likes/getallbyuser
    # A resource for getting all likes by user id
    # + userId - user id
    # + return - http response or likes
    resource function get getallbyuser(string userId,string jwt) returns likes[]|http:BadRequest|error {
        
        // Validate the JWT token
        jwt:Payload|error validationResult = jwt:validate(jwt, validatorConfig);
    
        if (validationResult is jwt:Payload) {
            // JWT validation succeeded
            sql:ParameterizedQuery selectQuery = `SELECT * FROM likes WHERE userId = ${userId} AND active = 1`;

            stream<likes, persist:Error?> likesStream = innolinkdb->queryNativeSQL(selectQuery);

            likes[]|error result = from var like in likesStream select like;
            if result is error {
                return <http:BadRequest>{body: {message: string `Failed to retrieve likes`}};
            }
            return result;
        } else {
            // JWT validation failed, return the error
            return validationResult;
        }
    };

    #api/likes/isliked
    # A resource for checking whether an user likes to a post (active likes)
    # + userId - user  
    # + postId - post
    # + return - boolean
    resource function get isliked(string userId,string postId,string jwt) returns int|http:BadRequest|error{
        // Validate the JWT token
        jwt:Payload|error validationResult = jwt:validate(jwt, validatorConfig);
    
        if (validationResult is jwt:Payload) {
            // JWT validation succeeded
            sql:ParameterizedQuery selectQuery = `SELECT * FROM likes WHERE userId = ${userId} AND postId = ${postId} AND active = 1`;
            io:println(selectQuery);
            stream<likes, persist:Error?> likesStream = innolinkdb->queryNativeSQL(selectQuery);
            io:println(likesStream);
            likes[]|error result = from var like in likesStream select like;
            io:println(result);
            if result is error {
                return <http:BadRequest>{body: {message: string `Failed to retrieve likes`}};
            }
            //return result.length > 0;
            return result.length();
        } else {
            // JWT validation failed, return the error
            return validationResult;
        }

    }



    #api/likes/add
    # A reource for adding a like
    # + userId - user who likes
    # + postId - for which post user likes
    # + return - postId or error
    resource function post add(string userId,string postId,string jwt) returns string|http:BadRequest|http:InternalServerError|error {

        // Validate the JWT token
        jwt:Payload|error validationResult = jwt:validate(jwt, validatorConfig);
    
        if (validationResult is jwt:Payload) {
            // JWT validation succeeded
            likes like = {
                id: uuid:createRandomUuid(),
                userId: userId,
                postId: postId,
                active: true,
                created_at: time:utcNow()
            };
            string[]|persist:Error result = innolinkdb->/likes.post([like]);
            if result is string[] {
                return result[0];
            }
            if result is persist:ConstraintViolationError {
                return <http:BadRequest>{body: {message: string `Invalid like`}};
            }
            return http:INTERNAL_SERVER_ERROR;
        }
        else {
            // JWT validation failed, return the error
            return validationResult;
        }   
    };   

    #api/likes/delete/{id}
    # A resource for deleting a like by id
    # + id - post id
    # + return - http response or error
    resource function delete delete/[string postId](string jwt) returns posts|http:NotFound|error{
        
        // Validate the JWT token
        jwt:Payload|error validationResult = jwt:validate(jwt, validatorConfig);
    
        if (validationResult is jwt:Payload) {
            // JWT validation succeeded
            posts|persist:Error post = innolinkdb->/posts/[postId].delete;
            if post is posts {
                return post;
            }
            else{
                return <http:NotFound>{body: {message: "post not found"}};
            }


        } else {
            // JWT validation failed, return the error
            return validationResult;
        }
    }




}