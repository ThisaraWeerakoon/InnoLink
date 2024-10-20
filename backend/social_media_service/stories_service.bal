import ballerina/http;
import ballerina/persist;
// import ballerina/time;
import ballerina/uuid;
import ballerina/sql;
import ballerina/jwt;



@http:ServiceConfig{
    cors: {
        allowOrigins: ["*"],
        allowCredentials: true
    }
}

service /api/stories on socialMediaListener {





    # /api/stories/getbyid/{id}
    # A resource for getting stories by id
    # + 
    # + return - json containing stories or error
    resource function get getbyid/[string id](string jwt) returns json|http:NotFound|error {

        // Validate the JWT token
        jwt:Payload|error validationResult = jwt:validate(jwt, validatorConfig);
    
        if (validationResult is jwt:Payload) {
            // JWT validation succeeded
            stories|persist:Error stories_object = innolinkdb->/stories/[id];
            if stories_object is stories {
                json reposneBody = {"stories_object_by_id": stories_object.toJson()};
                return reposneBody;
            }
            else{
                return <http:NotFound>{body: {message: "stories not found"}};
            }
        } else {
            // JWT validation failed, return the error
            return validationResult;
        }




    };

    # /api/stories/add
    # A resource for adding story section
    # + userId - user id
    # + newstory - new story section
    # + return - added story_object's id as a json object and other http reponses
    resource function post add(string userId,newstories newstory ,string jwt) returns json|http:InternalServerError|http:BadRequest|error {

        // Validate the JWT token
        jwt:Payload|error validationResult = jwt:validate(jwt, validatorConfig);
    
        if (validationResult is jwt:Payload) {
            // JWT validation succeeded
            stories stories_object = {
                id: uuid:createRandomUuid(),
                name: newstory.name,
                logo_url: newstory.logo_url,
                start_date: newstory.start_date,
                end_date: newstory.end_date,
                usersId: userId,
                description: newstory.description,
                domain: newstory.domain,
                learning: newstory.learning,
                success: newstory.success

            };

            string[]|persist:Error result = innolinkdb->/stories.post([stories_object]);
            if result is string[] {
                json reposneBody = {"stories_id": result[0]};
                return reposneBody;
            }
            if result is persist:ConstraintViolationError {
                return <http:BadRequest>{body: {message: string `Invalid story request`}};
            }
            return http:INTERNAL_SERVER_ERROR;

        } else {
            // JWT validation failed, return the error
            return validationResult;
        }


    
    };

    // # /api/users/update/{id}
    // # A resource for updating user by id
    // # + update - usersUpdate object
    // # + return - user or error
    // resource function put update/[string id](usersUpdate update,string jwt) returns users|http:InternalServerError|http:BadRequest|error {

    //     // Validate the JWT token
    //     jwt:Payload|error validationResult = jwt:validate(jwt, validatorConfig);
    
    //     if (validationResult is jwt:Payload) {
    //         // JWT validation succeeded
    //         users|persist:Error updatedUser = innolinkdb->/users/[id].put(update);
    //         if updatedUser is users {
    //             return updatedUser;
    //         }
    //         if updatedUser is persist:ConstraintViolationError {
    //             string violationMessage = updatedUser.message();// Get the violation message
    //             return <http:BadRequest>{body: {message: string `Constraint violation: ${violationMessage}`}};

    //         }
    //         return http:INTERNAL_SERVER_ERROR;


    //     } else {
    //         // JWT validation failed, return the error
    //         return validationResult;
    //     }
    // };

    // # /api/users/delete/{id}
    // # A resource for deleting user by id
    // # + 
    // # + return - user or error
    // resource function delete delete/[string id](string jwt) returns users|http:NotFound|error {

    //     // Validate the JWT token
    //     jwt:Payload|error validationResult = jwt:validate(jwt, validatorConfig);
    
    //     if (validationResult is jwt:Payload) {
    //         // JWT validation succeeded
    //         users|persist:Error user = innolinkdb->/users/[id].delete;
    //         if user is users {
    //             return user;
    //         }
    //         else{
    //             return <http:NotFound>{body: {message: "user not found"}};
    //         }


    //     } else {
    //         // JWT validation failed, return the error
    //         return validationResult;
    //     }
    // };

    #api/stories/getstoriesbyuserid
    # A resource for getting stories info about a give user
    # + userId - user id
    # + return - json obeject contating number of stories and information or errors
    resource function get getstoriesbyuserid(string userId,string jwt) returns json|http:BadRequest|error{
        // Validate the JWT token
        jwt:Payload|error validationResult = jwt:validate(jwt, validatorConfig);
    
        if (validationResult is jwt:Payload) {
            // JWT validation succeeded
            
            // Prepare the SQL query to fetch education records for the user
            sql:ParameterizedQuery selectQuery = `SELECT * FROM stories WHERE usersId = ${userId};`;

            // Execute the query and get the result as a stream
            stream<stories, persist:Error?> storiesStream = innolinkdb->queryNativeSQL(selectQuery);

            // Convert the result stream into an array
            stories[]|error result = from var storyEntry in storiesStream select storyEntry;

            // Handle errors in SQL execution
            if result is error {
                return <http:BadRequest>{body: {message: "Failed to retrieve stories records"}};
            }

            // If no records found, return an empty response
            if result.length() == 0 {
                return <http:BadRequest>{body: {message: "No story records found for the specified user"}};
            }

            // Return the JSON response containing the education records
            json responseBody = {
                "stories_count": result.length(),
                "stories_records": result.toJson()
            };
            return responseBody;
        }
        else {
            // JWT validation failed, return the error
            return validationResult;
        }

        
    }





}

