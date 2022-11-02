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

class Questions
    attr_accessor :id, :title, :body, :user_id
    def self.all
        data = DBConnection.instance.execute("SELECT * FROM questions")
        data.map { |datum| Questions.new(datum) }
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

    def self.find_by_id(target)
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
        Questions.new(result.first)
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
        Questions.new(result.first)
    end

end
