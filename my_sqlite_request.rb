require 'CSV'
class MySqliteRequest
    attr_accessor :type_request, :table_name, :table_data, :columns_name, :where_p, :insert_attribute
    
    def initialize
        @type_request = :none
        @table_name = :none
        @table_data = []
        @columns_name = []
        @where_p = []
        @insert_attribute = {}
        @set_attribute = {}
        @order = :acd
        @order_column = :none
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
        @table_data_1 = @table_data
        @table_data_2 = CSV.parse(File.read(filename_db_b), headers:true)
        @table_data = []
        @table_data_2.each do |row2|
            row2 = row2.to_h
            @table_data_1.each do |row1|
                row1 = row1.to_h
                if(row1[column_on_db_a]==row2[column_on_db_b])
                    @table_data << row1.merge!(row2)
                    # p row1.merge!(row2)
                end
            end
        end 
        self
    end

    def order(order, column_name)
        @order = order
        @order_column = column_name
        if @order == "ASC"
            @table_data.sort!(@order_column)
      elsif @order == "DESC"
            @table_data.sort!(@order_column)
      end
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
        @set_attribute = data
        self
    end

    def delete
        @type_request = :delete
        self
    end

    def run_select
        p "-----------------------------------------------------------------------------------------------------------"
        puts
        @table_data.each do |row|
            if(@where_p.empty?)
                p row.to_hash.slice(*@columns_name)
            elsif (@where_p.length() == 1)
                if row[@where_p[0][0]] == @where_p[1][0]
                    p row.to_hash.slice(*@columns_name)
                end
            else
                if ((row[@where_p[0][0]] == @where_p[0][1]) && (row[@where_p[1][0]] == @where_p[1][1]))
                    p row.to_hash.slice(*@columns_name)
                end
            end
        end
    end

    def run_insert
        if(@insert_attribute.is_a?(Array))
            open(@table_name, 'a') do |f|
                f.puts @insert_attribute.join(',')
            end
        else
            open(@table_name, 'a') do |f|
                f.puts @insert_attribute.values.join(',')
            end
        end
    end

    def run_update
        i=0;
        @table_data.each do |row|
            @where_p.each do |where_a|
                i+=1
                if row[where_a[0]] == where_a[1]
                    row[where_a[0]] = @set_attribute.values.join
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
                    next
                end
            end
        end       
        open(@table_name, 'r+') do |f|
            f.puts CSV.generate { |csv| arr_of_arrs.each { |row| csv << row } }
        end
        puts 
        arr_of_arrs.each do |row|
            p row.join(',')
        end
        puts
    end

    def printRequest
        puts "Type of request : #{@type_request}"
        puts "Table name : #{@table_name}"
        puts "Colunms name : #{@columns_name}" if(@type_request==:select)
        puts "Where values : #{@where_p}" if(@type_request==:select or @type_request ==:delete)
        puts "insert attribute : #{@insert_attribute}" if(@type_request==:insert)
    end

    def run
        printRequest
        puts
        run_select if(@type_request == :select)
        run_insert if(@type_request == :insert)
        run_update if(@type_request == :update)
        run_delete if(@type_request == :delete)
    end
end

def main
    request = MySqliteRequest.new
    #SELECT
    request = request.from('nba_text.csv')
    request = request.select('*')
    request = request.order("ASC",'Country')

    # request = request.join('CustomerID', 'nba_text.csv', 'CustomerID')
    
    # request = request.where('CustomerID', '1')
    # request = request.where('Country', 'Germany')

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

    request.run

end

main