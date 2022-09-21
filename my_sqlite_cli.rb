require "readline"
require_relative "my_sqlite_request"


class MySqliteCli 

  attr_accessor :table_name, :select_columns, :where_column, :where_criteria, :data_value, :values

  def initialize
    @table_name = :none
    @select_columns = []
    @where_column = :none
    @where_criteria = :none
    @data_value = {}
    @values = []

    self
  end

  def reInitialize
    @table_name = :none
    @select_columns = []
    @where_column = :none
    @where_criteria = :none
    @data_value = {}
    self
  end

  def get_table_name(query)
    query.each do |elt|
      if(elt.upcase=='FROM' or elt.upcase=='UPDATE' or elt.upcase=='INTO')
        @table_name = query[query.find_index(elt) + 1]
        break
      end
    end
    #p @table_name
    self
  end

  def get_select_columns(query)
    for i in (query.find_index('SELECT') + 1)..(query.find_index('FROM') - 1)
      @select_columns << query[i]
    end
    @select_columns = @select_columns.join.to_s if(@select_columns.length()==1)

    p @select_columns
    self
  end

  def get_where_p(query)
    query.each do |elt|
      if(elt.upcase=='WHERE')
        @where_column = query[query.find_index(elt) + 1].split('=').first
        @where_criteria = query[query.find_index(elt) + 1].split('=').last
        break
      end
    end
    self
  end

  def get_insert_value(query)
    if(query.find_index('VALUES'))
      @values = query[query.find_index('VALUES') + 1]
      @values.delete! "("
      @values.delete! ")"
    end
    @values = @values.split(',')
    p @values
  end

  def get(query)
    get_table_name(query)  if(query.include? "FROM")
    get_select_columns(query) if(query.include? "SELECT")
    get_where_p(query) if(query.include? "WHERE")
    get_table_name(query)  if(query.include? "INSERT" )
    get_insert_value(query) if(query.include? "INSERT")
    self
  end

  def run_request(query)
    get(query)
    request = MySqliteRequest.new
    request = request.from(@table_name) if(query.include? "FROM")
    request = request.select(@select_columns) if(query.include? "SELECT")
    request = request.where(@where_column,@where_criteria) if(query.include? "WHERE")
    request = request.insert(@table_name)
    request = request.values(@values)
    request = request.delete() if(query.include? "DELETE")
    request = request.run 
    self
  end

  def get_query(query)
    request_type = query.split.first
    print request_type
  end

  def run
    while query = Readline.readline("my_sqlite_cli > ", true)
      get_query(query)
      puts
      run_request(query)
      reInitialize()
      self
    end
  end
end

def main
  request = MySqliteCli.new
  request.run
end

main