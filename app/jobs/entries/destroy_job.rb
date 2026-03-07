class Entries::DestroyJob < ApplicationJob
  queue_as :default

  # Полное стирание постов с меткой "trash: true" через 30 дней
  def perform(*args)
    entry = Entry.where(trash: true).where(trash_data: ..30.days.ago)
    count = entry.count
    entry.destroy_all
    puts "Destroy trash entries: #{count}"
  end
end
