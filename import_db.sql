PRAGMA foreign_keys = ON;

-- DROP TABLE IF EXISTS users;
-- DROP TABLE IF EXISTS questions;
-- DROP TABLE IF EXISTS question_follows;
-- DROP TABLE IF EXISTS replies;
-- DROP TABLE IF EXISTS question_likes;

CREATE TABLE users (
    id INTEGER PRIMARY KEY,  
    fname TEXT NOT NULL,
    lname TEXT NOT NULL
);

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

    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (question_id) REFERENCES questions(id)
);


CREATE TABLE replies(
    id INTEGER PRIMARY KEY,
    subject_question INTEGER NOT NULL,
    parent_reply INTEGER, 
    body TEXT NOT NULL,
    user_id INTEGER NOT NULL, 

    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (subject_question) REFERENCES questions(id)
);

CREATE TABLE question_likes(
    id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    question_id INTEGER NOT NULL,

    FOREIGN KEY (question_id) REFERENCES questions(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

INSERT INTO
  users (fname, lname)
VALUES
  ('Arthur', 'Miller'),
  ('Eugene', 'Neill');

INSERT INTO
  questions (title, body, user_id)
VALUES
  ('Soccer', 'Who is the best player?', (SELECT id FROM users WHERE fname = 'Eugene'));

INSERT INTO
  question_follows (user_id, question_id)
VALUES
  ((SELECT id FROM users WHERE fname = 'Eugene'),(SELECT id FROM questions WHERE title = 'Soccer'));



INSERT INTO
  replies (subject_question, parent_reply, body, user_id)
VALUES
  ((SELECT id FROM questions WHERE title = 'Soccer'),2,'Pele',(SELECT id FROM users WHERE fname = 'Arthur')),
  ((SELECT id FROM questions WHERE title = 'Soccer'),2,'Messi',(SELECT id FROM users WHERE fname = 'Eugene')),
  ((SELECT id FROM questions WHERE title = 'Soccer'),2,'Zidane',(SELECT id FROM users WHERE fname = 'Arthur'));



INSERT INTO
  question_likes (user_id, question_id)
VALUES
  ((SELECT id FROM users WHERE fname = 'Arthur'),(SELECT id FROM questions WHERE title = 'Soccer'));