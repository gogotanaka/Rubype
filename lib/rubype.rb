require_relative 'rubype/version'
require_relative 'rubype/contract'

module Rubype
  module TypeInfo; end
  Module.send(:include, TypeInfo)
  Symbol.send(:include, TypeInfo)
  @@typed_methods = Hash.new({})

  class << self
    def define_typed_method(owner, meth, type_info_hash, __proxy__)
      raise InvalidTypesigError unless valid_type_info_hash?(type_info_hash)
      arg_types, rtn_type = *type_info_hash.first

      contract = Contract.new(arg_types, rtn_type, owner, meth)
      @@typed_methods[owner][meth] = contract

      add_typed_method_to_proxy(owner, meth, __proxy__)
    end

    def typed_methods
      @@typed_methods
    end

    private
      def valid_type_info_hash?(type_info_hash)
        return false unless type_info_hash.is_a?(Hash)
        type_info_hash.first[0].is_a?(Array)
      end
  end
end

require_relative 'rubype/core_ext'
