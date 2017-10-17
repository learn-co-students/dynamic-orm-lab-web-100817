require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "pragma table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |row|
      column_names << row["name"]
    end
    column_names.compact
  end

    self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
  end


  def initialize(attributes={})
    attributes.map do |var, val|
      #binding.pry
      self.send("#{var}=", val)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|column| column == "id"}.join(', ')
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |column|
      values << "'#{send(column)}'" unless send(column).nil?
    end
    values.join(', ')
  end

  def save
    sql = <<-SQL
      INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
      VALUES (#{values_for_insert});
    SQL

    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid()")[0][0]
  end

  def self.find_by_name(name)
    target = self.table_name
    #binding.pry
    sql = <<-SQL
      SELECT * FROM #{target} WHERE name = "#{name}"
    SQL

    DB[:conn].execute(sql)
  end


  def self.find_by(hash={})
    key = hash.keys[0].to_s
    val = hash.values[0]
    #binding.pry
    sql= <<-SQL
      SELECT * FROM #{self.table_name} WHERE #{key} = "#{val}"
    SQL

    DB[:conn].execute(sql)
  end

end
