module Perspectives
  module Memoization
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def property(name, *names, &block)
        super.tap { memoize_property(name) if names.empty? }
      end

      def memoize_property(prop_name)
        raise ArgumentError, "No method #{prop_name}" unless method_defined?(prop_name)

        original_property_method = "_unmemoized_#{prop_name}"
        raise ArgumentError, "Already memoized property #{prop_name.inspect}" if method_defined?(original_property_method)

        ivar = "@_memoized_#{prop_name.to_s.sub(/\?\Z/, '_query').sub(/!\Z/, '_bang')}"
        alias_method original_property_method, prop_name

        class_eval <<-CODE, __FILE__, __LINE__ + 1
          def #{prop_name}                              # def name
            return #{ivar} if defined?(#{ivar})         # return @_memoized_name if defined?(@_memoized_name)
            #{ivar} = #{original_property_method}      # @_memoized_name = _unmemoized_name
          end
        CODE
      end
    end
  end
end
