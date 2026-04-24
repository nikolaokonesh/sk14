class Post < ApplicationRecord
  broadcasts_refreshes
  has_one :entry, as: :entryable, touch: true, dependent: :destroy

  has_delegated_json :setting, 
                     no_comments: false, 
                     duration: "forever"
  
  # Все теги как логические поля
  has_delegated_json :tags_listing,
                     urgent: false,
                     important: false,
                     event: false,
                     question: false,
                     sell: false,
                     buy: false,
                     help: false

  # Справочник для рендеринга
  TAG_CONFIG = {
    urgent:    { label: "Срочно!",  color: "bg-rose-600" },
    important: { label: "Важное",   color: "bg-yellow-600" },
    event:     { label: "Событие",  color: "bg-blue-600" },
    question:  { label: "Вопрос",   color: "bg-teal-600" },
    sell:      { label: "Продам",   color: "bg-green-600" },
    buy:       { label: "Куплю",    color: "bg-orange-600" },
    help:      { label: "Помощь",   color: "bg-purple-600" }
  }.freeze
end
