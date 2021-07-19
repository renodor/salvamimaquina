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
          base_scope = add_simple_scope(base_scope)
          base_scope = add_search_scopes(base_scope)
          add_eagerload_scopes(base_scope)
        end

        def add_simple_scope(base_scope)
          scope = @properties[:scope]&.to_sym
          return base_scope unless scope.present? && base_scope.respond_to?(scope)

          base_scope.send(scope)
        end

        def prepare(params)
          super

          @properties[:scope] = params[:scope]
        end

        Spree::Core::Search::Base.prepend self
      end
    end
  end
end
