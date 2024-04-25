# frozen_string_literal: true

module Spree
  module Core
    module Search
      module BaseOverride
        def retrieve_products
          @products = get_base_scope
          curr_page = @properties[:page] || 1
          @products = @products.page(curr_page).per(@properties[:per_page])
        end

        protected

        def get_base_scope # rubocop:disable Naming/AccessorMethodName
          base_scope = Spree::Product.all
          base_scope = base_scope.in_taxon(@properties[:taxon]) if @properties[:taxon].present?
          base_scope = get_products_conditions_for(base_scope, @properties[:keywords])
          base_scope = add_simple_scopes(base_scope)
          add_search_scopes(base_scope)
        end

        def add_simple_scopes(base_scope)
          return base_scope unless @properties[:scopes].present?
          raise Spree::Core::Search::Base::InvalidOptions, :scopes unless @properties[:scopes].respond_to?(:each)

          @properties[:scopes]&.each do |scope_name|
            scope = scope_name.to_sym
            base_scope = base_scope.send(scope) if base_scope.respond_to?(scope)
          end

          base_scope
        end

        def add_search_scopes(base_scope)
          return base_scope unless @properties[:search].present?
          raise Spree::Core::Search::Base::InvalidOptions, :search unless @properties[:search].respond_to?(:each_pair)

          @properties[:search].each_pair do |name, scope_attribute|
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
          @properties[:taxon] = Spree::Taxon.find_by(id: params[:taxon_id])
          @properties[:keywords] = params[:keywords]
          @properties[:search] = params[:search]
          @properties[:include_images] = params[:include_images]

          per_page = params[:per_page].to_i
          @properties[:per_page] = per_page.positive? ? per_page : Spree::Config[:products_per_page]
          @properties[:page] = params[:page].to_i <= 0 ? 1 : params[:page].to_i
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
