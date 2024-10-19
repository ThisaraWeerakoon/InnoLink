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
    resource function get getall(string jwt) returns json|http:BadRequest|error {
        // Validate the JWT token
        jwt:Payload|error validationResult = jwt:validate(jwt, validatorConfig);
    
        if (validationResult is jwt:Payload) {
            // JWT validation succeeded
            stream<posts, persist:Error?> postStream = innolinkdb->/posts(posts);
            posts[]|error result = from posts post in postStream select post;
            if result is error {
                return <http:BadRequest>{body: {message: "Failed to retrieve posts"}};
            }
            
            json[] allPosts = [];
            foreach var post in result {
                json postJson = post.toJson();
                allPosts.push(postJson);
            }

            // Return the JSON response all posts and post count
            json responseBody = {
                "post_count": result.length(), 
                "post_objects": allPosts
            };
            return responseBody;
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

    #/api/posts/getPostsByHandshakedUsers
    # A resource for getting all posts by an user's handshakers
    # + userId - user id
    # + return - http reponse or posts[]
    resource function get getPostsByHandshakedUsers(string userId,string jwt) returns json|http:BadRequest|error{

        // Validate the JWT token
        jwt:Payload|error validationResult = jwt:validate(jwt, validatorConfig);
    
        if (validationResult is jwt:Payload) {
            // JWT validation succeeded
            sql:ParameterizedQuery query = `SELECT posts.* 
                                            FROM posts
                                            JOIN handshakes 
                                            ON (
                                                (handshakes.handshakerId = posts.userId AND handshakes.handshakeeId = ${userId})
                                                OR (handshakes.handshakerId = ${userId} AND handshakes.handshakeeId = posts.userId)
                                            )
                                            WHERE handshakes.status = 'ACCEPTED';`;
            
            // Execute the query and fetch the posts
            stream<posts, persist:Error?> postStream = innolinkdb->queryNativeSQL(query);

            // Collect the posts into an array
            posts[]|error postResult = from var post in postStream select post;

            if postResult is posts[] {
                if postResult.length() is 0 {
                    return <http:BadRequest>{body: {message: string `No posts found`}};
                }
                json responseBody = {"post_count": postResult.length(),"post_objects": postResult};
                return responseBody;
            } else {
                return <http:BadRequest>{body: {message: string `Error while retreiving posts`}}; // Return the error in case of failure
            }

 
        } else {
            // JWT validation failed, return the error
            return validationResult;
        }   
    };

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