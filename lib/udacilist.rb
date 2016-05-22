require 'terminal-table'
require 'etc'

require_relative 'todo'
require_relative 'event'
require_relative 'link'

class UdaciList
  include UdaciListErrors
  attr_reader :title, :items

  @@type_hash = {
    todo: TodoItem,
    event: EventItem,
    link: LinkItem
  }

  def initialize(options = {})
    @title = options[:title] ? options[:title] : "#{Etc.getpwuid[:gecos] || Etc.getlogin}'s Untitled List"
    @items = []
  end

  def add(type, description, options = {})
    type = type.downcase.to_sym
    if @@type_hash.key? type
      @items.push @@type_hash[type].new(description, options)
    else
      raise UdaciListErrors::InvalidItemType, "'#{type}' is not a valid data type"
    end
  end

  def delete(*index)
    indices_to_delete = *index

    indices_to_delete.each do |index_to_delete|
      if index_to_delete.between?(1, @items.count) == false
        raise UdaciListErrors::IndexExceedsListSize, "item '#{index_to_delete}' does not exist"  
      end
    end

    # Execute deletions
    @items.delete_if.with_index { |_, index| indices_to_delete.include? index + 1 }
  end

  def all
    print_items @items
  end

  # fileter items by type
  def filter(type)
    print_items @items.select { |item| item.type.casecmp(type).zero? }
  end

  def print_items(items)
    rows = []
    items.each_with_index do |item, position|
      rows << ["#{position + 1}"] + item.details
    end

    table = Terminal::Table.new :title => @title, :rows => rows
    puts table, "\n"
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
