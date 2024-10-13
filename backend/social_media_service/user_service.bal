import ballerina/http;
import ballerina/persist;
import ballerina/time;
import ballerina/uuid;



final Client innolinkdb = check new;

listener http:Listener socialMediaListener = new (9090);

@http:ServiceConfig{
    cors: {
        allowOrigins: ["*"]
    }
}

service /api/users on socialMediaListener {

    # /api/users/getall
    # A resource for getting all users
    # +
    # + return - users[] with all users or error
    resource function get getall() returns users[]|error {
        stream<users, persist:Error?> userStream = innolinkdb->/users(users);
        return from users user in userStream
            select user;
    }

    # /api/users/getbyid/{id}
    # A resource for getting user by id
    # + 
    # + return - user or error
    resource function get getbyid/[string id]() returns users|http:NotFound {
        users|persist:Error user = innolinkdb->/users/[id];
        if user is users {
            return user;
        }
        else{
            return <http:NotFound>{body: {message: "user not found"}};
        }


    };

    # /api/users/add
    # A resource for adding user
    # + newuser - newuser object 
    # + return - http response
    resource function post add(newusers newuser) returns http:Ok|http:InternalServerError|http:BadRequest {

        users user = {
            id: uuid:createRandomUuid(),
            name: newuser.name,
            first_name: newuser.first_name,
            last_name: newuser.last_name,
            email: newuser.email,
            dob: newuser.dob,
            created_at: time:utcNow(),
            profile_pic_url: newuser.profile_pic_url,
            password: newuser.password

        };

        string[]|persist:Error result = innolinkdb->/users.post([user]);
        if result is string[] {
            return http:OK;
        }
        if result is persist:ConstraintViolationError {
            return <http:BadRequest>{body: {message: string `Invalid user id: ${user.id}`}};
        }
        return http:INTERNAL_SERVER_ERROR;
    };

    # /api/users/update/{id}
    # A resource for updating user by id
    # + update - usersUpdate object
    # + return - user or error
    resource function put update/[string id](usersUpdate update) returns users|http:InternalServerError|http:BadRequest {
        users|persist:Error updatedUser = innolinkdb->/users/[id].put(update);
        if updatedUser is users {
            return updatedUser;
        }
        if updatedUser is persist:ConstraintViolationError {
        string violationMessage = updatedUser.message();// Get the violation message
        return <http:BadRequest>{body: {message: string `Constraint violation: ${violationMessage}`}};

        }
        return http:INTERNAL_SERVER_ERROR;

    };

    # /api/users/delete/{id}
    # A resource for deleting user by id
    # + 
    # + return - user or error
    resource function delete delete/[string id]() returns users|http:NotFound {
        users|persist:Error user = innolinkdb->/users/[id].delete;
        if user is users {
            return user;
        }
        else{
            return <http:NotFound>{body: {message: "user not found"}};
        }
    };




}

