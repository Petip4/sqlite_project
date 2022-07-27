require 'CSV'
class MySqliteRequest

    def initialize
        @type_request = :none
        @table_name = :none
        @table_data = []
        @columns_name = []
        @where_p = []
        @insert_attribute = {}
        @result = []
        self
    end

    def from(table_name)
        @table_name = table_name
        @table_data = CSV.parse(File.read(@table_name), headers:true)
        self
    end

    def select(columns)
        @type_request = :select
        if(columns.is_a?(Array))
            @columns_name += columns.collect{ | element | element.to_s }
        else
            if(columns == "*")
                array = CSV.parse(File.read(@table_name))
                @columns_name = array[0]
                p "column name"
                p @columns_name
            else
                @columns_name = columns.to_s
            end
        end
        self
    end

    def where(column_name, criteria)
        @where_p << [column_name, criteria]
        self
    end

    def join(column_on_db_a, filename_db_b, column_on_db_b)
        self
    end

    def order(order, column_name)

        self
    end

    def insert(table_name)
        @type_request = :insert
        @table_name = table_name
        @table_data = CSV.parse(File.read(@table_name), headers:true)

        self
    end

    def values(data)
        @insert_attribute = data
        self
    end

    def update(table_name)
        @type_request = :update
        @table_name=table_name
        @table_data = CSV.parse(File.read(@table_name), headers:true)
        self
    end

    def set(data)
        self
    end

    def delete
        @type_request = :delete
        self
    end

    def run_select
        p "----------------------------------------------------------------------------"
        p '--'
        @table_data.each do |row|
            if(@where_p.empty?)
                #p row.to_hash.slice(*@columns_name)
                @result << row.to_hash.slice(*@columns_name)
            else
                @where_p.each do |where_a|
                    if row[where_a[0]] == where_a[1]
                        #p row.to_hash.slice(*@columns_name)
                        @result << row.to_hash.slice(*@columns_name)
                    end
                end
            end
        end
        #p @result
        print @result
    end

    def run_insert
        open(@table_name, 'a') do |f|
            f.puts @insert_attribute.values.join(',')
        end
    end

    def run_update
        i=0;
        @table_data.each do |row|
            @where_p.each do |where_a|
                i+=1
                if row[where_a[0]] == where_a[1]
                    row[where_a[0]] = @insert_attribute.values.join
                end
            end
        end
        open(@table_name, 'r+') do |f|
            f.write(@table_data)
        end
        print @table_data
    end

    def run_delete
        arr_of_arrs = CSV.read(@table_name)
        i=0;
        @table_data.each do |row|
            @where_p.each do |where_a|
                i+=1
                if row[where_a[0]] == where_a[1]
                    arr_of_arrs.to_a.delete_at(i)
                end
            end
        end
        open(@table_name, 'r+') do |f|
            f.write(arr_of_arrs)
        end
        print arr_of_arrs
        p "\n"
    end

    def run
        puts "Type of request : #{@type_request}"
        puts "Table name : #{@table_name}"
        puts "Colunms name : #{@columns_name}" if(@type_request==:select)
        puts "Where values : #{@where_p}" if(@type_request==:select or @type_request ==:delete)
        puts "insert attribute : #{@insert_attribute}" if(@type_request==:insert)
        run_select if(@type_request == :select)
        run_insert if(@type_request == :insert)
        run_update if(@type_request == :update)
        run_delete if(@type_request == :delete)
    end
end

def main
    request = MySqliteRequest.new
    #SELECT
    # request = request.from('player_test.csv')
    # request = request.select('*')
    # request = request.where('weight', '225')

    #INSERT
    # request = request.insert('player_test.csv')
    # request = request.values('name' => 'Anais Dounou', 'year_start' => '1991', 'year_end' => '1995', 'position' => 'F-C', 'height' => '6-10', 'weight' => '240', 'birth_date' => '"June 24, 1968"', 'college' => 'Duke University')

    #delete
    # request = request.delete()
    # request = request.where('name', 'Alaa Abdelnaby')
    # request = request.from('player_test.csv')

    #UPDATE
    # request = request.update('player_test.csv')
    # request = request.values('name'=>'Alaa Renamed')
    # request = request.where('name', 'Alaa Abdelnaby')

    #request.run
end

main