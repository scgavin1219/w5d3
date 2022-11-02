require_relative 'connection'
require_relative 'reply'

class QuestionLike
    attr_accessor :id, :question_id, :user_id
    def self.all
        data = DBConnection.instance.execute("SELECT * FROM question_likes")
        data.map { |datum| QuestionLike.new(datum) }
    end

    def initialize(options)
        @id = options['id']
        @question_id = options['question_id']
        @user_id = options['user_id']
    end

    def self.likers_for_question_id(question_id)
        result = DBConnection.instance.execute(<<-SQL, question_id)
            SELECT
                *
            FROM
                users
            JOIN question_likes ON question_likes.user_id = users.id
            WHERE 
                question_id = ? 
        SQL
        return nil unless result.length > 0
        result.map { |x| User.new(x) }
    end

    def self.num_likes_for_question_id(question_id)
        result = DBConnection.instance.execute(<<-SQL, question_id)
            SELECT
                COUNT(*) AS num_likes
            FROM
                users
            JOIN question_likes ON question_likes.user_id = users.id
            WHERE 
                question_id = ? 

        SQL
        return nil unless result.length > 0
        result
    end

    def self.liked_questions_for_user_id(target)
        result = DBConnection.instance.execute(<<-SQL, target)
            SELECT
                *
            FROM
                question_likes
            JOIN questions ON question_likes.question_id = questions.id
            WHERE 
                question_likes.user_id = ? 
        SQL
        return nil unless result.length > 0
        result.map { |x| Question.new(x) }

    end

    def self.most_liked_questions(n)
        result = DBConnection.instance.execute(<<-SQL, n)
            SELECT
                title, body, questions.user_id --, COUNT(question_likes.user_id) AS likers
            FROM
                question_likes
            JOIN questions ON question_likes.question_id = questions.id
            GROUP BY question_id
            ORDER BY COUNT(question_likes.user_id) DESC
            LIMIT ?
        SQL
        return nil unless result.length > 0
        result.map { |x| Question.new(x) }

    end

end