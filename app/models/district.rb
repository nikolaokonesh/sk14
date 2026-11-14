class District < ApplicationRecord
  has_many :posts, dependent: :destroy

  # Допустимые часовые пояса для Якутии
  VALID_TIME_ZONES = %w[
    Asia/Yakutsk
    Asia/Vladivostok
    Asia/Srednekolymsk
  ].freeze

  validates :name, presence: true
  validates :time_zone, presence: true
  validates :slug, presence: true, uniqueness: true

  scope :arctic, -> { where(is_arctic: true) }
  scope :non_arctic, -> { where(is_arctic: false) }

  # Опционально: метод для получения смещения от UTC
  def utc_offset_hours
    case time_zone
    when "Asia/Yakutsk" then 9
    when "Asia/Vladivostok" then 10
    when "Asia/Srednekolymsk" then 11
    else 9
    end
  end
end