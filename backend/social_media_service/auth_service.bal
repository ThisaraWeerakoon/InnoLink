import ballerina/jwt;
import ballerina/persist;
service /api/auth on socialMediaListener {

    // JWT issuer configurations


    # A resource for generating greetings
    # + name - name as a string or nil
    # + return - string name with hello message or error
    resource function post login(string? name) returns string|error {

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
        // Send a response back to the caller.
        if name is () {
            return error("name should not be empty!");
        }
        //return string `Hello, ${name}`;
        // Generate JWT token
        string jwtToken = check jwt:issue(issuerConfig);
        return jwtToken;
    }

    resource function post register() returns string|http:Ok|http:BadRequest {
        users|persist:NotFoundError user = innolinkdb->/users;
        
    }
}