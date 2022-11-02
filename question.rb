require_relative 'connection'
require_relative 'reply'

class Question
    attr_accessor :id, :title, :body, :user_id
    def self.all
        data = DBConnection.instance.execute("SELECT * FROM questions")
        data.map { |datum| Question.new(datum) }
    end

    def initialize(options)
        @id = options['id']
        @title = options['title']
        @body = options['body']
        @user_id = options['user_id']
    end

    def create
        raise "#{self} already in database" if self.id
        DBConnection.instance.execute(<<-SQL, self.title, self.body, self.user_id)
            INSERT INTO
                questions (title, body, user_id)
            VALUES
                (?, ?, ?)
        SQL
        self.id = DBConnection.instance.last_insert_row_id
        
    end

    def update
        raise '#{self} not in database' unless self.id
        DBConnection.instance.execute(<<-SQL,self.title, self.body, self.id)
            UPDATE
                questions
            SET
                title = ?, body = ?
            WHERE 
                id = ?
            SQL
    end

    def self.find_by_author_id(target)
        raise 'input must be an integer' unless target.is_a?(Integer)
        result = DBConnection.instance.execute(<<-SQL,target)
            SELECT
                *
            FROM
                questions
            WHERE 
                id = ?
        SQL
        return nil unless result.length > 0
        Question.new(result.first)
    end

    def self.find_by_name(first_name,last_name)
        raise 'input must be strings' unless first_name.is_a?(String) && last_name.is_a?(String)
        result = DBConnection.instance.execute(<<-SQL,first_name,last_name)
            SELECT
                *
            FROM
                questions
            JOIN users ON questions.user_id = users.id
            WHERE 
                fname = ? AND lname = ?
        SQL
        return nil unless result.length > 0
        Question.new(result.first)
    end

    def author
        target = self.user_id
        result = DBConnection.instance.execute(<<-SQL, target)
            SELECT
                fname,lname
            FROM
                users
            WHERE 
                id = ?
        SQL
        return nil unless result.length > 0
        result
    end

    def replies
        target = self.user_id
        result = Reply.find_by_user_id(target)
        return nil if result.nil? || result.empty?
        result
    end

    def followers
        QuestionFollow.followers_for_question_id(self.id)
    end

    def self.most_followed(n)
        QuestionFollow.most_followed_questions(n)
    end

    def likers
        QuestionLike.likers_for_question_id(self.id)
    end

    def num_likes
        QuestionLike.num_likes_for_question_id(self.id)
    end

    def self.most_liked(n)
        QuestionLike.most_liked_questions(n)
    end

end