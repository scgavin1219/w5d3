require 'sqlite3'
require 'singleton'

class DBConnection < SQLite3::Database
    include Singleton

    def initialize
        super('questions.db')
        self.type_translation = true
        self.results_as_hash = true
    end
end

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


end

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
end

class Reply
        attr_accessor :id, :subject_question, :parent_reply, :body, :user_id
    
    def self.all
        data = DBConnection.instance.execute("SELECT * FROM replies")
        data.map { |datum| Reply.new(datum) }
    end

    def initialize(options)
        @id = options['id']
        @subject_question = options['subject_question']
        @parent_reply = options['parent_reply']
        @body = options['body']
        @user_id = options['user_id']
    end

    def self.find_by_user_id(target)
        raise 'input must be an integer' unless target.is_a?(Integer)
        result = DBConnection.instance.execute(<<-SQL, target)
            SELECT
                *
            FROM
                replies
            WHERE 
                user_id = ?
        SQL
        return nil unless result.length > 0
        result.map { |x| Reply.new(x) }
    end

    def self.find_by_question_id(question_id)
        raise 'input must be an integer' unless question_id.is_a?(Integer)
        result = DBConnection.instance.execute(<<-SQL, question_id)
            SELECT
                *
            FROM
                replies
            WHERE 
                subject_question = ?
        SQL
        return nil unless result.length > 0
        result.map { |x| Reply.new(x) }
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

    def question
        target = self.subject_question
        result = DBConnection.instance.execute(<<-SQL, target)
            SELECT
                title, body
            FROM
                questions
            WHERE 
                id = ?
        SQL
        return nil unless result.length > 0
        result
    end

    def parent_reply
        target = self.parent_reply
        result = DBConnection.instance.execute(<<-SQL, target)
            SELECT
                body
            FROM
                replies
            WHERE 
                id = ?
        SQL
        return nil unless result.length > 0
        result

    end

    def child_replies

    end

end