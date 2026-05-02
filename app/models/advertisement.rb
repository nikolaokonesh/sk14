# frozen_string_literal: true

class Advertisement < ApplicationRecord
  THEMES = {
    "sunset" => "from-pink-500 via-orange-400 to-amber-300",
    "ocean" => "from-cyan-500 via-blue-500 to-indigo-500",
    "forest" => "from-emerald-500 via-green-500 to-lime-400",
    "night" => "from-slate-800 via-violet-700 to-fuchsia-700"
  }.freeze

  include Entry::Content

  belongs_to :user

  validates :theme, inclusion: { in: THEMES.keys }

  scope :active, -> { where(active: true) }
  scope :paid_top, -> { where(top_placement: true).where("paid_until IS NULL OR paid_until > ?", Time.current) }
  scope :on_top, -> { active.order(top_placement: :desc, created_at: :desc) }
  scope :expired, -> { where("created_at < ?", 1.month.ago) }

  def theme_gradient
    THEMES.fetch(theme, THEMES["sunset"])
  end

  def paid_top?
    top_placement? && (paid_until.blank? || paid_until.future?)
  end

  def post?
    true
  end
end
