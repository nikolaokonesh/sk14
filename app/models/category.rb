class Category < ApplicationRecord
  has_many :category_keywords, dependent: :destroy
  has_many :posts, dependent: :nullify

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
end