# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # `BigDecimal.new()` is deprecated since BigDecimal 1.3.3.
      # This cop identifies places where `BigDecimal.new()`
      # can be replaced by `BigDecimal()`.
      #
      # @example
      #   # bad
      #   BigDecimal.new(123.456, 3)
      #
      #   # good
      #   BigDecimal(123.456, 3)
      #
      # @api private
      class BigDecimalNew < Base
        extend AutoCorrector

        MSG = '`%<double_colon>sBigDecimal.new()` is deprecated. ' \
              'Use `%<double_colon>sBigDecimal()` instead.'

        def_node_matcher :big_decimal_new, <<~PATTERN
          (send
            (const ${nil? cbase} :BigDecimal) :new ...)
        PATTERN

        def on_send(node)
          return unless node.method?(:new)

          big_decimal_new(node) do |captured_value|
            double_colon = captured_value ? '::' : ''
            message = format(MSG, double_colon: double_colon)

            add_offense(node.loc.selector, message: message) do |corrector|
              corrector.remove(node.loc.selector)
              corrector.remove(node.loc.dot)
            end
          end
        end
      end
    end
  end
end
