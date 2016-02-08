# A custom initializer that enables sorting via custom scopes in Ransack (like the same feature in MetaSearch)

module Ransack
  module Adapters
    module ActiveRecord
      class Context < ::Ransack::Context

        # Allows for sorting by custom scopes
        #
        #
        # Define your custom scopes in your model, e. g. sort_by_title_asc and sort_by_title_desc
        # (The scopes would sort by some calculated column or a column added via some crazy join, etc.)
        #
        # In your sort links refer to the scopes like to standard fields, e. g.
        #   <%= sort_link(@q, :title, 'Crazy calculated title') %>
        def evaluate(search, opts = {})
          viz = Visitor.new
          relation = @object.where(viz.accept(search.base))
          if search.sorts.any?
            custom_scopes = search.sorts.select do |s|
              custom_scope_name = :"sort_by_#{s.name}_#{s.dir}"
              relation.respond_to?(custom_scope_name)
            end
            attribute_scopes = search.sorts - custom_scopes

            relation = relation.except(:order)

            custom_scopes.each do |s|
              custom_scope_name = :"sort_by_#{s.name}_#{s.dir}"
              relation = relation.public_send(custom_scope_name)
            end

            relation = relation.reorder(viz.accept(attribute_scopes)) if attribute_scopes.any?
          end
          opts[:distinct] ? relation.distinct : relation
        end
      end
    end
  end
end