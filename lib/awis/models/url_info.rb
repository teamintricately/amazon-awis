module Awis
  module Models
    class UrlInfo < Base
      attr_accessor :data_url, :rank, :asin, :contact_info, :content_data, :usage_statistics, :related_links, :categories

      def initialize(response)
        @usage_statistics = []
        @related_links = []
        @categories = []
        setup_data!( loading_response(response) )
      end

      def setup_data!(response)
        content_data = { }
        contact_info = { 
          phone_number: []
        }
        statistics = []
        related_related_links = []
        category_data = []

        response.each_node do |node, path|
          text = node.inner_xml
          text = text.to_i if text.to_i.to_s === text && node.name != 'aws:Delta'

          if node.name == 'aws:RequestId'
            @request_id ||= text
          elsif node.name == 'aws:StatusCode'
            @status_code ||= text
          elsif node.name == 'aws:DataUrl' && path == "#{traffic_node_name}/aws:DataUrl"
            @data_url = text
          elsif node.name == 'aws:Asin' && path == "#{traffic_node_name}/aws:Asin"
            @asin = text
          elsif node.name == 'aws:Rank' && path == "#{traffic_node_name}/aws:Rank"
            @rank = text
          elsif node.name == 'aws:DataUrl' && path == "#{content_node_name}/aws:DataUrl"
            content_data[:data_url] = text
          elsif node.name == 'aws:Title' && path == "#{content_node_name}/aws:SiteData/aws:Title"
            content_data[:site_title] = text
          elsif node.name == 'aws:Description'
            content_data[:site_description] = text
          elsif node.name == 'aws:MedianLoadTime'
            content_data[:speed_median_load_time] = text
          elsif node.name == 'aws:Percentile'
            content_data[:speed_percentile] = text
          elsif node.name == 'aws:AdultContent'
            content_data[:adult_content] = text
          elsif node.name == 'aws:Locale'
            content_data[:language_locale] = text
          elsif node.name == 'aws:LinksInCount'
            content_data[:links_in_count] = text
          elsif node.name == 'aws:OwnedDomains'
            content_data[:owned_domains] = text
          elsif node.name == 'aws:DataUrl' && path == "#{root_node_name}/aws:ContactInfo/aws:DataUrl"
            contact_info[:data_url] = text
          elsif node.name == 'aws:OwnerName'
            contact_info[:owner_name] = text
          elsif node.name == 'aws:Email'
            contact_info[:email] = text
          elsif node.name == 'aws:PhysicalAddress'
            contact_info[:physical_address] = text
          elsif node.name == 'aws:CompanyStockTicker'
            contact_info[:company_stock_ticker] = text
          elsif node.name == 'aws:PhoneNumber'
            contact_info[:phone_numbers] << text
          elsif node.name == 'aws:DataUrl' && path == "#{related_links_node_name}/aws:DataUrl"
            related_related_links << { data_url: text }
          elsif node.name == 'aws:NavigableUrl' && path == "#{related_links_node_name}/aws:NavigableUrl"
            related_related_links << { navigable_url: text }
          elsif node.name == 'aws:Title' &&  path == "#{related_links_node_name}/aws:Title"
            related_related_links << { title: text }
          elsif node.name == 'aws:Title' && path == "#{categories_node_name}/aws:Title"
            category_data << { title: text }
          elsif node.name == 'aws:AbsolutePath' &&  path == "#{categories_node_name}/aws:AbsolutePath"
            category_data << { absolute_path: text }
          elsif node.name == 'aws:Months' && path == "#{statistic_node_name}/aws:TimeRange/aws:Months"
            statistics << { time_range_months: text }
          elsif node.name == 'aws:Days' && path == "#{statistic_node_name}/aws:TimeRange/aws:Days"
            statistics << { time_range_days: text }
          elsif node.name == 'aws:Value' && path == "#{statistic_node_name}/aws:Rank/aws:Value"
            statistics << { rank_value: text }
          elsif node.name == 'aws:Delta' && path == "#{statistic_node_name}/aws:Rank/aws:Delta"
            statistics << { rank_delta: text }
          elsif node.name == 'aws:Value' && path == "#{statistic_node_name}/aws:Reach/aws:Rank/aws:Value"
            statistics << { reach_rank_value: text }
          elsif node.name == 'aws:Delta' && path == "#{statistic_node_name}/aws:Reach/aws:Rank/aws:Delta"
            statistics << { reach_rank_delta: text }
          elsif node.name == 'aws:Value' && path == "#{statistic_node_name}/aws:Reach/aws:PerMillion/aws:Value"
            statistics << { reach_per_million_value: text }
          elsif node.name == 'aws:Delta' && path == "#{statistic_node_name}/aws:Reach/aws:PerMillion/aws:Delta"
            statistics << { reach_per_million_delta: text }
          elsif node.name == 'aws:Value' && path == "#{statistic_node_name}/aws:PageViews/aws:PerMillion/aws:Value"
            statistics << { reach_page_views_per_million_value: text }
          elsif node.name == 'aws:Delta' && path == "#{statistic_node_name}/aws:PageViews/aws:PerMillion/aws:Delta"
            statistics << { reach_page_views_per_million_delta: text }
          elsif node.name == 'aws:Value' && path == "#{statistic_node_name}/aws:PageViews/aws:Rank/aws:Value"
            statistics << { reach_page_views_rank_value: text }
          elsif node.name == 'aws:Delta' && path == "#{statistic_node_name}/aws:PageViews/aws:Rank/aws:Delta"
            statistics << { reach_page_views_rank_delta: text }
          elsif node.name == 'aws:Value' && path == "#{statistic_node_name}/aws:PageViews/aws:PerUser/aws:Value"
            statistics << { reach_page_views_per_user_value: text }
          elsif node.name == 'aws:Delta' && path == "#{statistic_node_name}/aws:PageViews/aws:PerUser/aws:Delta"
            statistics << { reach_page_views_per_user_delta: text }
          end
        end

        init_entity_data('content_data', content_data, ContentData)
        init_entity_data('contact_info', contact_info, ContactInfo)

        relationship_collections(@usage_statistics, statistics, 13, UsageStatistic)
        relationship_collections(@related_links, related_related_links, 3, RelatedLink)
        relationship_collections(@categories, category_data, 3, CategoryData)
      end

      def init_entity_data(attr_name, data, kclass)
        return if data.empty?

        instance_variable_set("@#{attr_name}", kclass.new(data))
      end

      def content_node_name
        "#{root_node_name}/aws:ContentData"
      end

      def related_node_name
        "#{root_node_name}/aws:Related"
      end

      def related_links_node_name
        "#{related_node_name}/aws:RelatedLinks/aws:RelatedLink"
      end

      def categories_node_name
        "#{related_node_name}/aws:Categories/aws:CategoryData"
      end

      def traffic_node_name
        "#{root_node_name}/aws:TrafficData"
      end

      def statistic_node_name
        "#{traffic_node_name}/aws:UsageStatistics/aws:UsageStatistic"
      end
    end

    class ContentData
      attr_accessor :data_url, :site_title, :site_description, :speed_median_load_time, :speed_percentile, :adult_content, 
                    :language_locale, :links_in_count, :owned_domains

      def initialize(hash)
        hash.map { |k, v| instance_variable_set("@#{k}", v) }
      end
    end

    class ContactInfo
      attr_accessor :data_url, :owner_name, :email, :physical_address, :company_stock_ticker, :phone_numbers

      def initialize(hash)
        phone_numbers = hash.delete(:phone_numbers)

        hash.map { |k, v| instance_variable_set("@#{k}", v) }
        phone_number_collections(phone_numbers)
      end

      def phone_number_collections(phone_numbers)
        return @phone_numbers = [] if phone_numbers.nil? || phone_numbers.empty?

        phone_numbers.map { |item| @phone_numbers << PhoneNumber.new(item) }
      end
    end

    class PhoneNumber
      attr_accessor :number

      def initialize(hash)
        hash.map { |k, v| instance_variable_set("@#{k}", v) }
      end
    end

    class RelatedLink
      attr_accessor :data_url, :navigable_url, :title

      def initialize(hash)
        hash.map { |k, v| instance_variable_set("@#{k}", v) }
      end
    end

    class CategoryData
      attr_accessor :title, :absolute_path

      def initialize(hash)
        hash.map { |k, v| instance_variable_set("@#{k}", v) }
      end
    end

    class UsageStatistic
      attr_accessor :time_range_months, :time_range_days, :rank_value, :rank_delta, :reach_rank_value, :reach_rank_delta, 
                    :reach_per_million_value, :reach_per_million_delta, :reach_page_views_per_million_value, :reach_page_views_per_million_delta,
                    :reach_page_views_rank_value, :reach_page_views_rank_delta, :reach_page_views_per_user_value, :reach_page_views_per_user_delta

      def initialize(hash)
        hash.map { |k, v| instance_variable_set("@#{k}", v) }
      end
    end
  end
end