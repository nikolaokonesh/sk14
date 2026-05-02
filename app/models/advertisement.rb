# frozen_string_literal: true

class Advertisement < ApplicationRecord
  THEMES = {
    "sunset" => "from-pink-500 via-orange-400 to-amber-300",
    "ocean" => "from-cyan-500 via-blue-500 to-indigo-500",
    "forest" => "from-emerald-500 via-green-500 to-lime-400",
    "night" => "from-slate-800 via-violet-700 to-fuchsia-700"
  }.freeze

  belongs_to :user

  validates :title, :description, :cta_text, :cta_url, presence: true
  validates :title, length: { maximum: 120 }
  validates :description, length: { maximum: 1200 }
  validates :cta_text, length: { maximum: 30 }
  validates :theme, inclusion: { in: THEMES.keys }
  validates :cta_url, format: URI::DEFAULT_PARSER.make_regexp(%w[http https])

  scope :active, -> { where(active: true) }
  scope :paid_top, -> { where(top_placement: true).where("paid_until IS NULL OR paid_until > ?", Time.current) }
  scope :on_top, -> { active.order(top_placement: :desc, created_at: :desc) }

  def theme_gradient
    THEMES.fetch(theme, THEMES["sunset"])
  end

  def paid_top?
    top_placement? && (paid_until.blank? || paid_until.future?)
  end
end
