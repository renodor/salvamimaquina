# frozen_string_literal: true

class AddRepairShoprIdToTaxon < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_taxons, :repair_shopr_id, :integer
  end
end
