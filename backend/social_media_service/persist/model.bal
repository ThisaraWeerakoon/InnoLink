import ballerina/persist as _;
import ballerina/time;
// import ballerinax/persist.sql;

public enum Domain {
    FINANCE,
    HEALTHCARE,
    EDUCATION,
    ECOMMERCE,
    LOGISTICS,
    ENTERTAINMENT,
    REAL_ESTATE,
    RETAIL,
    MANUFACTURING,
    TELECOMMUNICATIONS,
    HOSPITALITY,
    AUTOMOTIVE,
    TECHNOLOGY
};

public enum NotificationType{
    LIKES_TYPE,
    COMMENTS_TYPE,
    HANDSHAKE_REQUEST_TYPE
}

public type stories record {|
    // @sql:Generated
    // readonly int id;
    readonly string id;
    string name;
    string? logo_url;
    time:Date start_date;
    time:Date? end_date;
    string? description;
    Domain? domain;
    string? learning;
    boolean success;
	users users;



|};

public type education record {|
    // @sql:Generated
    // readonly int id;
    readonly string id;
    string school;
    time:Date start_date;
    time:Date? end_date;
    string? degree;
	users users;

|};

public type users record {|
    // @sql:Generated
    // readonly int id;
    readonly string id;
    string? name;
    string email;
    string first_name;
    string last_name;
    time:Date dob;
    time:Utc created_at;
    string? profile_pic_url;
    string? banner_url;
    string password;
    string? about_me;



    // Relations
    posts[] userPosts;      // A user can have multiple posts.
    comments[] userComments; // A user can have multiple comments.
    likes[] userLikes;      // A user can have multiple likes.
    handshakes[] handshakers;    // A user can have multiple followers.
    handshakes[] handshakees;
	notifications[] receipents;
	notifications[] related_users;   // A user can follow multiple others.
    stories[] userStories;   // A user can follow multiple stories.
    education[] userEducation;  // A user can follow multiple education.
|};

public type posts record {|
    // @sql:Generated
    // readonly int id;
    readonly string id;
    string? img_url;
    string? video_url;
    time:Utc created_at;
    users user;
    string caption;

    // Relations
    comments[] postComments; // A post can have multiple comments.
    likes[] postLikes;
	notifications[] notifications;       // A post can have multiple likes.
|};

public type comments record {|
    // @sql:Generated
    // readonly int id;
    readonly string id;
    string content;
    time:Utc created_at;
    users user;
    posts post;
|};

public type likes record {|
    // @sql:Generated
    // readonly int id;
    readonly string id;
    users user;
    posts post;
    time:Utc created_at;
    boolean active;   
|};

public type handshakes record {|
    //  @sql:Generated
    // readonly int id;
    readonly string id;
    users handshaker;
    users handshakee;
    time:Utc created_at; 
    boolean accepted;
|};

public type notifications record {|
    readonly string id;
    users receipent;
    NotificationType notification_type;
    users related_user;
    posts related_post;
    boolean read;
    time:Utc created_at;

|};





