import ballerina/http;
import ballerina/persist;
import ballerina/time;
import ballerina/uuid;
// import ballerina/sql;
import ballerina/jwt;

final Client innolinkdb = check new;

listener http:Listener socialMediaListener = new (9090);

final jwt:ValidatorConfig validatorConfig = {
    issuer: "socialMediaApp",
    audience: "users",
    clockSkew: 60,
    signatureConfig: {
        certFile: "./resources/public.crt"
    }
};

@http:ServiceConfig{
    cors: {
        allowOrigins: ["*"],
        allowCredentials: true
    }
}

service /api/users on socialMediaListener {


    # /api/users/getall
    # A resource for getting all users
    # +
    # + return - users[] with all users or error
    resource function get getall(string jwt) returns users[]|error {

    
        // Validate the JWT token
        jwt:Payload|error validationResult = jwt:validate(jwt, validatorConfig);
    
        if (validationResult is jwt:Payload) {
            // JWT validation succeeded
            stream<users, persist:Error?> userStream = innolinkdb->/users(users);
        
            // Convert the stream to an array
            users[]|error userList = from users user in userStream select user;
        
            return userList;
        } else {
            // JWT validation failed, return the error
            return validationResult;
        }
    }


    # /api/users/getbyid/{id}
    # A resource for getting user by id
    # + 
    # + return - user or error
    resource function get getbyid/[string id](string jwt) returns users|http:NotFound|error {

        // Validate the JWT token
        jwt:Payload|error validationResult = jwt:validate(jwt, validatorConfig);
    
        if (validationResult is jwt:Payload) {
            // JWT validation succeeded
            users|persist:Error user = innolinkdb->/users/[id];
            if user is users {
                return user;
            }
            else{
                return <http:NotFound>{body: {message: "user not found"}};
            }
        } else {
            // JWT validation failed, return the error
            return validationResult;
        }




    };

    # /api/users/add
    # A resource for adding user
    # + newuser - newuser object 
    # + return - http response
    resource function post add(newusers newuser,string jwt) returns http:Ok|http:InternalServerError|http:BadRequest|error {

        // Validate the JWT token
        jwt:Payload|error validationResult = jwt:validate(jwt, validatorConfig);
    
        if (validationResult is jwt:Payload) {
            // JWT validation succeeded
            users user = {
                id: uuid:createRandomUuid(),
                name: newuser.name,
                first_name: newuser.first_name,
                last_name: newuser.last_name,
                email: newuser.email,
                dob: newuser.dob,
                created_at: time:utcNow(),
                profile_pic_url: newuser.profile_pic_url,
                password: newuser.password,
                about_me: (),
                banner_url: ()

            };

            string[]|persist:Error result = innolinkdb->/users.post([user]);
            if result is string[] {
                return http:OK;
            }
            if result is persist:ConstraintViolationError {
                return <http:BadRequest>{body: {message: string `Invalid user id: ${user.id}`}};
            }
            return http:INTERNAL_SERVER_ERROR;

        } else {
            // JWT validation failed, return the error
            return validationResult;
        }

    
    };

    # /api/users/update/{id}
    # A resource for updating user by id
    # + update - usersUpdate object
    # + return - user or error
    resource function put update/[string id](usersUpdate update,string jwt) returns users|http:InternalServerError|http:BadRequest|error {

        // Validate the JWT token
        jwt:Payload|error validationResult = jwt:validate(jwt, validatorConfig);
    
        if (validationResult is jwt:Payload) {
            // JWT validation succeeded
            users|persist:Error updatedUser = innolinkdb->/users/[id].put(update);
            if updatedUser is users {
                return updatedUser;
            }
            if updatedUser is persist:ConstraintViolationError {
                string violationMessage = updatedUser.message();// Get the violation message
                return <http:BadRequest>{body: {message: string `Constraint violation: ${violationMessage}`}};

            }
            return http:INTERNAL_SERVER_ERROR;


        } else {
            // JWT validation failed, return the error
            return validationResult;
        }
    };

    # /api/users/delete/{id}
    # A resource for deleting user by id
    # + 
    # + return - user or error
    resource function delete delete/[string id](string jwt) returns users|http:NotFound|error {

        // Validate the JWT token
        jwt:Payload|error validationResult = jwt:validate(jwt, validatorConfig);
    
        if (validationResult is jwt:Payload) {
            // JWT validation succeeded
            users|persist:Error user = innolinkdb->/users/[id].delete;
            if user is users {
                return user;
            }
            else{
                return <http:NotFound>{body: {message: "user not found"}};
            }


        } else {
            // JWT validation failed, return the error
            return validationResult;
        }
    };


}

