require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names #returns a list of what we need to make accessors
    sql = <<-SQL
      PRAGMA table_info(#{self.table_name});
    SQL

    DB[:conn].execute(sql).inject([]) do |memo, hash|
      memo << hash["name"]
    end
  end

  def initialize(attributes={})
      attributes.each do |key, value|
        self.send("#{key}=", value)
      end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert #(name, grade)
    self.class.column_names[1..-1].join(", ")
  end

  def values_for_insert
    self.class.column_names[1..-1].map do |attribute|
      attribute.is_a?(String) ? "'#{send(attribute)}'" : attribute
    end.join(", ")
  end

  def save
    sql=<<-SQL
      INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})
    SQL
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid()")[0][0]
  end

  def self.find_by_name(name)
    sql=<<-SQL
      SELECT * FROM #{table_name} WHERE name = ?
    SQL
    DB[:conn].execute(sql, name)
  end

  def self.find_by(hash)
    sql=<<-SQL
      SELECT * FROM #{table_name} WHERE #{hash.keys[0].to_s} = ?
    SQL
    DB[:conn].execute(sql, hash.values[0])
  end
end
