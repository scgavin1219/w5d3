require_relative 'connection'
require_relative 'reply'
require_relative 'questionfollow'

class User
    attr_accessor :id, :fname, :lname

    def initialize(options)
        @id = options['id']
        @fname = options['fname']
        @lname = options['lname']
    end

     def self.all
        data = DBConnection.instance.execute("SELECT * FROM users")
        data.map { |datum| User.new(datum) }
    end

    def self.find_by_name(first_name,last_name)
        raise 'input must be strings' unless first_name.is_a?(String) && last_name.is_a?(String)
        result = DBConnection.instance.execute(<<-SQL,first_name,last_name)
            SELECT
                *
            FROM
                users
            WHERE 
                fname = ? AND lname = ?
        SQL
        return nil unless result.length > 0
        User.new(result.first)
    end

     def authored_questions
        target = self.id
        result = DBConnection.instance.execute(<<-SQL, target)
            SELECT
                questions.id, title, body
            FROM
                questions
            JOIN users ON questions.user_id = users.id
            WHERE 
                user_id = ? 
        SQL
        return nil unless result.length > 0
        result.map { |x| User.new(x)}
    end

    def authored_replies
        result = Reply.find_by_user_id(self.id)
        return nil unless result.length > 0
        result
    end

    def followed_questions
        QuestionFollow.followed_questions_for_user_id(self.id)
    end

    def liked_questions
        QuestionLike.liked_questions_for_user_id(self.id)
    end

    def average_karma
        result = DBConnection.instance.execute(<<-SQL, self.id )
            SELECT
                CAST(COUNT(question_id) AS FLOAT)/COUNT(DISTINCT(questions.id)) AS average_karma
            FROM
                questions
            LEFT JOIN question_likes ON questions.id = question_likes.question_id
            WHERE
                questions.user_id = ?
        SQL
        return nil unless result.length > 0
        result # .map { |x| User.new(x)}
    end

    def save
        raise "#{self} already in database" if self.id
        DBConnection.instance.execute(<<-SQL, self.fname, self.lname)
        INSERT INTO
            users (fname, lname)
        VALUES
            (?, ?)
        SQL
        self.id = DBConnection.instance.last_insert_row_id
    end
   
end
# Eugene 1 - 1 question - 2 likes / 2 avg karma
# Dylan 2 - 1 question - 1 likes / 1 avg karma
# Diego 3 - 2 question - 1 likes / 0.5 avg karma



# FROM
# questions
# LEFT JOIN question_likes ON questions.user_id = question_likes.user_id
# GROUP BY question_likes.user_id
# HAVING 
# question_likes.user_id = ?