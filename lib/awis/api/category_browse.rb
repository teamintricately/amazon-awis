module Awis
  module API
    class CategoryBrowse < Base
      DEFAULT_RESPONSE_GROUP = %w(categories related_categories language_categories letter_bars).freeze

      def fetch(arguments = {})
        raise ArgumentError.new("Valid category path (Top/Arts, Top/Business/Automotive)") unless arguments.has_key?(:path)
        @arguments = arguments

        @arguments[:response_group] = Array(arguments.fetch(:response_group, DEFAULT_RESPONSE_GROUP))
        @arguments[:descriptions]   = arguments.fetch(:descriptions, true)

        @response_body = Awis::Connection.new.get(params)
        self
      end

      private
      def params
        {
          "Action"        => action_name,
          "ResponseGroup" => response_groups,
          "Path"          => arguments[:path],
          "Descriptions"  => descriptions_params
        }
      end

      def response_groups
        arguments[:response_group].sort.map { |group| camelize(group) }.join(",")
      end

      def descriptions_params
        arguments[:descriptions].to_s.capitalize
      end
    end
  end
end