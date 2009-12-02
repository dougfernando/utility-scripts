require 'win32ole'

class Categorizer
  def initialize(path)
    @excel = WIN32OLE.new('Excel.Application')
    @xls = @excel.Workbooks.Open(path)
    @creditcard_sheet = CreditCardSheet.new(@xls.Worksheets(1))
    @account_sheet = AccountSheet.new(@xls.Worksheets(2))
    @summary_sheet = SummarySheet.new(@xls.Worksheets(4))
    @patterns = CategorySheet.new(@xls.Worksheets(3)).load_patterns()
  end

  def execute
    puts 'Updating account categories'
    @account_sheet.update_categories(@patterns)
    puts 'Updating credit card categories'
    @creditcard_sheet.update_categories(@patterns)

    puts 'Summarizing'
    aggregator = CategoryAgregattor.new

    puts 'Summarizing credit cards'
    @creditcard_sheet.aggregate(aggregator)

    puts 'Summarizing account'
    @account_sheet.aggregate(aggregator)

    puts 'Writing summary by month'
    @summary_sheet.clear
    @summary_sheet.write_results(aggregator)
  end
  
  def close
    @xls.Save
    @xls.Close
    @excel.Quit
  end
end

class CategoryUpdater
  def initialize(sheet)
    @sheet = sheet
  end

  def find_category(item, patterns) 
    result = '???????'
    patterns.each do |key, value|
      if item.index(key)
        result = value
        break
      end
    end  
    result
  end
  
  def update_categories(patterns, start_row, item_column, manual_column, category_column)
    row_index = start_row
    while @sheet.Cells(row_index, item_column).Value != nil
      if @sheet.Cells(row_index, manual_column).Value == nil
        category = find_category(@sheet.Cells(row_index, item_column).Value, patterns)
        @sheet.Cells(row_index, category_column).Value = category
        puts @sheet.Cells(row_index, item_column).Value + " => " + @sheet.Cells(row_index, category_column).Value
      end
      row_index += 1
    end  
  end
end

class SummarySheet
  DATE_COLUMN = 1
  CATEGORY_COLUMN = 2
  VALUE_COLUMN = 3
  START_ROW = 2
  
  def initialize(sheet)
    @sheet = sheet
  end
  
  def write_results(aggregator)
    aggregator.write_results(@sheet, START_ROW, DATE_COLUMN, CATEGORY_COLUMN, VALUE_COLUMN)    
  end
  
  def clear
    row_index = START_ROW
    while @sheet.Cells(row_index, DATE_COLUMN).Value != nil
      @sheet.Cells(row_index, DATE_COLUMN).Value = nil
      @sheet.Cells(row_index, CATEGORY_COLUMN).Value = nil
      @sheet.Cells(row_index, VALUE_COLUMN).Value = nil
      row_index += 1
    end
      
  end
end

class CreditCardSheet
  CARD = 1
  DATE = 2
  ITEM = 3
  CREDIT = 4
  DEBIT = 5
  PAYMENT_MONTH = 6
  CATEGORY = 7
  MANUAL = 8
  START_ROW = 2
  
  def initialize(sheet)
    @sheet = sheet
  end

  def update_categories(patterns)
    updater = CategoryUpdater.new(@sheet)
    updater.update_categories(patterns, START_ROW, ITEM, MANUAL, CATEGORY)
  end
  
  def aggregate(aggregator)
    aggregator.totalize_categories(@sheet, START_ROW, 2, CATEGORY, DEBIT) 
  end
end

class AccountSheet
  DATE = 1
  NO_DOC = 2
  ITEM = 3
  CREDIT = 4
  DEBIT = 5
  BALANCE = 6
  CATEGORY = 7
  MANUAL = 8
  START_ROW = 2

  def initialize(sheet)
    @sheet = sheet
  end

  def update_categories(patterns)
    updater = CategoryUpdater.new(@sheet)
    updater.update_categories(patterns, START_ROW, ITEM, MANUAL, CATEGORY)
  end
  
  def aggregate(aggregator)
    aggregator.totalize_categories(@sheet, START_ROW, DATE, CATEGORY, DEBIT) 
  end
end

class CategorySheet
  PATTERN = 1
  CATEGORY = 2
  START_ROW = 2

  def initialize(sheet)
    @sheet = sheet
  end

  def load_patterns
    patterns = {}
    row_index = START_ROW
    while @sheet.Cells(row_index, PATTERN).Value != nil
      patterns[@sheet.Cells(row_index, PATTERN).Value] = @sheet.Cells(row_index, CATEGORY).Value
      puts "Loaded pattern " + @sheet.Cells(row_index, PATTERN).Value + " => " + @sheet.Cells(row_index, CATEGORY).Value
      row_index += 1
    end
  
    patterns
  end
end

class CategoryMonthKey
  attr_accessor :category, :month, :year
  
  def initialize(month, year, category)
    @category = category
    @month = month
    @year = year
  end
  
  def CategoryMonthKey.create(string_date, category)
    date = DateTime.strptime(string_date.to_s, '%Y/%m/%d %H:%M:%S')
    CategoryMonthKey.new(date.month, date.year, category)
  end
  
  def ==(another_key)
    self.eql?(another_key)
  end
  
  def eql?(o)
    o.is_a?(CategoryMonthKey) && @category == o.category && @year == o.year && @month == o.month
  end
  
  def hash
    @category.hash * 10 + @year.hash * 7 + @month.hash * 33 + 43
  end
  
  def to_s
    "#{@month}/#{@year} - #{@category}"
  end
end

class CategoryAgregattor
  def initialize
    @values = {}
  end

  def totalize_categories(sheet, start_row, date_column, category_column, value_column) 
    row_index = start_row
    while sheet.Cells(row_index, date_column).Value != nil
      key = CategoryMonthKey.create(sheet.Cells(row_index, date_column).Value, sheet.Cells(row_index, category_column).Value)
      if @values[key]
        puts "Before: #{key} => #{@values[key]}"
        @values[key] += (sheet.Cells(row_index, value_column).Value.to_f.abs * -1)
        puts "Now: #{key} => #{@values[key]}"
      else
        @values[key] = sheet.Cells(row_index, value_column).Value.to_f.abs * -1
        puts "Starting: #{key} => #{@values[key]}"
      end
      row_index += 1
    end  
  end
  
  def write_results(sheet, start_row, date_column, category_column, value_column)
    row_index = start_row
    @values.each do |key, value|
      if value != 0
        sheet.Cells(row_index, date_column).Value = "%d/%02d" % [key.year.to_s, key.month.to_s]
        sheet.Cells(row_index, category_column).Value = key.category
        sheet.Cells(row_index, value_column).Value = value
        row_index += 1
      end
    end
  end
end

# MAIN
cat = Categorizer.new(ARGV[0])
begin
  cat.execute
ensure
  cat.close
end