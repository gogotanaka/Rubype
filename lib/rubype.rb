require_relative 'rubype/version'
require_relative 'rubype/contract'

module Rubype
  module TypeInfo; end
  Module.send(:include, TypeInfo)
  Symbol.send(:include, TypeInfo)
  @@typed_method = Hash.new({})

  class << self
    def define_typed_method(owner, meth, type_info_hash, __rubype__)
      raise InvalidTypesigError unless valid_type_info_hash?(type_info_hash)
      arg_types, rtn_type = *type_info_hash.first

      contract = Contract.new(arg_types, rtn_type, owner, meth)
      @@typed_method[owner][meth] = contract
      method_visibility = get_method_visibility(owner, meth)
      __rubype__.send(:define_method, meth) do |*args, &block|
        contract.assert_args_type(self, args)
        super(*args, &block)
          .tap { |rtn| contract.assert_rtn_type(self, rtn) }
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

    def typed_method
      @@typed_method
    end

    private

      def valid_type_info_hash?(type_info_hash)
        return false unless type_info_hash.is_a?(Hash)
        type_info_hash.first[0].is_a?(Array)
      end
  end
end

require_relative 'rubype/core_ext'
