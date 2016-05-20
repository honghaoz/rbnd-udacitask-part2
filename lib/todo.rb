class TodoItem
  include UdaciListErrors
  include Listable
  attr_reader :description, :due, :priority, :type

  def initialize(description, options = {})
    @description = description
    @due = options[:due] ? Chronic.parse(options[:due]) : options[:due]
    @priority = validate_priority(options[:priority])
    @type = "Todo"
  end

  def validate_priority(priority_string)
    if ['high', 'medium', 'low', nil].include?(priority_string)
      priority_string
    else
      raise UdaciListErrors::InvalidPriorityValue, "'#{priority_string}' is not a valid priority"
    end
  end

  def details
    [
      type, 
      format_description(@description),
      'due: ' + format_date(due: @due) + format_priority(@priority)
    ]
  end

end
