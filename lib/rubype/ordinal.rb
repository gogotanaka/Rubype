# Borrowed from ActiveSupport::Inflector
def ordinal(number)
  if (11..13).include?(number % 100)
    "th"
  else
    case number % 10
      when 1; "st"
      when 2; "nd"
      when 3; "rd"
      else    "th"
    end
  end
end
