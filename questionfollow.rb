require_relative 'connection'
require_relative 'reply'
require_relative 'user'
require_relative 'question'

class QuestionFollow
    attr_accessor :id, :question_id, :user_id

    def self.all
        data = DBConnection.instance.execute("SELECT * FROM question_follows")
        data.map { |datum| QuestionFollow.new(datum) }
    end

    def initialize(options)
        @id = options['id']
        @question_id = options['question_id']
        @user_id = options['user_id']
    end

    def self.followers_for_question_id(question_id)
        result = DBConnection.instance.execute(<<-SQL, question_id)
            SELECT
                *
            FROM
                users
            JOIN question_follows ON question_follows.user_id = users.id
            WHERE 
                question_id = ? 
        SQL
        return nil unless result.length > 0
        result.map { |x| User.new(x) }
    end

    def self.followed_questions_for_user_id(target)
        result = DBConnection.instance.execute(<<-SQL, target)
            SELECT
                *
            FROM
                question_follows
            JOIN questions ON question_follows.question_id = questions.id
            WHERE 
                question_follows.user_id = ? 
        SQL
        return nil unless result.length > 0
        result.map { |x| Question.new(x) }
    end
end