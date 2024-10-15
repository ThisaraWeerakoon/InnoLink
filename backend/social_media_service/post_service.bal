import ballerina/persist;
import ballerina/http;
import ballerina/sql;
service /api/posts on socialMediaListener{

    # /api/posts/getall
    # A resource for getting all posts
    # +
    # + return - posts[] with all posts or error
    resource function get getall() returns posts[]|error {
        stream<posts, persist:Error?> postStream = innolinkdb->/posts(posts);
        return from posts post in postStream
            select post;
    }

    # /api/posts/getbyid/{id}
    # A resource for getting posts by id
    # + 
    # + return - post or error
    resource function get getbyid/[string id]() returns posts|http:NotFound {
        posts|persist:Error post = innolinkdb->/posts/[id];
        if post is posts {
            return post;
        }
        else{
            return <http:NotFound>{body: {message: "post not found"}};
        }
    };

    #/api/posts/getallbyuser/{userId}
    # A resource for getting all posts by user id
    # + userId - user id
    # + return - http response or posts
    resource function get getallbyuser(string userId) returns posts[]|http:BadRequest {

        sql:ParameterizedQuery selectQuery = `SELECT * FROM posts WHERE userId = ${userId}}`;

        stream<posts, persist:Error?> postStream = innolinkdb->queryNativeSQL(selectQuery);

        posts[]|error result = from var post in postStream select post;
        if result is error {
            return <http:BadRequest>{body: {message: string `Failed to retrieve posts:`}};
        }
        return result;
    };

    #/api/posts/getAllByUserFollowing
    # A resource for getting all posts by an user's followers
    # + userId - user id
    # + return - http reponse or posts
    remote function get getAllByUserFollowing(string userId) returns posts[]|http:BadRequest{
        
        sql:ParameterizedQuery selectQuery = `SELECT p.* FROM posts p JOIN followers f ON p.userId = f.followingId WHERE f.followerId = ${userId}}`;
        
    }




}