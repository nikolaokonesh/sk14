# frozen_string_literal: true

puts "--- Очистка базы данных ---"
[ EntryRead, ActionText::RichText, Entry, Post, User ].each(&:delete_all)

puts "--- Создание персонажей ---"
admin = User.create!(
  email: "nikolaokonesh@gmail.com",
  first_name: "Николай",
  last_name: "Оконешников",
  slug: "nikola"
)
admin.add_role "admin"

users_data = [
  { f: "Дядя Вася", s: "vasya-mehanik" },
  { f: "Мария", s: "masha-pro" },
  { f: "Сан Саныч", s: "san-sanych" },
  { f: "Елена", s: "elena-beauty" },
  { f: "Виктор", s: "vitya-kolyma" }
]

users = [ admin ]
users_data.each do |u|
  users << User.create!(email: "#{u[:s]}@example.com", first_name: u[:f], last_name: "Житель", slug: u[:s])
end

puts "--- Создание 20 Афиш (с учетом часовой длительности) ---"
now = Time.current

# h: через сколько часов начнется
# d: длительность В ЧАСАХ (теперь мы используем часы)
afishas_raw = [
  { t: "🎥 Кино: Чебурашка", h: 0, d: 2, c: "Семейный просмотр." },
  { t: "💃 Дискотека 90-х", h: 4, d: 6, c: "Танцы до упаду." },
  { t: "🏆 Шахматы", h: -2, d: 3, c: "Уже идет или только закончилось." }, # Прошлое
  { t: "🎤 Концерт", h: 24, d: 4, c: "Живой звук!" },
  { t: "🏀 Баскетбол", h: 48, d: 2, c: "Школа vs Сборная." },
  { t: "🛒 Ярмарка", h: 72, d: 24, c: "Свежие продукты." }, # 1 день
  { t: "📣 Собрание", h: 10, d: 1, c: "Важные вопросы." },
  { t: "🎨 Выставка", h: 100, d: 72, c: "Длится 3 дня." }
]

# Добьем до 20 штук случайными
12.times { |i| afishas_raw << { t: "Событие №#{i}", h: (i + 5) * 10, d: [ 1, 2, 3, 6, 24 ].sample, c: "Описание..." } }

afishas_raw.each do |a|
  # Создаем запись через Entry, чтобы сработали вложенные атрибуты
  entry = Entry.new(
    user: users.sample,
    entryable_type: "Post",
    entryable_attributes: {
      is_afisha: true,
      event_date: now + a[:h].hours,
      event_duration: a[:d], # Передаем часы!
      manual_finished: false
    },
    content: "<h2>#{a[:t]}</h2><p>#{a[:c]}</p>"
  )

  # Сохраняем, вызывая метод расчета finished_at вручную, так как это сиды
  post = entry.entryable
  post.calculate_afisha_expiry if post.respond_to?(:calculate_afisha_expiry)

  entry.save!(validate: false)
end

puts "--- Создание 130 обычных постов ---"
topics = [ "Где вода?", "Продам дрова", "Туман на реке", "Ищу попутку", "Медленный интернет" ]

1000.times do |i|
  Entry.create!(
    user: users.sample,
    entryable_type: "Post",
    entryable_attributes: {
      is_afisha: false,
      setting: { no_comments: (i % 15 == 0), duration: "forever" }
    },
    created_at: (i * 30).minutes.ago,
    content: "<h3>#{topics.sample}</h3><p>Текст поста номер #{i}...</p>"
  )
end

puts "\n--- Готово! Заполнил базу. Запусти 'rails c' и проверь Post.last.finished_at ---"

puts "--- Создание 20 рекламных объявлений ---"

ads_data = [
  { t: "Свежая рыба", c: "Привезли чира и омуля. Прямой вылов!", theme: "ocean" },
  { t: "Услуги электрика", c: "Замена проводки, установка люстр. Быстро.", theme: "sunset" },
  { t: "Пиломатериалы", c: "Доска, брус в наличии. Доставка.", theme: "forest" },
  { t: "Такси Межгород", c: "Комфортные поездки в любое время.", theme: "night" }
]

20.times do |i|
  # Берем данные из примера или генерируем случайные
  data = ads_data[i % ads_data.length]

  entry = Entry.create!(
    user: users.sample,
    entryable_type: "Advertisement",
    entryable_attributes: {
      theme: data[:theme],
      active: true,
      # Сделаем первые 5 объявлений "топовыми"
      top_placement: (i < 5),
      paid_until: (i < 5) ? 1.month.from_now : nil
    },
    created_at: i.hours.ago,
    content: "<h3>#{data[:t]}</h3><p>#{data[:c]} (Объявление №#{i})</p>"
  )
end

puts "--- Реклама создана! ---"
