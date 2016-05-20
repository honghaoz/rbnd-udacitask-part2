require 'terminal-table'
require 'etc'

class UdaciList
  include UdaciListErrors
  attr_reader :title, :items

  def initialize(options = {})
    @title = options[:title] ? options[:title] : "#{Etc.getpwuid[:gecos] || Etc.getlogin}'s Untitled List"
    @items = []
  end

  def add(type, description, options = {})
    type = type.downcase
    if type == 'todo'
      @items.push TodoItem.new(description, options)
    elsif type == 'event'
      @items.push EventItem.new(description, options)
    elsif type == 'link'
      @items.push LinkItem.new(description, options)
    else
      raise UdaciListErrors::InvalidItemType, "'#{type}' is not a valid data type"
    end
  end

  def delete(index)
    if index.between?(1, @items.count)
      @items.delete_at(index - 1)
    else
      raise UdaciListErrors::IndexExceedsListSize, "item '#{index}' does not exist"
    end
  end

  def all
    rows = []
    @items.each_with_index do |item, position|
      rows << ["#{position + 1}"] + item.details
    end

    table = Terminal::Table.new :title => @title, :rows => rows
    puts table, "\n"
  end

  # fileter items by type
  def filter(type)
    @items.select { |item| item.type.casecmp(type).zero? }
  end

  # save list into a csv file
  def export_to_csv
    puts 'Please enter a csv file name:'

    filename = get_filename
    filename = add_csv_suffix_if_needed filename
    
    write_to_csv_file filename
    
  end

  # read filename from standard input
  def get_filename
    filename = gets.chomp
  end

  # add .csv suffix if needed
  def add_csv_suffix_if_needed(filename)
    filename += (filename.end_with? '.csv') ? '' : '.csv'
  end

  # write list to .csv file
  def write_to_csv_file(filename)
    CSV.open(filename, 'w') do |csv|
      csv << [@title]
      @items.each_with_index do |item, position|
        csv << [position + 1] + item.details
      end
    end
  end

end
