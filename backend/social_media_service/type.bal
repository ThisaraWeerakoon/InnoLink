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

public type registerusers record{|

    string email;
    string first_name;
    string last_name;
    time:Date dob;
    string password;


|};

public type newposts record{|

    string? img_url;
    string? video_url;
    time:Utc created_at;
    users user;
    string caption;

|};