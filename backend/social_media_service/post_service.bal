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
service /api/posts on socialMediaListener{

    # /api/posts/getall
    # A resource for getting all posts
    # +
    # + return - posts[] with all posts or error
    resource function get getall(string jwt) returns posts[]|error {
        // Validate the JWT token
        jwt:Payload|error validationResult = jwt:validate(jwt, validatorConfig);
    
        if (validationResult is jwt:Payload) {
            // JWT validation succeeded
            stream<posts, persist:Error?> postStream = innolinkdb->/posts(posts);
            return from posts post in postStream
                select post;
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

    #/api/posts/getallbyuser
    # A resource for getting all posts by user id
    # + userId - user id
    # + return - http response or posts
    resource function get getallbyuser(string userId,string jwt) returns posts[]|http:BadRequest|error {
        
        // Validate the JWT token
        jwt:Payload|error validationResult = jwt:validate(jwt, validatorConfig);
    
        if (validationResult is jwt:Payload) {
            // JWT validation succeeded
            sql:ParameterizedQuery selectQuery = `SELECT * FROM posts WHERE userId = ${userId}`;

            stream<posts, persist:Error?> postStream = innolinkdb->queryNativeSQL(selectQuery);

            posts[]|error result = from var post in postStream select post;
            if result is error {
                return <http:BadRequest>{body: {message: string `Failed to retrieve posts:`}};
            }
            return result;
        } else {
            // JWT validation failed, return the error
            return validationResult;
        }


    };

    // #/api/posts/getAllByHandshakers
    // # A resource for getting all posts by an user's handshakers
    // # + userId - user id
    // # + return - http reponse or posts[]
    // resource function get getAllByUserFollowing(string userId,string jwt) returns posts[]|http:BadRequest|error{

    //     // Validate the JWT token
    //     jwt:Payload|error validationResult = jwt:validate(jwt, validatorConfig);
    
    //     if (validationResult is jwt:Payload) {
    //         // JWT validation succeeded
    //         sql:ParameterizedQuery selectFollowsQuery = `SELECT * FROM handshakes WHERE handshakerId = ${userId} AND accepted = TRUE`;

    //         stream<follows, persist:Error?> followStream = innolinkdb->queryNativeSQL(selectFollowsQuery);

    //         follows[]|error result = from var follow in followStream select follow;

    //         if result is error {
    //             return <http:BadRequest>{body: {message: string `Failed to retrieve followers:`}};
    //         }

    //         posts[] allPostsFromFollowers = [];

    //         foreach follows follow in result {
    //             string followerId = follow.followingId;
    //             sql:ParameterizedQuery selectPostsQuery = `SELECT * FROM posts WHERE userId = ${followerId}`;
    //             stream<posts, persist:Error?> postStream = innolinkdb->queryNativeSQL(selectPostsQuery);
    //             posts[]|error postsResult = from var post in postStream select post;
    //             if postsResult is error {
    //                 return <http:BadRequest>{body: {message: string `Failed to retrieve posts for followers:`}};
    //             }
    //             foreach posts post in postsResult {
    //                 allPostsFromFollowers.push(post);
    //             }
    //         }
            
    //         return allPostsFromFollowers;
    //     } else {
    //         // JWT validation failed, return the error
    //         return validationResult;
    //     }   
    // };

    #api/posts/add
    # A reource for adding a new post
    # + mewPost - newposts
    # + return - postId or error
    resource function post add(newposts newPost, string userId,string jwt) returns string|http:BadRequest|http:InternalServerError|error {

        // Validate the JWT token
        jwt:Payload|error validationResult = jwt:validate(jwt, validatorConfig);
    
        if (validationResult is jwt:Payload) {
            // JWT validation succeeded
            posts post = {
                id: uuid:createRandomUuid(),
                img_url: newPost.img_url,
                video_url: newPost.video_url,
                caption: newPost.caption,
                userId: userId,
                created_at: time:utcNow()
            };
            string[]|persist:Error result = innolinkdb->/posts.post([post]);
            if result is string[] {
                return result[0];
            }
            if result is persist:ConstraintViolationError {
                return <http:BadRequest>{body: {message: string `Invalid post details`}};
            }
            return http:INTERNAL_SERVER_ERROR;
        }
        else {
            // JWT validation failed, return the error
            return validationResult;
        }   
    };   

    #api/posts/delete/{id}
    # A resource for deleting a post by id
    # + id - post id
    # + return - http response or error
    resource function delete delete/[string id](string jwt) returns posts|http:NotFound|error{
        
        // Validate the JWT token
        jwt:Payload|error validationResult = jwt:validate(jwt, validatorConfig);
    
        if (validationResult is jwt:Payload) {
            // JWT validation succeeded
            posts|persist:Error post = innolinkdb->/posts/[id].delete;
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