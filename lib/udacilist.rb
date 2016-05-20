require 'terminal-table'

class UdaciList
  include UdaciListErrors
  attr_reader :title, :items

  def initialize(options = {})
    @title = options[:title] ? options[:title] : 'Untitled List'
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

  def filter(type)
    @items.select { |item| item.type.casecmp(type).zero? }
  end

end
