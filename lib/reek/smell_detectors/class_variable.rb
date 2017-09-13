# frozen_string_literal: true

require 'set'
require_relative 'base_detector'

module Reek
  module SmellDetectors
    #
    # Class variables form part of the global runtime state, and as such make
    # it easy for one part of the system to accidentally or inadvertently
    # depend on another part of the system. So the system becomes more prone to
    # problems where changing something over here breaks something over there.
    # In particular, class variables can make it hard to set up tests (because
    # the context of the test includes all global state).
    #
    # See {file:docs/Class-Variable.md} for details.
    class ClassVariable < BaseDetector
      def self.contexts # :nodoc:
        [:class, :module]
      end

      #
      # Checks whether the given class or module declares any class variables.
      #
      # @return [Array<SmellWarning>]
      #
      def sniff
        class_variables_in_context.map do |variable, lines|
          smell_warning(
            context: context,
            lines: lines,
            message: "declares the class variable '#{variable}'",
            parameters: { name: variable.to_s })
        end
      end

      #
      # Collects the names of the class variables declared and/or used
      # in the given module.
      #
      # :reek:TooManyStatements: { max_statements: 7 }
      def class_variables_in_context
        result = Hash.new { |hash, key| hash[key] = [] }
        collector = proc do |cvar_node|
          result[cvar_node.name].push(cvar_node.line)
        end
        [:cvar, :cvasgn, :cvdecl].each do |stmt_type|
          expression.each_node(stmt_type, [:class, :module], &collector)
        end
        result
      end
    end
  end
end
