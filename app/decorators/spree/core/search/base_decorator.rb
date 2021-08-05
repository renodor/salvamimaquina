# frozen_string_literal: true

module Spree
  module Core
    module Search
      module BaseDecorator
        protected

        def get_base_scope # rubocop:disable Naming/AccessorMethodName
          base_scope = Spree::Product.display_includes.available
          base_scope = base_scope.in_taxon(@properties[:taxon]) unless @properties[:taxon].blank?
          base_scope = get_products_conditions_for(base_scope, @properties[:keywords])
          base_scope = add_simple_scopes(base_scope)
          base_scope = add_search_scopes(base_scope)
          add_eagerload_scopes(base_scope)
        end

        def add_simple_scopes(base_scope)
          @properties[:scopes]&.each_key do |scope_name|
            scope = scope_name.to_sym
            base_scope = base_scope.send(scope) if base_scope.respond_to?(scope)
          end

          base_scope
        end

        def add_search_scopes(base_scope)
          @properties[:search]&.each do |name, scope_attribute|
            scope_name = name.to_sym
            if base_scope.respond_to?(:search_scopes) && base_scope.search_scopes.include?(scope_name.to_sym)
              parsed_scope_attribute = parse_scope_attribute(scope_attribute, scope_name)
              base_scope = base_scope.send(scope_name, *parsed_scope_attribute)
            else
              base_scope = base_scope.merge(Spree::Product.ransack({ scope_name => scope_attribute }).result)
            end
          end

          base_scope
        end

        def prepare(params)
          super

          @properties[:scopes] = params[:scopes]
        end

        def parse_scope_attribute(scope_attribute, scope_name)
          # For now it apply only to the :with_option scope,
          # But we could imagine doing it for every scope that needs 2 arguments
          # TODO: check if we can apply that to every scope where scope_attribute is an Hash or an Array
          return scope_attribute unless scope_name == :with_option

          key = scope_attribute.keys.first
          [key, scope_attribute[key]]
        end

        Spree::Core::Search::Base.prepend self
      end
    end
  end
end
