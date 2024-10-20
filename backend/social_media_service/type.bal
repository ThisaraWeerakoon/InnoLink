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
    string caption;
|};

public type neweducation record {|
    string institution;
    int start_year;
    int? end_year;
    string? degree;
    string? field_of_study;
    
    
|};

public type newstories record{|

    string name;
    string? logo_url;
    time:Date start_date;
    time:Date? end_date;
    string? description;
    Domain? domain;
    string? learning;
    boolean success;

|};



