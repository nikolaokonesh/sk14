module User::Stats
  extend ActiveSupport::Concern

  def trash_size
    entries.where(entryable_type: "Post").inactive.count
  end

  def entries_size
    entries.where(entryable_type: "Post").active.count
  end
end
