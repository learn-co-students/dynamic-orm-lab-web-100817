require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def self.table_name
    table_name = self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "pragma table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |x|
      column_names << x["name"]
    end
    column_names.compact
  end

  def initialize(options={})
    options.each do |key, value|
    self.send("#{key}=", value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if{|x| x == "id"}.join(", ")
  end

  def values_for_insert
    values = []
    col = self.class.column_names.each do |col_n|
       values << "'#{send(col_n)}'" unless send(col_n) == nil
    end
    values.join(", ")
  end

  def save
    sql = "insert into #{self.class.table_name} (#{col_names_for_insert}) Values (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("Select last_insert_rowid() from #{self.class.table_name}")[0][0]
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = ?"
    DB[:conn].execute(sql, name)
  end

  def self.find_by(hash)

    sql = "Select * from #{self.table_name} Where #{hash.keys[0].to_s} = '#{hash.values[0]}'"
    DB[:conn].execute(sql)

  end
end
