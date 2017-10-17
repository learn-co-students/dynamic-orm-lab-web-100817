require_relative "../config/environment.rb"
require 'active_support/inflector'
require "pry"

class InteractiveRecord

  def self.make_aas
    self.column_names.each do |col|
      attr_accessor col.to_sym
    end
  end

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true
    sql = <<-SQL
      PRAGMA table_info(#{self.table_name});
    SQL
    table_hash = DB[:conn].execute(sql)
    col_names = []
    table_hash.each do |col_hash|
      col_names << col_hash["name"]
    end
    col_names.compact
  end

  def initialize(args={})
    args.each do |prop, val|
      self.send("#{prop}=", val)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if{|col| col == "id"}.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col|
      values <<  "'#{self.send(col)}'" unless !self.send(col)
    end
    values.join(", ")
  end

  def save
    sql ="INSERT INTO  #{self.table_name_for_insert} (#{self.col_names_for_insert}) VALUES (#{self.values_for_insert})"
    DB[:conn].execute(sql)
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{self.table_name_for_insert}")[0]["last_insert_rowid()"]
  end

  # def vals_for_insert
  #
  #   self.class.column_names.map do |col|
  #   "'#{self.send(col)}'" unless !self.send(col)
  #   end
  #   # values.join(", ")
  #
  # end
  #
  # def save
  #   sql ="INSERT INTO  #{self.table_name_for_insert} (#{self.col_names_for_insert}) VALUES (#{values.map{|val| val = ? }.join(", ")})"
  #
  #   DB[:conn].execute(sql, *self.vals_for_insert)
  #   # self.id = 1
  #   # sql = "INSERT INTO #{self.table_name_for_insert} (#{self.col_names_for_insert}) VALUES (#{self.values_for_insert});"
  #   # binding.pry
  #   # DB[:conn].execute(sql)
  #   self.id = 1
  # end



  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = ?;"
    DB[:conn].execute(sql, name)
  end

  def self.params_for_find(args = {})
    arg_arr = []
    args.each do |col, val|
      arg_arr << "#{col} = '#{val}'"
    end
    arg_arr.join(" AND ")
    #binding.pry
  end

  def self.find_by(args={})
    sql = "SELECT * FROM #{self.table_name} WHERE #{self.params_for_find(args)}"
    #binding.pry
    DB[:conn].execute(sql)
  end


end
