class DropRelatedProductsGemTables < ActiveRecord::Migration[7.0]
  def change
    drop_table :spree_relations, id: :serial do |t|
      t.integer "relation_type_id"
      t.string "relatable_type"
      t.integer "relatable_id"
      t.string "related_to_type"
      t.integer "related_to_id"
      t.decimal "discount_amount", precision: 8, scale: 2, default: "0.0"
      t.integer "position"
      t.string "description"
      t.timestamps precision: nil
    end

    drop_table :spree_relation_types, id: :serial do |t|
      t.string "name"
      t.text "description"
      t.string "applies_to"
      t.string "applies_from"
      t.boolean "bidirectional", default: false

      t.timestamps precision: nil
    end
  end
end
