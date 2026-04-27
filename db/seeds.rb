# db/seeds.rb

puts "--- Очистка базы данных ---"
# Очищаем в правильном порядке, чтобы не нарушить связи
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
  { f: "Виктор", s: "vitya-kolyma" },
  { f: "Анна", s: "anya-post" }
]

users = [ admin ]
users_data.each do |u|
  users << User.create!(
    email: "#{u[:s]}@example.com",
    first_name: u[:f],
    last_name: "Житель",
    slug: u[:s]
  )
end

puts "--- Создание 20 Афиш ---"
now = Time.current.beginning_of_hour

# Список из 20 разнообразных событий
afishas_raw = [
  { t: "🎥 Кино: Чебурашка", h: 0, d: 1, c: "Семейный просмотр в ДК." },
  { t: "💃 Дискотека 90-х", h: 4, d: 1, c: "Танцы до упаду. Вход 200р." },
  { t: "🏆 Турнир по шахматам", h: 20, d: 2, c: "Запись в библиотеке." },
  { t: "🎤 Концерт Полярная Звезда", h: 24, d: 1, c: "Живой звук!" },
  { t: "🏀 Баскетбол: Школа vs Сборная", h: 30, d: 1, c: "Спортзал школы." },
  { t: "🛒 Фермерская ярмарка", h: 48, d: 2, c: "Свежее мясо и рыба." },
  { t: "📣 Собрание по газификации", h: 52, d: 1, c: "Встреча в администрации." },
  { t: "🧘 Йога на свежем воздухе", h: 60, d: 1, c: "С собой коврики." },
  { t: "🎨 Выставка художников", h: 72, d: 7, c: "Вход свободный." },
  { t: "🍲 Фестиваль ухи", h: 100, d: 1, c: "Конкурс на лучшую уху." },
  { t: "📚 Книжный клуб", h: 120, d: 1, c: "Обсуждаем классику." },
  { t: "⚽ Футбол: Районный кубок", h: 130, d: 1, c: "Финал на стадионе." },
  { t: "🎸 Квартирник у Михалыча", h: 140, d: 1, c: "Акустический вечер." },
  { t: "🧹 Субботник в парке", h: 145, d: 1, c: "Инвентарь выдадим." },
  { t: "🩺 День здоровья", h: 150, d: 1, c: "Прием врачей из города." },
  { t: "🧩 Игротека", h: 155, d: 1, c: "Настольные игры для всех." },
  { t: "🎿 Лыжный забег", h: 160, d: 1, c: "Закрытие сезона." },
  { t: "🗳️ Выборы в совет", h: 165, d: 1, c: "Важен голос каждого." },
  { t: "🍰 Конкурс выпечки", h: 168, d: 1, c: "Приходите пробовать!" },
  { t: "📽️ Ночь короткого метра", h: 170, d: 1, c: "Кино под открытым небом." }
]

afishas_raw.each do |a|
  entry = Entry.new(
    user: users.sample,
    entryable_type: "Post",
    entryable_attributes: {
      is_afisha: true,
      event_date: now + a[:h].hours,
      event_duration: a[:d],
      setting: { no_comments: false, duration: "forever" }
    },
    content: "<h2>#{a[:t]}</h2><p>#{a[:c]}</p>"
  )
  # Используем validate: false, чтобы обойти проверку "дата в прошлом"
  entry.save(validate: false)
end

puts "--- Создание 130 обычных постов ---"
topics = [
  "Кто знает, почему нет воды?", "Продам дрова, доставка Уралом.",
  "На переправе туман!", "Ищу попутчиков до города.",
  "Опять интернет тормозит..."
]

130.times do |i|
  Entry.create!(
    user: users.sample,
    entryable_type: "Post",
    entryable_attributes: {
      is_afisha: false,
      setting: { no_comments: (i % 15 == 0), duration: "forever" }
    },
    created_at: (i * 30).minutes.ago,
    content: topics.sample + " " + "!" * (i % 3 + 1)
  )
  print "." if i % 25 == 0
end

puts "\n--- Готово! База наполнена (150 записей) ---"
