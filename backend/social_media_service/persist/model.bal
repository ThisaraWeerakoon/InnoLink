import ballerina/persist as _;
import ballerina/time;

public type users record {|
    readonly string id;
    string name;
    string email;
    string first_name;
    string last_name;
    time:Date dob;
    time:Utc created_at;
    string profile_pic_url;
    string password;

     // Relations
    posts[] userPosts;      // A user can have multiple posts.
    comments[] userComments; // A user can have multiple comments.
    likes[] userLikes;      // A user can have multiple likes.
    follows[] followers;    // A user can have multiple followers.
    follows[] following;    // A user can follow multiple others.
|};

public type posts record {|
    readonly string id;
    string? img_url;
    string? video_url;
    time:Utc created_at;
    users user;
    string caption;

    // Relations
    comments[] postComments; // A post can have multiple comments.
    likes[] postLikes;       // A post can have multiple likes.
|};

public type comments record {|
    readonly string id;
    string content;
    time:Utc created_at;
    users user;
    posts post;
|};

public type likes record {|
    readonly string id;
    users user;
    posts post;
    time:Utc created_at;
    boolean active;   
|};

public type follows record {|
    readonly string id;
    users follower;
    users following;
    time:Utc created_at; 
|};


