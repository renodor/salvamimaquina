# frozen_string_literal: true
# This migration comes from solidus_related_products (originally 20100308090631)

class CreateRelationTypes < SolidusSupport::Migration[4.2]
  def self.up
    create_table :relation_types do |t|
      t.string :name
      t.text :description
      t.string :applies_to
      t.timestamps
    end
  end

  def self.down
    drop_table :relation_types
  end
end
