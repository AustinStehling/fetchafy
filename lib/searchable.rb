require_relative 'db_connection'
require_relative 'sql_object'

module Searchable
  def where(params)
    statement = []

    params.keys.each do |key|
      statement << ("#{key} = ?")
    end

    statement = statement.join(" AND ")

    data = DBConnection.execute(<<-SQL, *params.values)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{statement}
    SQL

    parse_all(data)
  end
end

class SQLObject
  extend Searchable
end
