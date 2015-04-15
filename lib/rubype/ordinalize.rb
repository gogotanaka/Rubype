# Borrowed from ActiveSupport::Inflector
def ordinalize(number)
  if (11..13).include?(number % 100)
    "#{number}th"
  else
    case number % 10
      when 1 then "#{number}st"
      when 2 then "#{number}nd"
      when 3 then "#{number}rd"
      else        "#{number}th"
    end
  end
end
