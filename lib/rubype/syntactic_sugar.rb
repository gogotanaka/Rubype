require 'binding_of_caller'

class Array
  def >(*args)
    args_match = args.length == 1 && args.first.kind_of?(Symbol)
    self_matches = length > 0 && all? { |e| e.kind_of?(Class) }

    if args_match && self_matches
      return_type = self.last
      call_string = "typesig :#{args.first}, [#{self[0...-1].map(&:name).join(', ')}] => #{return_type}"
      binding.of_caller(1).eval(call_string)
    else
      if !args_match
        raise "You must pass a Symbol as the only argument to a type definition!"
      else
        raise "Wrong type definition #{self}"
      end
    end
  end
end