# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop enforces that optional keyword parameters are placed at the
      # end of the parameters list.
      #
      # This improves readability, because when looking through the source,
      # it is expected to find required parameters at the beginning of parameters list
      # and optional parameters at the end.
      #
      # @example
      #   # bad
      #   def some_method(first: false, second:, third: 10)
      #     # body omitted
      #   end
      #
      #   # good
      #   def some_method(second:, first: false, third: 10)
      #     # body omitted
      #   end
      #
      # @api private
      class KeywordParametersOrder < Base
        include RangeHelp
        extend AutoCorrector

        MSG = 'Place optional keyword parameters at the end of the parameters list.'

        def on_kwoptarg(node)
          kwarg_nodes = right_siblings_of(node).select(&:kwarg_type?)
          return if kwarg_nodes.empty?

          add_offense(node) do |corrector|
            if node.parent.find(&:kwoptarg_type?) == node
              corrector.insert_before(node, "#{kwarg_nodes.map(&:source).join(', ')}, ")
              remove_kwargs(kwarg_nodes, corrector)
            end
          end
        end

        private

        # TODO: Use API from `rubocop-ast` when released.
        def right_siblings_of(node)
          node.parent.children[node.sibling_index + 1..-1]
        end

        def remove_kwargs(kwarg_nodes, corrector)
          kwarg_nodes.each do |kwarg|
            with_space = range_with_surrounding_space(range: kwarg.source_range)
            corrector.remove(range_with_surrounding_comma(with_space, :left))
          end
        end
      end
    end
  end
end
