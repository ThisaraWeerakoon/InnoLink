import ballerina/persist;
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


}