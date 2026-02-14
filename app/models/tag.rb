class Tag < ApplicationRecord
  has_many :entry_keywords, dependent: :destroy
  has_many :entries, through: :entry_keywords

  has_many :subscriptions, as: :followable, dependent: :destroy
  has_many :followers, through: :subscriptions, source: :user

  validates :name, presence: true
end
