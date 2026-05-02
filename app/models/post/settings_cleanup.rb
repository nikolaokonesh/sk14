# frozen_string_literal: true

module Post::SettingsCleanup
  extend ActiveSupport::Concern

  TAG_CONFIG = {
    urgent:    { label: "Срочно!", color_bg: "bg-rose-500/20", color_text: "text-rose-500" },
    important: { label: "Важное", color_bg: "bg-yellow-500/20", color_text: "text-yellow-500" },
    event:     { label: "Событие", color_bg: "bg-blue-500/20", color_text: "text-blue-500" },
    question:  { label: "Вопрос", color_bg: "bg-teal-500/20", color_text: "text-teal-500" },
    sell:      { label: "Продам", color_bg: "bg-green-500/20", color_text: "text-green-500" },
    buy:       { label: "Куплю", color_bg: "bg-orange-500/20", color_text: "text-orange-500" },
    help:      { label: "Помощь", color_bg: "bg-purple-500/20", color_text: "text-purple-500" }
  }.freeze

  included do
    before_validation :sanitize_settings_logic
  end

  private

  def sanitize_settings_logic
    if is_afisha?
      self.duration = "forever"
      TAG_CONFIG.each_key { |key| self.send("#{key}=", false) }
      self.event_duration ||= 1
    else
      self.event_date = nil
      self.event_duration = 1
      self.manual_finished = false
      self.finished_at = nil
      self.afisha_status = nil
    end
  end
end
