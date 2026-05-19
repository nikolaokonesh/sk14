# frozen_string_literal: true

puts "--- Очистка базы данных ---"
[ ActionText::RichText, Entry, Post, Comment, Advertisement, User ].each(&:delete_all)

puts "--- Создание пользователей ---"
admin = User.create!(
  email: "nikolaokonesh@gmail.com",
  first_name: "Николай",
  last_name: "Оконешников",
  slug: "nikola"
)
admin.add_role "admin"

users_data = [
  { first_name: "Дядя Вася", slug: "vasya-mehanik" },
  { first_name: "Мария", slug: "masha-pro" },
  { first_name: "Сан Саныч", slug: "san-sanych" },
  { first_name: "Елена", slug: "elena-beauty" },
  { first_name: "Виктор", slug: "vitya-kolyma" }
]

users = [ admin ]
users_data.each do |user_data|
  users << User.create!(
    email: "#{user_data[:slug]}@example.com",
    first_name: user_data[:first_name],
    last_name: "Житель",
    slug: user_data[:slug]
  )
end

puts "--- Создание афиш ---"
now = Time.current

afishas_raw = [
  { title: "🎥 Кино: Чебурашка", starts_in_hours: 0, duration: 2, content: "Семейный просмотр." },
  { title: "💃 Дискотека 90-х", starts_in_hours: 4, duration: 6, content: "Танцы до упаду." },
  { title: "🏆 Шахматы", starts_in_hours: -2, duration: 3, content: "Уже идет или только закончилось." },
  { title: "🎤 Концерт", starts_in_hours: 24, duration: 4, content: "Живой звук!" },
  { title: "🏀 Баскетбол", starts_in_hours: 48, duration: 2, content: "Школа vs Сборная." },
  { title: "🛒 Ярмарка", starts_in_hours: 72, duration: 24, content: "Свежие продукты." },
  { title: "📣 Собрание", starts_in_hours: 10, duration: 1, content: "Важные вопросы." },
  { title: "🎨 Выставка", starts_in_hours: 100, duration: 72, content: "Длится 3 дня." }
]

12.times do |i|
  afishas_raw << {
    title: "Событие №#{i + 1}",
    starts_in_hours: (i + 5) * 10,
    duration: [ 1, 2, 3, 6, 24 ].sample,
    content: "Описание события №#{i + 1}."
  }
end

afisha_entries = afishas_raw.map do |afisha|
  entry = Entry.new(
    user: users.sample,
    entryable_type: Entry::POST_TYPE,
    entryable_attributes: {
      is_afisha: true,
      event_date: now + afisha[:starts_in_hours].hours,
      event_duration: afisha[:duration],
      manual_finished: false
    },
    content: "<h2>#{afisha[:title]}</h2><p>#{afisha[:content]}</p>"
  )

  post = entry.entryable
  post.calculate_afisha_expiry if post.respond_to?(:calculate_afisha_expiry)

  entry.save!(validate: false)
  entry
end

puts "--- Создание обычных постов ---"
topics = [ "Где вода?", "Продам дрова", "Туман на реке", "Ищу попутку", "Медленный интернет", "Новости посёлка" ]

posts = 130.times.map do |i|
  Entry.create!(
    user: users.sample,
    entryable_type: Entry::POST_TYPE,
    entryable_attributes: {
      is_afisha: false,
      setting: { no_comments: (i % 15).zero?, duration: "forever" }
    },
    created_at: (i * 30).minutes.ago,
    content: "<h3>#{topics.sample}</h3><p>Текст поста номер #{i + 1}. Подробности в комментариях.</p>"
  )
end

puts "--- Создание рекламных объявлений ---"
ads_data = [
  { title: "Свежая рыба", content: "Привезли чира и омуля. Прямой вылов!", theme: "ocean" },
  { title: "Услуги электрика", content: "Замена проводки, установка люстр. Быстро.", theme: "sunset" },
  { title: "Пиломатериалы", content: "Доска, брус в наличии. Доставка.", theme: "forest" },
  { title: "Такси Межгород", content: "Комфортные поездки в любое время.", theme: "night" }
]

ad_entries = 20.times.map do |i|
  data = ads_data[i % ads_data.length]

  Entry.create!(
    user: users.sample,
    entryable_type: Entry::ADVERTISEMENT_TYPE,
    entryable_attributes: {
      theme: data[:theme],
      active: true,
      top_placement: i < 5,
      paid_until: (i < 5) ? 1.month.from_now : nil
    },
    created_at: i.hours.ago,
    content: "<h3>#{data[:title]}</h3><p>#{data[:content]} (Объявление №#{i + 1})</p>"
  )
end

puts "--- Создание комментариев ---"
comment_texts = [
  "Ок",
  "Спасибо!",
  "Поддерживаю",
  "Уточните адрес, пожалуйста",
  "Буду",
  "Классная новость",
  "Актуально?",
  "Готов купить",
  "Написал в ЛС",
  "Принято"
]

commentable_entries = (posts + afisha_entries + ad_entries).reject { |entry| entry.no_comments? }
comment_count = 0

commentable_entries.sample(50).each do |root_entry|
  rand(2..8).times do
    comment_user = users.sample
    Entry.create!(
      user: comment_user,
      parent: root_entry,
      root: root_entry,
      entryable: Comment.new,
      content: "<p>#{comment_texts.sample}</p>",
      created_at: root_entry.created_at + rand(5..600).minutes
    )
    comment_count += 1
  end
end

puts "--- Готово! ---"
puts "Пользователей: #{User.count}"
puts "Записей: #{Entry.count}"
puts "Комментариев: #{comment_count}"
puts "Постов: #{posts.size}, афиш: #{afisha_entries.size}, объявлений: #{ad_entries.size}"
