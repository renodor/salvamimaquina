# frozen_string_literal:true

class UserMessage < ApplicationRecord
  validates :email, presence: true, format: { with: /\A\S+@\S+\.\S+\z/i }
  validates :message, presence: true
end