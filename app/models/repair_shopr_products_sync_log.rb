# frozen_string_literal:true

class RepairShoprProductsSyncLog < ApplicationRecord
  enum status: { pending: 0, complete: 1, error: 2 }
end
