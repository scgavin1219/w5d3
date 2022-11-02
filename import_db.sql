PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS question_follows;
DROP TABLE IF EXISTS replies;
DROP TABLE IF EXISTS question_likes;

CREATE TABLE users (
id INTEGER PRIMARY KEY,  
fname TEXT NOT NULL,
lname TEXT NOT NULL);


CREATE TABLE questions(
    id INTEGER PRIMARY KEY,
    title TEXT NOT NULL, 
    body TEXT NOT NULL,
    user_id INTEGER NOT NULL, 

    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE question_follows(
    id INTEGER PRIMARY KEY,
    question_id INTEGER NOT NULL, 
    user_id INTEGER NOT NULL, 

    FOREIGN KEY (user_id) REFERENCES users(id)
    FOREIGN KEY (question_id) REFERENCES questions(id)
);


CREATE TABLE replies(
    id INTEGER PRIMARY KEY,
    subject_question INTEGER NOT NULL,
    parent_replay INTEGER, 
    body TEXT NOT NULL,
    user_id INTEGER NOT NULL, 

    FOREIGN KEY (user_id) REFERENCES users(id)
    FOREIGN KEY (subject_question) REFERENCES questions(id)
);


CREATE TABLE question_likes(
    id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    question_id INTEGER NOT NULL,

    FOREIGN KEY (question_id) REFERENCES questions(id)
    FOREIGN KEY (user_id) REFERENCES users(id)
);

INSERT INTO
    