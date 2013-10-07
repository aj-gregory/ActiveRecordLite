require_relative './db_connection'

module Searchable
  def where(params)
  	mapped_keys = params.keys.map { |key| "#{key} = ?" }
  	vals = params.values

  	hash_array =DBConnection.execute(<<-SQL, *vals)
  	  SELECT *
  	  FROM "#{self.table_name}"
  	  WHERE #{mapped_keys.join(', ')}
  	SQL

    object_array = []
  	hash_array.each { |hash| object_array << self.new(hash)}
    object_array
  end
end