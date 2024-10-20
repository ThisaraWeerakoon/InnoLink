drop schema innolink_db;
create schema innolink_db;
use innolink_db;

-- AUTO-GENERATED FILE.

-- This file is an auto-generated file by Ballerina persistence layer for model.
-- Please verify the generated scripts and execute them against the target DB server.

DROP TABLE IF EXISTS `stories`;
DROP TABLE IF EXISTS `education`;
DROP TABLE IF EXISTS `comments`;
DROP TABLE IF EXISTS `handshakes`;
DROP TABLE IF EXISTS `likes`;
DROP TABLE IF EXISTS `posts`;
DROP TABLE IF EXISTS `notifications`;
DROP TABLE IF EXISTS `users`;

CREATE TABLE `users` (
	`id` VARCHAR(191) NOT NULL,
	`name` VARCHAR(191),
	`email` VARCHAR(191) NOT NULL,
	`first_name` VARCHAR(191) NOT NULL,
	`last_name` VARCHAR(191) NOT NULL,
	`dob` DATE NOT NULL,
	`created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`profile_pic_url` VARCHAR(191),
	`banner_url` VARCHAR(191),
	`password` VARCHAR(191) NOT NULL,
	`about_me` VARCHAR(191),
	PRIMARY KEY(`id`)
);

CREATE TABLE `notifications` (
	`id` VARCHAR(191) NOT NULL,
	`referenceId` VARCHAR(191) NOT NULL,
	`created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`read` BOOLEAN NOT NULL,
	`notify_type` ENUM('LIKE', 'COMMENT', 'HANDSHAKE_REQUEST', 'HANDSHAKE_ACCEPTED', 'INVEST_REQUEST', 'INVEST_ACCEPTED') NOT NULL,
	`recepientId` VARCHAR(191) NOT NULL,
	FOREIGN KEY(`recepientId`) REFERENCES `users`(`id`) ON DELETE CASCADE ON UPDATE CASCADE,
	`senderId` VARCHAR(191) NOT NULL,
	FOREIGN KEY(`senderId`) REFERENCES `users`(`id`) ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY(`id`)
);

CREATE TABLE `posts` (
	`id` VARCHAR(191) NOT NULL,
	`img_url` VARCHAR(191),
	`video_url` VARCHAR(191),
	`created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`caption` VARCHAR(191) NOT NULL,
	`userId` VARCHAR(191) NOT NULL,
	FOREIGN KEY(`userId`) REFERENCES `users`(`id`) ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY(`id`)
);

CREATE TABLE `likes` (
	`id` VARCHAR(191) NOT NULL,
	`created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`active` BOOLEAN NOT NULL,
	`userId` VARCHAR(191) NOT NULL,
	FOREIGN KEY(`userId`) REFERENCES `users`(`id`) ON DELETE CASCADE ON UPDATE CASCADE,
	`postId` VARCHAR(191) NOT NULL,
	FOREIGN KEY(`postId`) REFERENCES `posts`(`id`) ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY(`id`)
);

CREATE TABLE `handshakes` (
	`id` VARCHAR(191) NOT NULL,
	`created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`status` ENUM('PENDING', 'ACCEPTED', 'REJECTED') NOT NULL,
	`handshakerId` VARCHAR(191) NOT NULL,
	FOREIGN KEY(`handshakerId`) REFERENCES `users`(`id`) ON DELETE CASCADE ON UPDATE CASCADE,
	`handshakeeId` VARCHAR(191) NOT NULL,
	FOREIGN KEY(`handshakeeId`) REFERENCES `users`(`id`) ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY(`id`)
);

CREATE TABLE `comments` (
	`id` VARCHAR(191) NOT NULL,
	`content` VARCHAR(191) NOT NULL,
	`media` VARCHAR(191),
	`created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`userId` VARCHAR(191) NOT NULL,
	FOREIGN KEY(`userId`) REFERENCES `users`(`id`) ON DELETE CASCADE ON UPDATE CASCADE,
	`postId` VARCHAR(191) NOT NULL,
	FOREIGN KEY(`postId`) REFERENCES `posts`(`id`) ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY(`id`)
);

CREATE TABLE `education` (
	`id` VARCHAR(191) NOT NULL,
	`institution` VARCHAR(191) NOT NULL,
	`start_year` INT NOT NULL,
	`end_year` INT,
	`degree` VARCHAR(191),
	`field_of_study` VARCHAR(191),
	`userId` VARCHAR(191) NOT NULL,
	FOREIGN KEY(`userId`) REFERENCES `users`(`id`) ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY(`id`)
);

