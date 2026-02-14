class Entries::DestroyJob < ApplicationJob
  queue_as :default

  # Удаление постов с меткой "trash: true"
  def perform(*args)
    entry = Entry.where(trash: true, updated_at: ..30.days.ago)
    count = entry.count
    entry.destroy_all
    puts "Destroy trash entries: #{count}"
  end
end
