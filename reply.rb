require_relative 'connection'

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
        target = @parent_reply
        result = DBConnection.instance.execute(<<-SQL, target)
            SELECT
                *
            FROM
                replies
            WHERE 
                id = ?
        SQL
        return nil unless result.length > 0
        result.map { |x| Reply.new(x) }

    end

    def child_replies
        target = self.id
        result = DBConnection.instance.execute(<<-SQL, target)
            SELECT
                *
            FROM
                replies
            WHERE 
                parent_reply = ?
        SQL
        return nil unless result.length > 0
        result.map { |x| Reply.new(x) }
    end

    def save
        raise "#{self} already in database" if self.id
        DBConnection.instance.execute(<<-SQL, self.subject_question, self.parent_reply, self.body, self.user_id)
        INSERT INTO
            replies (subject_question, parent_reply, body, user_id)
        VALUES
            (?, ?, ?, ?)
        SQL
        self.id = DBConnection.instance.last_insert_row_id
    end

end