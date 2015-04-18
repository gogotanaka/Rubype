require_relative 'rubype/version'
require_relative 'rubype/ordinalize'
require 'rubype/rubype'

module Rubype
  @@typed_method_info = Hash.new({})
  module TypeInfo; end
  Module.send(:include, TypeInfo)
  Symbol.send(:include, TypeInfo)
  class << self
    def define_typed_method(owner, meth, type_info_hash, __rubype__)
      raise InvalidTypesigError unless valid_type_info_hash?(type_info_hash)
      arg_types, rtn_type = *type_info_hash.first

      @@typed_method_info[owner][meth] = { arg_types => rtn_type }

      method_visibility = get_method_visibility(owner, meth)
      __rubype__.send(:define_method, meth) do |*args, &block|
        caller_trace = caller_locations(1, 5)
        ::Rubype.assert_args_type(self.class, meth, args, arg_types, caller_trace)
        super(*args, &block).tap { |rtn| ::Rubype.assert_rtn_type(self.class, meth, rtn, rtn_type, caller_trace) }
      end
      __rubype__.send(method_visibility, meth)
    end

    def get_method_visibility(owner, meth)
      case
      when owner.private_method_defined?(meth)
        :private
      when owner.protected_method_defined?(meth)
        :protected
      else
        :public
      end
    end

    def typed_method_info
      @@typed_method_info
    end

    private
      def valid_type_info_hash?(type_info_hash)
        return false unless type_info_hash.is_a?(Hash)
        type_info_hash.first[0].is_a?(Array)
      end
  end
end

require_relative 'rubype/core_ext'
