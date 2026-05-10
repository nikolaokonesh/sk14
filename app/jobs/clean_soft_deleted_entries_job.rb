# Удаляем Entry которые удалены в корзину через 30 дней
class CleanSoftDeletedEntriesJob < ApplicationJob
  queue_as :default

  def perform
    expired_entries = Entry.where(trash: true)
                           .where("trash_data < ?", 1.month.ago)

    expired_entries.find_each do |entry|
      entry.destroy
    end
  end
end
