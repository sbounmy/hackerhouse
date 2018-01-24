module Concerns
  module MongoidQuery

    extend ActiveSupport::Concern

    module ClassMethods
      def search(query=nil)
        query = ActiveSupport::HashWithIndifferentAccess.new(query)
        return all if query.nil?
        search_scope(query).where(to_origin(query))
      end

      # MAKE SURE TO DEFINE THIS IN YOUR MODEL.
      def queryable_scopes()
        raise 'please define this method. it returns an array of queryable scopes example : [:active, :out_of_stock]'
      end

      private

      def to_origin(query)
        origin_query = {}
        query.each do |name, value|
          name, strategy = name.split('.')
          if strategy.present? && name.to_sym.respond_to?(strategy)
            origin_query[name.to_sym.send(strategy)] = value
          else
            origin_query[name.to_sym] = value
          end
        end
        origin_query
      end

      def search_scope(query)
        selected = queryable_scopes & query.symbolize_keys.keys
        selected.inject(scoped) do |scp, name|
          value = query[name.to_s]
          query.delete name.to_s

          # skip param if 'true' string like ransack
          # https://github.com/activerecord-hackery/ransack#using-scopesclass-methods
          if value == 'true'
            scp.send(name)
          else
            scp.send(name, value)
          end
        end
      end

    end

  end
end