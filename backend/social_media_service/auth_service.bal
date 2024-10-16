import ballerina/jwt;
import ballerina/http;
import ballerina/sql;
// import ballerinax/persist.sql as psql;
import ballerina/persist;
import ballerina/time;
import ballerina/uuid;
import ballerina/crypto;

// JWT issuer configurations
jwt:IssuerConfig issuerConfig = {
    issuer: "socialMediaApp",
    audience: "users",
    expTime: 3600,
    signatureConfig: {
        config: {
            keyFile: "./resources/private.key" // No need for a private key file
            }
    }
};

@http:ServiceConfig{
    cors: {
        allowOrigins: ["*"]
    }
}

service /api/auth on socialMediaListener {
    
    # /api/auth/login
    # A resource for logging users
    # + email - email as a string
    # + password - password as a string
    # + return - jwt token as a string, htttp:BadRequest, error
    resource function get login(string email, string password) returns string|http:BadRequest|error {

        
        sql:ParameterizedQuery selectQuery = `SELECT * FROM users WHERE email = ${email}`;
        stream<users, persist:Error?> userStream = innolinkdb->queryNativeSQL(selectQuery);

        users[]|error result = from var user in userStream select user;

        if result is error {
            return <http:BadRequest>{body: {message: string `Failed to retrieve user details:`}};
        }

        // Check if the user exists
        if result.length() > 0 {
            users user = result[0];

            //compare the provided password against the password stored in the database
            if comparePassword(password,user.password) is false {
                return <http:BadRequest>{body: {message: string ` wrong password:`}};
            }
            // Issue JWT token
            string jwtToken = check jwt:issue(issuerConfig);
            return jwtToken;
        }
        else{
            return <http:BadRequest>{body: {message: string `User does not exists:`}};
        }
    }


    # /api/auth/register
    # A resource for registering users
    # + registerUser - registerusers 
    # + return - jwt token as a string, htttp:BadRequest, error
    resource function post register(registerusers registerUser) returns string|http:BadRequest|error {

        sql:ParameterizedQuery selectQuery = `SELECT * FROM users WHERE email = ${registerUser.email}`;

        stream<users, persist:Error?> userStream = innolinkdb->queryNativeSQL(selectQuery);

        users[]|error result = from var user in userStream select user;
        if result is error {
            return <http:BadRequest>{body: {message: string `Failed to retrieve user details:`}};
        }

        // Check if the user already exists
        if result.length() > 0 {
            return <http:BadRequest>{body: {message: string `User already exists:`}};
        }

        users newUser = {
            id: uuid:createRandomUuid(),
            name: (),
            first_name: registerUser.first_name,
            last_name: registerUser.last_name,
            email: registerUser.email,
            dob: registerUser.dob,
            created_at: time:utcNow(),
            profile_pic_url: (),
            password: hashPassword(registerUser.password)
        };

        // Insert the new user into the database
        string[]|persist:Error insertResult = innolinkdb->/users.post([newUser]);

        if insertResult is string[] {
            // Issue JWT token
            string jwtToken = check jwt:issue(issuerConfig);
            return jwtToken;
            
        }
        return <http:BadRequest>{body: {message: string `Failed to register user:`}};
    }

                  
    
}

// Hash a password using SHA-256
isolated function hashPassword(string password) returns string {
    byte[] hashedPassword = crypto:hashSha256(password.toBytes());
    // Convert the hashed password to a base16 (hexadecimal) string for storage
    return hashedPassword.toBase16();
}

// Compare password with hashed password
isolated function comparePassword(string inputPassword, string storedHashedPassword) returns boolean {
    string hashedInputPassword = hashPassword(inputPassword);
    return hashedInputPassword == storedHashedPassword;
}



    
