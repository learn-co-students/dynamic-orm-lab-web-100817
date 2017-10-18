require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  RESERVED_WORDS = "ABORT
  ACTION
  ADD
  AFTER
  ALL
  ALTER
  ANALYZE
  AND
  AS
  ASC
  ATTACH
  AUTOINCREMENT
  BEFORE
  BEGIN
  BETWEEN
  BY
  CASCADE
  CASE
  CAST
  CHECK
  COLLATE
  COLUMN
  COMMIT
  CONFLICT
  CONSTRAINT
  CREATE
  CROSS
  CURRENT_DATE
  CURRENT_TIME
  CURRENT_TIMESTAMP
  DATABASE
  DEFAULT
  DEFERRABLE
  DEFERRED
  DELETE
  DESC
  DETACH
  DISTINCT
  DROP
  EACH
  ELSE
  END
  ESCAPE
  EXCEPT
  EXCLUSIVE
  EXISTS
  EXPLAIN
  FAIL
  FOR
  FOREIGN
  FROM
  FULL
  GLOB
  GROUP
  HAVING
  IF
  IGNORE
  IMMEDIATE
  IN
  INDEX
  INDEXED
  INITIALLY
  INNER
  INSERT
  INSTEAD
  INTERSECT
  INTO
  IS
  ISNULL
  JOIN
  KEY
  LEFT
  LIKE
  LIMIT
  MATCH
  NATURAL
  NO
  NOT
  NOTNULL
  NULL
  OF
  OFFSET
  ON
  OR
  ORDER
  OUTER
  PLAN
  PRAGMA
  PRIMARY
  QUERY
  RAISE
  RECURSIVE
  REFERENCES
  REGEXP
  REINDEX
  RELEASE
  RENAME
  REPLACE
  RESTRICT
  RIGHT
  ROLLBACK
  ROW
  SAVEPOINT
  SELECT
  SET
  TABLE
  TEMP
  TEMPORARY
  THEN
  TO
  TRANSACTION
  TRIGGER
  UNION
  UNIQUE
  UPDATE
  USING
  VACUUM
  VALUES
  VIEW
  VIRTUAL
  WHEN
  WHERE
  WITH
  WITHOUT"
  def initialize(attributes={})
  end

  def self.table_name
  self.to_s.downcase.pluralize
  end

  def self.column_names
    sql= <<-SQL
    PRAGMA table_info("#{table_name}")
    SQL
    table_info = DB[:conn].execute(sql)
    # binding.pry
    results = table_info.map{|keys| keys["name"]}
  end

  def table_name_for_insert
    # binding.pry
    self.class.table_name
  end

  def col_names_for_insert
    columns = self.class.column_names
    columns.delete("id")
    columns.join(", ")
  end

  def values_for_insert
    value = []
    self.col_names_for_insert.split(", ").each do |col_names|
        #removes quotes around grade, since it can be represented as a integer
        # value << (send(col_names)== Fixnum ? "'#{send(col_names)}'" : "#{send(col_names)}")  unless col_names == "id"
        value << "'#{send(col_names)}'" unless col_names == "id"
    end
    value.join(", ")
    # binding.pry
  end

    def save
      # binding.pry
       # Add as many questions marks as are items to be included
       sql_question_mark = "INSERT INTO #{self.class.table_name} (#{self.col_names_for_insert}) VALUES " + "(#{add_question_mark_to_values(self.values_for_insert)})"
       # Solve interpolation and add to string
       sql_interpolation = "INSERT INTO #{self.class.table_name} (#{self.col_names_for_insert}) VALUES " + "(#{solve_interpolation_add_to_values(self.values_for_insert)})"
      #DB[:conn].execute(sql,self.values_for_insert)
      #using interpolation solution
      DB[:conn].execute(sql_interpolation)
      self.id=DB[:conn].execute("SELECT last_insert_rowid() FROM #{self.class.table_name}")[0][0]
      #  binding.pry
    end

     def add_question_mark_to_values(many_times)
       values =[]
        many_times.split(", ").size.times{values << "?"}
        values.join(",")
     end

     def solve_interpolation_add_to_values(values_for_insert)
       cant_have = RESERVED_WORDS.split(/\n/).map{|word|word.strip}

       result = "#{values_for_insert}".split(", ").select do |word|
         word.split(" ").each do|x|
           if cant_have.include?(x)
             return "Invalid String"
           end
         end
      end
       "#{values_for_insert}"
    end

    def self.find_by_name(name)
      DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE name = ?",name)
    end

    def self.find_by(attribute)
      DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE #{attribute.keys[0].to_s} = ?",attribute.values[0])
    end

end
