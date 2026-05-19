# frozen_string_literal: true

class Comment < ApplicationRecord
  has_one :entry, as: :entryable, touch: true, dependent: :destroy

  delegate :user, :content, :created_at, to: :entry
end