CREATE TABLE `stories` (
	`id` VARCHAR(191) NOT NULL,
	`name` VARCHAR(191) NOT NULL,
	`logo_url` VARCHAR(191),
	`start_date` DATE NOT NULL,
	`end_date` DATE,
	`description` VARCHAR(191),
	`domain` ENUM('FINANCE', 'HEALTHCARE', 'EDUCATION', 'ECOMMERCE', 'LOGISTICS', 'ENTERTAINMENT', 'REAL_ESTATE', 'RETAIL', 'MANUFACTURING', 'TELECOMMUNICATIONS', 'HOSPITALITY', 'AUTOMOTIVE', 'TECHNOLOGY'),
	`learning` VARCHAR(191),
	`success` BOOLEAN NOT NULL,
	`usersId` VARCHAR(191) NOT NULL,
	FOREIGN KEY(`usersId`) REFERENCES `users`(`id`) ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY(`id`)
);


CREATE TABLE `invests` (
	`id` VARCHAR(191) NOT NULL,
	`status` ENUM('PENDING', 'ACCEPTED', 'REJECTED') DEFAULT 'PENDING' NOT NULL,
	`created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`postId` VARCHAR(191) NOT NULL,
	FOREIGN KEY(`postId`) REFERENCES `posts`(`id`),
	`investorId` VARCHAR(191) NOT NULL,
	FOREIGN KEY(`investorId`) REFERENCES `users`(`id`),
	PRIMARY KEY(`id`)
);


use innolink_db;



-- function that returns the count of active likes for a given post
DELIMITER $$

CREATE FUNCTION `get_like_count` (`postId` VARCHAR(191))
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE like_count INT;

    -- Count the number of active likes for the given post
    SELECT COUNT(*)
    INTO like_count
    FROM likes
    WHERE postId = postId
      AND active = TRUE;

    RETURN like_count;
END $$

DELIMITER ;

-- function that returns the count of comments for a given post
DELIMITER $$

CREATE FUNCTION `get_comment_count` (`postId` VARCHAR(191))
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE comment_count INT;

    -- Count the number of comments for the given post
    SELECT COUNT(*)
    INTO comment_count
    FROM comments
    WHERE postId = postId;

    RETURN comment_count;
END $$

DELIMITER ;



-- SQL Stored Procedure to Get All Handshaked Users' Details for a Given User
DELIMITER $$

CREATE PROCEDURE get_handshaked_users_details(IN given_user_id VARCHAR(191))
BEGIN
    SELECT 
        u.*  -- Select all columns from the users table
    FROM 
        handshakes h
    JOIN 
        users u
        ON (CASE 
            WHEN h.handshakerId = given_user_id THEN h.handshakeeId 
            ELSE h.handshakerId 
            END) = u.id
    WHERE 
        (h.handshakerId = given_user_id OR h.handshakeeId = given_user_id)
        AND h.status = 'ACCEPTED';
END $$

DELIMITER ;


-- Trigger for Inserting Comment Notification 
DELIMITER $$

CREATE TRIGGER `after_comment_insert` 
AFTER INSERT ON `comments`
FOR EACH ROW
BEGIN
    -- Insert a notification for the post owner when a comment is added
    INSERT INTO notifications (id, recepientId, senderId, notify_type, referenceId, created_at, `read`) 
    VALUES (UUID(), 
            (SELECT posts.userId FROM posts WHERE posts.id = NEW.postId),  -- The post owner
            NEW.userId,  -- The commenter
            'COMMENT',   -- Notification type
            NEW.id,      -- Comment ID as reference
            NOW(), 
            FALSE);
END $$

DELIMITER ;

-- Trigger for Deleting Comment Notification
DELIMITER $$

CREATE TRIGGER `after_comment_delete` 
AFTER DELETE ON `comments`
FOR EACH ROW
BEGIN
    -- Delete the notification when the comment is deleted
    DELETE FROM notifications 
    WHERE notify_type = 'COMMENT' AND referenceId = OLD.id;
END $$

DELIMITER ;


-- Trigger for Inserting Like Notification
DELIMITER $$

CREATE TRIGGER `after_like_insert` 
AFTER INSERT ON `likes`
FOR EACH ROW
BEGIN
    IF NEW.active THEN
        -- Insert a notification for the post owner when a like is added
        INSERT INTO notifications (id, recepientId, senderId, notify_type, referenceId, created_at, `read`) 
        VALUES (UUID(), 
                (SELECT posts.userId FROM posts WHERE posts.id = NEW.postId),  -- The post owner
                NEW.userId,   -- The user who liked
                'LIKE',       -- Notification type
                NEW.id,       -- Like ID as reference
                NOW(),
                FALSE);
    END IF;
END $$

DELIMITER ;

-- Trigger for Updating Like Notification
DELIMITER $$

CREATE TRIGGER `after_like_update` 
AFTER UPDATE ON `likes`
FOR EACH ROW
BEGIN
    IF OLD.active AND NOT NEW.active THEN
        -- If the like becomes inactive, delete the notification
        DELETE FROM notifications 
        WHERE notify_type = 'LIKE' AND referenceId = OLD.id;
    END IF;
END $$

DELIMITER ;

-- Trigger for Deleting Like Notification
DELIMITER $$

CREATE TRIGGER `after_like_delete` 
AFTER DELETE ON `likes`
FOR EACH ROW
BEGIN
    -- Delete the notification when the like is deleted
    DELETE FROM notifications 
    WHERE notify_type = 'LIKE' AND referenceId = OLD.id;
END $$

DELIMITER ;

-- Trigger for Inserting Handshake (Friend Request) Notification
DELIMITER $$

CREATE TRIGGER `after_handshake_insert` 
AFTER INSERT ON `handshakes`
FOR EACH ROW
BEGIN
    -- Insert a notification for the handshake request
    INSERT INTO notifications (id, recepientId, senderId, notify_type, referenceId, created_at, `read`) 
    VALUES (UUID(), 
            NEW.handshakeeId,  -- The recipient of the friend request
            NEW.handshakerId,  -- The sender of the friend request
            'HANDSHAKE_REQUEST',  -- Notification type
            NEW.id,  -- Handshake ID as reference
            NOW(),
            FALSE);
END $$

DELIMITER ;

-- Trigger for Deleting Handshake Notification
DELIMITER $$

CREATE TRIGGER `after_handshake_delete` 
AFTER DELETE ON `handshakes`
FOR EACH ROW
BEGIN
    -- Delete the notification when the handshake request is deleted
    DELETE FROM notifications 
    WHERE notify_type = 'HANDSHAKE_REQUEST' AND referenceId = OLD.id;
END $$

DELIMITER ;

-- Trigger for Updating Handshake Status to "Accepted" or "Rejected"
DELIMITER $$

CREATE TRIGGER `after_handshake_update` 
AFTER UPDATE ON `handshakes`
FOR EACH ROW
BEGIN
    IF NEW.status = 'ACCEPTED' THEN
        -- Insert a notification for the handshake acceptance
        INSERT INTO notifications (id, recepientId, senderId, notify_type, referenceId, created_at, `read`) 
        VALUES (UUID(),
                NEW.handshakerId,  -- The sender of the request (who will receive the notification)
                NEW.handshakeeId,  -- The recipient of the request (who accepted)
                'HANDSHAKE_ACCEPTED',  -- Notification type
                NEW.id,  -- Handshake ID as reference
                NOW(),
                FALSE);
    ELSEIF NEW.status = 'REJECTED' THEN
        -- If the request is rejected, delete the handshake and notification
        DELETE FROM notifications 
        WHERE notify_type = 'HANDSHAKE_REQUEST' AND referenceId = NEW.id;
        DELETE FROM handshakes WHERE id = NEW.id;
    END IF;
END $$

DELIMITER ;

-- Trigger for Inserting Invest Notification
DELIMITER $$

CREATE TRIGGER `after_invest_insert` 
AFTER INSERT ON `invests`
FOR EACH ROW
BEGIN
    -- Insert a notification for the invest request
    INSERT INTO notifications (id, recepientId, senderId, notify_type, referenceId, created_at, `read`) 
    VALUES (UUID(), 
            (SELECT posts.userId FROM posts WHERE posts.id = NEW.postId),  -- The recipient of the invest request
            NEW.investorId,  -- The sender of the investor request
            'INVEST_REQUEST',  -- Notification type
            NEW.id,  -- Handshake ID as reference
            NOW(),
            FALSE);
END $$

DELIMITER ;

-- Trigger for Deleting Invest Notification
DELIMITER $$

CREATE TRIGGER `after_invest_delete` 
AFTER DELETE ON `invests`
FOR EACH ROW
BEGIN
    -- Delete the notification when the invest request is deleted
    DELETE FROM notifications 
    WHERE notify_type = 'INVEST_REQUEST' AND referenceId = OLD.id;
END $$

DELIMITER ;

-- Trigger for Updating Invest Status to "Accepted" or "Rejected"
DELIMITER $$

CREATE TRIGGER `after_invest_update` 
AFTER UPDATE ON `invests`
FOR EACH ROW
BEGIN
    IF NEW.status = 'ACCEPTED' THEN
        -- Insert a notification for the handshake acceptance
        INSERT INTO notifications (id, recepientId, senderId, notify_type, referenceId, created_at, `read`) 
        VALUES (UUID(),
                NEW.investorId,  -- The sender of the request (who will receive the notification that accepted your request)
                (SELECT posts.userId FROM posts WHERE posts.id = NEW.postId),  -- The recipient of the request (who accepted)
                'REQUEST_ACCEPTED',  -- Notification type
                NEW.id,  -- Invest ID as reference
                NOW(),
                FALSE);
    ELSEIF NEW.status = 'REJECTED' THEN
        -- If the request is rejected, delete the invest and notification
        DELETE FROM notifications 
        WHERE notify_type = 'INVEST_REQUEST' AND referenceId = NEW.id;
        DELETE FROM invests WHERE id = NEW.id;
    END IF;
END $$

DELIMITER ;

-- Trigger to Delete Notification When read is Updated to TRUE
DELIMITER $$

CREATE TRIGGER `after_read_update`
AFTER UPDATE ON `notifications`
FOR EACH ROW
BEGIN
    -- Check if the `read` status has changed to TRUE
    IF NEW.read = TRUE THEN
        DELETE FROM notifications WHERE id = NEW.id;
    END IF;
END $$

DELIMITER ;


-- Example Raw Passwords
-- u1: u1
-- u2: u2
-- u3: u3
-- u4: u4
-- u5: u5
-- u6: u6
-- u7: u7
-- u8: u8
-- u9: u9
-- u10: u10


-- Populate users table with 10 users
INSERT INTO `users` (`id`, `name`, `email`, `first_name`, `last_name`, `dob`, `created_at`, `profile_pic_url`, `banner_url`, `password`, `about_me`)
VALUES 
('u1', 'John Doe', 'john@example.com', 'John', 'Doe', '1990-01-01', NOW(), 'https://example.com/john.jpg', 'https://example.com/banner1.jpg', 'bb82030dbc2bcaba32a90bf2e207a84a856fc5f033b77c480836ab6f77f40f19', 'I love technology.'),
('u2', 'Jane Smith', 'jane@example.com', 'Jane', 'Smith', '1992-05-15', NOW(), 'https://example.com/jane.jpg', 'https://example.com/banner2.jpg', '6ca202c88e549dff68c09bfafbfc60b2fac074debc1e6777e9ba4b6c703ed114', 'Software engineer and artist.'),
('u3', 'Alex Johnson', 'alex@example.com', 'Alex', 'Johnson', '1988-08-25', NOW(), 'https://example.com/alex.jpg', 'https://example.com/banner3.jpg', '011e39efe22590f4a339ad19cd180f4d855e32feba602d1ec8e154780838c99c', 'Passionate about AI.'),
('u4', 'Emily Davis', 'emily@example.com', 'Emily', 'Davis', '1995-02-14', NOW(), 'https://example.com/emily.jpg', 'https://example.com/banner4.jpg', 'e9c981a479986215bab0bf6c32efefa14852534b138c3509d8369edd510363da', 'Loves to travel.'),
('u5', 'Michael Brown', 'michael@example.com', 'Michael', 'Brown', '1991-12-12', NOW(), 'https://example.com/michael.jpg', 'https://example.com/banner5.jpg', '5850a03e801ffb108da1160e3373979443004b9e670addf33000dca9045fa413', 'Photographer.'),
('u6', 'Sarah Wilson', 'sarah@example.com', 'Sarah', 'Wilson', '1993-03-03', NOW(), 'https://example.com/sarah.jpg', 'https://example.com/banner6.jpg', '71ea5f5b962198c5d0532765e7e92cdd0519456bb3d735297e535dcab17bf84d', 'Outdoor enthusiast.'),
('u7', 'David Lee', 'david@example.com', 'David', 'Lee', '1989-09-09', NOW(), 'https://example.com/david.jpg', 'https://example.com/banner7.jpg', 'e8180000fa67e824043aa522c6743de57dbc5de1d39d5483acb618b699a9dd00', 'Software developer.'),
('u8', 'Olivia Martinez', 'olivia@example.com', 'Olivia', 'Martinez', '1994-11-11', NOW(), 'https://example.com/olivia.jpg', 'https://example.com/banner8.jpg', 'c89951a24c6ca28c13fd1cfdc646b2b656d69e61a92b91023be7eb58eb914b6b', 'Food blogger.'),
('u9', 'James Clark', 'james@example.com', 'James', 'Clark', '1990-06-06', NOW(), 'https://example.com/james.jpg', 'https://example.com/banner9.jpg', '553f26abeeebe4be18603f3c15bbf6cd3106002e869ce9275054868fb0d610af', 'Gamer and coder.'),
('u10', 'Sophia Turner', 'sophia@example.com', 'Sophia', 'Turner', '1987-07-07', NOW(), 'https://example.com/sophia.jpg', 'https://example.com/banner10.jpg', '105a9cef3903c748eb63d42ec006c9b46cdab99141b0cd80176026b76cbb69fd', 'Fitness trainer.');

-- Populate posts table with 30 posts (3 per user)
INSERT INTO `posts` (`id`, `img_url`, `video_url`, `created_at`, `caption`, `userId`)
VALUES 
('p1', 'https://example.com/img1.jpg', NULL, NOW(), 'Enjoying the sunset!', 'u1'),
('p2', NULL, 'https://example.com/video1.mp4', NOW(), 'Check out my latest vlog!', 'u1'),
('p3', 'https://example.com/img2.jpg', NULL, NOW(), 'My new project update.', 'u1'),
('p4', 'https://example.com/img3.jpg', NULL, NOW(), 'Hiking adventure.', 'u2'),
('p5', NULL, 'https://example.com/video2.mp4', NOW(), 'New art video!', 'u2'),
('p6', 'https://example.com/img4.jpg', NULL, NOW(), 'Software project!', 'u2'),
('p7', 'https://example.com/img5.jpg', NULL, NOW(), 'Beautiful landscape.', 'u3'),
('p8', NULL, 'https://example.com/video3.mp4', NOW(), 'AI research vlog.', 'u3'),
('p9', 'https://example.com/img6.jpg', NULL, NOW(), 'Tech conference!', 'u3'),
('p10', 'https://example.com/img7.jpg', NULL, NOW(), 'Traveling to Japan!', 'u4'),
('p11', NULL, 'https://example.com/video4.mp4', NOW(), 'My cooking journey.', 'u4'),
('p12', 'https://example.com/img8.jpg', NULL, NOW(), 'Adventure trip!', 'u4'),
('p13', 'https://example.com/img9.jpg', NULL, NOW(), 'Captured this view.', 'u5'),
('p14', NULL, 'https://example.com/video5.mp4', NOW(), 'New vlog update.', 'u5'),
('p15', 'https://example.com/img10.jpg', NULL, NOW(), 'Photography tips.', 'u5'),
('p16', 'https://example.com/img11.jpg', NULL, NOW(), 'Health and fitness.', 'u6'),
('p17', NULL, 'https://example.com/video6.mp4', NOW(), 'Outdoor adventures.', 'u6'),
('p18', 'https://example.com/img12.jpg', NULL, NOW(), 'Mountain hiking.', 'u6'),
('p19', 'https://example.com/img13.jpg', NULL, NOW(), 'Coding bootcamp!', 'u7'),
('p20', NULL, 'https://example.com/video7.mp4', NOW(), 'Software dev update.', 'u7'),
('p21', 'https://example.com/img14.jpg', NULL, NOW(), 'Tech innovations.', 'u7'),
('p22', 'https://example.com/img15.jpg', NULL, NOW(), 'Fitness routine!', 'u8'),
('p23', NULL, 'https://example.com/video8.mp4', NOW(), 'New workout video.', 'u8'),
('p24', 'https://example.com/img16.jpg', NULL, NOW(), 'Healthy eating tips.', 'u8'),
('p25', 'https://example.com/img17.jpg', NULL, NOW(), 'Gaming setup reveal.', 'u9'),
('p26', NULL, 'https://example.com/video9.mp4', NOW(), 'Game streaming.', 'u9'),
('p27', 'https://example.com/img18.jpg', NULL, NOW(), 'Tech upgrades.', 'u9'),
('p28', 'https://example.com/img19.jpg', NULL, NOW(), 'Fitness inspiration.', 'u10'),
('p29', NULL, 'https://example.com/video10.mp4', NOW(), 'Workout transformation.', 'u10'),
('p30', 'https://example.com/img20.jpg', NULL, NOW(), 'Fitness gear review.', 'u10');



-- Populate likes table with 30 likes (3 per user)
INSERT INTO `likes` (`id`, `created_at`, `active`, `userId`, `postId`)
VALUES 
('l1', NOW(), TRUE, 'u1', 'p4'),
('l2', NOW(), TRUE, 'u1', 'p5'),
('l3', NOW(), TRUE, 'u1', 'p6'),
('l4', NOW(), TRUE, 'u2', 'p7'),
('l5', NOW(), TRUE, 'u2', 'p8'),
('l6', NOW(), TRUE, 'u2', 'p9'),
('l7', NOW(), TRUE, 'u3', 'p10'),
('l8', NOW(), TRUE, 'u3', 'p11'),
('l9', NOW(), TRUE, 'u3', 'p12'),
('l10', NOW(), TRUE, 'u4', 'p13'),
('l11', NOW(), TRUE, 'u4', 'p14'),
('l12', NOW(), TRUE, 'u4', 'p15'),
('l13', NOW(), TRUE, 'u5', 'p16'),
('l14', NOW(), TRUE, 'u5', 'p17'),
('l15', NOW(), TRUE, 'u5', 'p18'),
('l16', NOW(), TRUE, 'u6', 'p19'),
('l17', NOW(), TRUE, 'u6', 'p20'),
('l18', NOW(), TRUE, 'u6', 'p21'),
('l19', NOW(), TRUE, 'u7', 'p22'),
('l20', NOW(), TRUE, 'u7', 'p23'),
('l21', NOW(), TRUE, 'u7', 'p24'),
('l22', NOW(), TRUE, 'u8', 'p25'),
('l23', NOW(), TRUE, 'u8', 'p26'),
('l24', NOW(), TRUE, 'u8', 'p27'),
('l25', NOW(), TRUE, 'u9', 'p28'),
('l26', NOW(), TRUE, 'u9', 'p29'),
('l27', NOW(), TRUE, 'u9', 'p30'),
('l28', NOW(), TRUE, 'u10', 'p1'),
('l29', NOW(), TRUE, 'u10', 'p2'),
('l30', NOW(), TRUE, 'u10', 'p3');

-- Populate handshakes table with 15 handshake requests (some pending, some accepted)
INSERT INTO `handshakes` (`id`, `created_at`, `status`, `handshakerId`, `handshakeeId`)
VALUES 
('h1', NOW(), 'pending', 'u1', 'u2'),    -- John sent a request to Jane
('h2', NOW(), 'accepted', 'u1', 'u3'),   -- John and Alex are now friends
('h3', NOW(), 'pending', 'u2', 'u4'),    -- Jane sent a request to Emily
('h4', NOW(), 'accepted', 'u2', 'u5'),   -- Jane and Michael are friends
('h5', NOW(), 'accepted', 'u3', 'u6'),   -- Alex and Sarah are friends
('h6', NOW(), 'pending', 'u4', 'u1'),    -- Emily sent a request to John
('h7', NOW(), 'accepted', 'u4', 'u7'),   -- Emily and David are friends
('h8', NOW(), 'pending', 'u1', 'u10'),    -- Michael sent a request to Sophia
('h9', NOW(), 'accepted', 'u6', 'u8'),   -- Sarah and Olivia are friends
('h10', NOW(), 'pending', 'u7', 'u3'),   -- David sent a request to Alex
('h11', NOW(), 'accepted', 'u8', 'u9'),  -- Olivia and James are friends
('h12', NOW(), 'pending', 'u9', 'u10'),  -- James sent a request to Sophia
('h13', NOW(), 'accepted', 'u9', 'u1'),  -- James and John are friends
('h14', NOW(), 'pending', 'u10', 'u5'),  -- Sophia sent a request to Michael
('h15', NOW(), 'accepted', 'u7', 'u10'); -- David and Sophia are friends


-- Populate comments table with 30 comments
INSERT INTO `comments` (`id`, `created_at`, `content`, `userId`, `postId`) VALUES 
('c1', NOW(), 'Great post! Really enjoyed this.', 'u1', 'p1'),
('c2', NOW(), 'Thanks for sharing!', 'u2', 'p1'),
('c3', NOW(), 'Very informative!', 'u3', 'p2'),
('c4', NOW(), 'I learned a lot from this post.', 'u1', 'p2'),
('c5', NOW(), 'Interesting perspective!', 'u2', 'p3'),
('c6', NOW(), 'I completely agree!', 'u3', 'p1'),
('c7', NOW(), 'Looking forward to more posts like this!', 'u1', 'p3'),
('c8', NOW(), 'Can you elaborate on this?', 'u3', 'p2'),
('c9', NOW(), 'Loved the visuals!', 'u2', 'p4'),
('c10', NOW(), 'Amazing video!', 'u3', 'p5'),
('c11', NOW(), 'This recipe looks delicious!', 'u1', 'p11'),
('c12', NOW(), 'What a beautiful landscape!', 'u2', 'p10'),
('c13', NOW(), 'Hiking goals!', 'u3', 'p12'),
('c14', NOW(), 'This is such a creative idea!', 'u1', 'p5'),
('c15', NOW(), 'Great coding tips!', 'u3', 'p19'),
('c16', NOW(), 'Can’t wait to try this out!', 'u2', 'p10'),
('c17', NOW(), 'Inspirational story!', 'u1', 'p6'),
('c18', NOW(), 'Your fitness journey is motivating!', 'u3', 'p8'),
('c19', NOW(), 'Love your gaming setup!', 'u2', 'p25'),
('c20', NOW(), 'Very cool project!', 'u1', 'p21'),
('c21', NOW(), 'I’ve tried this too, it works!', 'u3', 'p14'),
('c22', NOW(), 'What’s the best part about it?', 'u2', 'p16'),
('c23', NOW(), 'You should do more vlogs!', 'u1', 'p8'),
('c24', NOW(), 'This should go viral!', 'u3', 'p22'),
('c25', NOW(), 'Your travel videos are amazing!', 'u1', 'p12'),
('c26', NOW(), 'So true, keep it up!', 'u2', 'p27'),
('c27', NOW(), 'Very relatable content!', 'u3', 'p28'),
('c28', NOW(), 'Keep inspiring us!', 'u1', 'p30'),
('c29', NOW(), 'I love this!', 'u2', 'p29'),
('c30', NOW(), 'Awesome job!', 'u3', 'p30');


-- Populate education table with entries for each user
INSERT INTO `education` (`id`, `userId`, `institution`, `degree`, `field_of_study`, `start_year`, `end_year`) VALUES 
('e1', 'u1', 'University of Technology', 'Bachelor', 'Computer Science', 2010, 2014),
('e2', 'u1', 'Stanford University', 'Master', 'Artificial Intelligence', 2015, 2017),
('e3', 'u2', 'Art Institute', 'Bachelor', 'Fine Arts', 2011, 2015),
('e4', 'u2', 'Harvard University', 'Master', 'Design', 2016, 2018),
('e5', 'u3', 'MIT', 'Bachelor', 'Electrical Engineering', 2006, 2010),
('e6', 'u3', 'UC Berkeley', 'Master', 'Data Science', 2011, 2013),
('e7', 'u4', 'University of Adventure', 'Bachelor', 'Travel & Tourism', 2012, 2016),
('e8', 'u4', 'University of Gastronomy', 'Diploma', 'Culinary Arts', 2017, 2018),
('e9', 'u5', 'School of Photography', 'Bachelor', 'Photography', 2011, 2015),
('e10', 'u5', 'New York Film Academy', 'Certificate', 'Film Production', 2016, 2017),
('e11', 'u6', 'Outdoor Adventure College', 'Associate', 'Outdoor Education', 2015, 2017),
('e12', 'u6', 'Health and Fitness Academy', 'Certification', 'Personal Training', 2018, 2019),
('e13', 'u7', 'University of Software Development', 'Bachelor', 'Computer Science', 2007, 2011),
('e14', 'u7', 'Columbia University', 'Master', 'Cybersecurity', 2012, 2014),
('e15', 'u8', 'Culinary Arts School', 'Bachelor', 'Culinary Arts', 2013, 2017),
('e16', 'u8', 'Food Blogger Academy', 'Certificate', 'Blogging & Marketing', 2018, 2019),
('e17', 'u9', 'Game Design Institute', 'Bachelor', 'Game Development', 2008, 2012),
('e18', 'u9', 'University of Tech Innovations', 'Master', 'Computer Games', 2013, 2015),
('e19', 'u10', 'Fitness Training Academy', 'Bachelor', 'Kinesiology', 2009, 2013),
('e20', 'u10', 'University of Sports Science', 'Master', 'Exercise Science', 2014, 2016);


-- Populate stories table with multiple entries for each user, including more failed startups
INSERT INTO `stories` (`id`, `name`, `logo_url`, `start_date`, `end_date`, `description`, `domain`, `learning`, `success`, `usersId`) VALUES 
('s1', 'Tech Innovations', 'https://example.com/logo1.png', '2023-01-01', '2023-01-31', 'A deep dive into the latest tech innovations.', 'TECHNOLOGY', 'Understanding new technologies', TRUE, 'u1'),
('s2', 'Healthy Living', 'https://example.com/logo2.png', '2023-02-01', '2023-02-28', 'Exploring healthy living tips and tricks.', 'HEALTHCARE', 'Learning about health benefits', TRUE, 'u1'),
('s3', 'Failed Tech Startup', 'https://example.com/logo3.png', '2023-03-01', '2023-04-01', 'A tech startup that couldn\'t find its market fit.', 'TECHNOLOGY', 'Understanding market needs', FALSE, 'u1'),
('s4', 'Artistic Journey', 'https://example.com/logo4.png', '2023-04-01', '2023-04-30', 'Documenting my journey as an artist.', 'ENTERTAINMENT', 'Growth as a creator', TRUE, 'u2'),
('s5', 'Investment Strategies', 'https://example.com/logo5.png', '2023-05-01', '2023-05-31', 'Sharing successful investment strategies.', 'FINANCE', 'Learning to invest wisely', TRUE, 'u2'),
('s6', 'Budgeting App Failure', 'https://example.com/logo6.png', '2023-06-01', '2023-06-30', 'An app designed to manage budgets that failed to gain users.', 'FINANCE', 'Understanding user needs', FALSE, 'u2'),
('s7', 'AI Research Insights', 'https://example.com/logo7.png', '2023-07-01', '2023-07-31', 'Insights from recent AI research.', 'TECHNOLOGY', 'Deepening AI knowledge', TRUE, 'u3'),
('s8', 'Coding Bootcamp', 'https://example.com/logo8.png', '2023-08-01', '2023-08-31', 'A bootcamp experience in coding.', 'EDUCATION', 'Learning programming languages', TRUE, 'u3'),
('s9', 'Game Development Gone Wrong', 'https://example.com/logo9.png', '2023-09-01', '2023-09-30', 'A game that failed to launch due to poor market research.', 'ENTERTAINMENT', 'Understanding game dynamics', FALSE, 'u3'),
('s10', 'Travel Adventures', 'https://example.com/logo10.png', '2023-10-01', '2023-10-31', 'Documenting my travel experiences.', 'ENTERTAINMENT', 'Cultural insights gained', TRUE, 'u4'),
('s11', 'Culinary Delights', 'https://example.com/logo11.png', '2023-11-01', '2023-11-30', 'Sharing my cooking journey.', 'ENTERTAINMENT', 'Learning culinary skills', TRUE, 'u4'),
('s12', 'Failed Restaurant', 'https://example.com/logo12.png', '2023-12-01', '2023-12-15', 'A restaurant that struggled with management and closed.', 'RETAIL', 'Understanding restaurant management', FALSE, 'u4'),
('s13', 'Nature Captured', 'https://example.com/logo13.png', '2023-01-05', '2023-01-20', 'Exploring nature through photography.', 'ENTERTAINMENT', 'Appreciating nature', TRUE, 'u5'),
('s14', 'Adventure Travels', 'https://example.com/logo14.png', '2023-02-01', '2023-02-20', 'Documenting my adventures.', 'ENTERTAINMENT', 'Gaining travel experience', TRUE, 'u5'),
('s15', 'Outdoor Activity App Failure', 'https://example.com/logo15.png', '2023-03-01', '2023-03-20', 'An app that didn\'t meet user needs and failed.', 'HEALTHCARE', 'Understanding app development', FALSE, 'u5'),
('s16', 'Fitness Journey', 'https://example.com/logo16.png', '2023-04-01', '2023-04-30', 'My path to a healthier lifestyle.', 'HEALTHCARE', 'Improving health habits', TRUE, 'u6'),
('s17', 'Outdoor Adventures', 'https://example.com/logo17.png', '2023-05-01', '2023-05-31', 'Exploring the great outdoors.', 'ENTERTAINMENT', 'Connecting with nature', TRUE, 'u6'),
('s18', 'Wellness Retreat Gone Wrong', 'https://example.com/logo18.png', '2023-06-01', '2023-06-30', 'A wellness retreat that failed due to poor planning.', 'HEALTHCARE', 'Learning from failures', FALSE, 'u6'),
('s19', 'Game Development', 'https://example.com/logo19.png', '2023-07-01', '2023-07-31', 'My journey in game development.', 'ENTERTAINMENT', 'Learning game design', TRUE, 'u7'),
('s20', 'Software Innovations', 'https://example.com/logo20.png', '2023-08-01', '2023-08-31', 'Discussing software innovations.', 'TECHNOLOGY', 'Staying updated on software', TRUE, 'u7'),
('s21', 'Mobile Game Failure', 'https://example.com/logo21.png', '2023-09-01', '2023-09-30', 'A mobile game that failed to attract players.', 'ENTERTAINMENT', 'Understanding mobile gaming', FALSE, 'u7'),
('s22', 'Healthy Recipes', 'https://example.com/logo22.png', '2023-10-01', '2023-10-31', 'Sharing my healthy recipes.', 'HEALTHCARE', 'Cooking nutritious meals', TRUE, 'u8'),
('s23', 'Restaurant Reviews', 'https://example.com/logo23.png', '2023-11-01', '2023-11-30', 'Reviewing local restaurants.', 'RETAIL', 'Exploring food options', TRUE, 'u8'),
('s24', 'Failed Food Truck', 'https://example.com/logo24.png', '2023-12-01', '2023-12-31', 'A food truck that failed due to location issues.', 'RETAIL', 'Understanding food service', FALSE, 'u8'),
('s25', 'Gamer Life', 'https://example.com/logo25.png', '2023-01-10', '2023-01-20', 'Living the gamer lifestyle.', 'ENTERTAINMENT', 'Engaging with the gaming community', TRUE, 'u9'),
('s26', 'Game Development Insights', 'https://example.com/logo26.png', '2023-02-10', '2023-02-20', 'Insights into game development.', 'ENTERTAINMENT', 'Learning game mechanics', TRUE, 'u9'),
('s27', 'Tech Reviews', 'https://example.com/logo27.png', '2023-03-10', '2023-03-20', 'Reviewing the latest tech gadgets.', 'TECHNOLOGY', 'Staying updated on technology', TRUE, 'u9'),
('s28', 'Fitness Challenges', 'https://example.com/logo28.png', '2023-04-10', '2023-04-20', 'Participating in fitness challenges.', 'HEALTHCARE', 'Improving fitness levels', TRUE, 'u10'),
('s29', 'Personal Training Tips', 'https://example.com/logo29.png', '2023-05-10', '2023-05-20', 'Sharing personal training tips.', 'HEALTHCARE', 'Gaining training knowledge', TRUE, 'u10'),
('s30', 'Fitness App Gone Wrong', 'https://example.com/logo30.png', '2023-06-10', '2023-06-20', 'A fitness app that failed due to lack of features.', 'HEALTHCARE', 'Understanding app development', FALSE, 'u10');