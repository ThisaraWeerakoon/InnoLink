import ballerina/time;
public type newusers record {|

    string name;
    string email;
    string first_name;
    string last_name;
    time:Date dob;
    string profile_pic_url;
    string password;
|};