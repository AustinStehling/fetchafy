require_relative 'db_connection'
require 'active_support/inflector'

class SQLObject
  def self.columns
    return @columns if @columns
    data = DBConnection.execute2(<<-SQL)
      SELECT
       *
      FROM
       #{self.table_name}
    SQL
    @columns = data.first.map(&:to_sym)
    @columns
  end

  def self.finalize!
    self.columns.each do |col|
      cols = "#{col}"
      define_method(cols) do
        self.attributes[col]
      end
    end

    self.columns.each do |col|
      cols = "#{col}="
      define_method(cols) do |val|
        self.attributes[col] = val
      end
    end

  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.name.underscore.pluralize
  end

  def self.all
    data = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL
    parse_all(data)
  end

  def self.parse_all(results)
    results.map do |result|
      self.new(result)
    end
  end

  def self.find(id)
    info = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        id = ?
    SQL
    return nil if info.length == 0
    self.new(info.first)
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      unless self.class.columns.include?(attr_name.to_sym)
        raise "unknown attribute '#{attr_name}'"
      end

      key = attr_name.to_sym
      self.send("#{key}", value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map {|val| self.send(val)}
  end

  def insert
    col = self.class.columns.map {|k| k.to_s}.drop(1).join(', ')
    question_marks = (['?'] * (attribute_values.size - 1)).join(", ")
    DBConnection.execute(<<-SQL, *attribute_values.drop(1))
    INSERT INTO
      #{self.class.table_name} (#{col})
    VALUES
      (#{question_marks})
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def update
    set = self.class.columns.map {|k| "#{k} = ?"}.join(', ')

      DBConnection.execute(<<-SQL, *attribute_values, id)
        UPDATE
          #{self.class.table_name}
        SET
          #{set}
        WHERE
          #{self.class.table_name}.id = ?
      SQL

  end

  def save
    self.id.nil? ? insert : update
  end
end
