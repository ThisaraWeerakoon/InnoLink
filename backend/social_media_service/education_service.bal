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

service /api/education on socialMediaListener {





    # /api/education/getbyid/{id}
    # A resource for getting education by id
    # + 
    # + return - json containing education or error
    resource function get getbyid/[string id](string jwt) returns json|http:NotFound|error {

        // Validate the JWT token
        jwt:Payload|error validationResult = jwt:validate(jwt, validatorConfig);
    
        if (validationResult is jwt:Payload) {
            // JWT validation succeeded
            education|persist:Error education_object = innolinkdb->/educations/[id];
            if education_object is education {
                json reposneBody = {"education_object_by_id": education_object};
                return reposneBody;
            }
            else{
                return <http:NotFound>{body: {message: "user not found"}};
            }
        } else {
            // JWT validation failed, return the error
            return validationResult;
        }




    };

    # /api/education/addEducation
    # A resource for adding education section
    # + userId - user id
    # + education - new education section
    # + return - added education_object's id as a json object and other http reponses
    resource function post add(string userId,neweducation neweducation,string jwt) returns json|http:InternalServerError|http:BadRequest|error {

        // Validate the JWT token
        jwt:Payload|error validationResult = jwt:validate(jwt, validatorConfig);
    
        if (validationResult is jwt:Payload) {
            // JWT validation succeeded
            education education_object = {
                id: uuid:createRandomUuid(),
                institution: neweducation.institution,
                start_year: neweducation.start_year,
                end_year: neweducation.end_year,
                degree: neweducation.degree,
                field_of_study: neweducation.field_of_study,
                userId: userId

            };

            string[]|persist:Error result = innolinkdb->/educations.post([education_object]);
            if result is string[] {
                json reposneBody = {"education_id": result[0]};
                return reposneBody;
            }
            if result is persist:ConstraintViolationError {
                return <http:BadRequest>{body: {message: string `Invalid handshake request`}};
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

    #api/education/geteducationbyuserid
    # A resource for getting education info about a give user
    # + userId - user id
    # + return - json obeject contating number of education and information or erro
    resource function get geteducationbyuserid(string userId,string jwt) returns json|http:BadRequest|error{
        // Validate the JWT token
        jwt:Payload|error validationResult = jwt:validate(jwt, validatorConfig);
    
        if (validationResult is jwt:Payload) {
            // JWT validation succeeded
            
            // Prepare the SQL query to fetch education records for the user
            sql:ParameterizedQuery selectQuery = `SELECT * FROM education WHERE userId = ${userId};`;

            // Execute the query and get the result as a stream
            stream<education, persist:Error?> educationStream = innolinkdb->queryNativeSQL(selectQuery);

            // Convert the result stream into an array
            education[]|error result = from var educationEntry in educationStream select educationEntry;

            // Handle errors in SQL execution
            if result is error {
                return <http:BadRequest>{body: {message: "Failed to retrieve education records"}};
            }

            // If no records found, return an empty response
            if result.length() == 0 {
                return <http:BadRequest>{body: {message: "No education records found for the specified user"}};
            }

            // Return the JSON response containing the education records
            json responseBody = {
                "education_count": result.length(),
                "education_records": result
            };
            return responseBody;
        }
        else {
            // JWT validation failed, return the error
            return validationResult;
        }

        
    }





}

