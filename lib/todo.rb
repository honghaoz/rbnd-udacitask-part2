class TodoItem
  include UdaciListErrors
  include Listable
  attr_reader :description, :due, :priority

  def initialize(description, options = {})
    @description = description
    @due = options[:due] ? Chronic.parse(options[:due]) : options[:due]
    if ['high', 'medium', 'low', nil].include?(options[:priority])
      @priority = options[:priority]
    else
      raise UdaciListErrors::InvalidPriorityValue, "'#{options[:priority]}' is not a valid priority"
    end
  end

  def details
    format_description(@description) + 'due: ' +
        format_date(due: @due) +
        format_priority(@priority)
  end

end
