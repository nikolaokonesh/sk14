# db/seeds.rb

puts "--- Очистка базы данных ---"
EntryRead.delete_all
ActionText::RichText.delete_all
Entry.delete_all
Post.delete_all
User.delete_all

puts "--- Создание пользователей ---"
# Вы - главный
admin = User.create!(
  email: "nikolaokonesh@gmail.com",
  first_name: "Николай",
  last_name: "Оконешников",
  slug: "nikola"
)

# Жители
users = [ admin ]
first_names = %w[Алексей Мария Иван Елена Пётр Светлана Дмитрий Анна Сергей]
last_names = %w[Петров Сидорова Волков Кузнецова Попов Морозова Павлов Соколова Козлов]

9.times do |i|
  f_name = first_names[i]
  l_name = last_names[i]
  users << User.create!(
    email: "user#{i+1}@example.com",
    first_name: f_name,
    last_name: l_name,
    slug: "#{f_name.downcase}-#{i+1}"
  )
end

puts "--- Создание 100 постов с валидным контентом ---"

topics = [
  "Прогноз погоды: обещают сильные заморозки до конца недели, будьте осторожны.",
  "Вчера на реке Колыма открыли официальный ледовый переход для легковых авто.",
  "Продам отличный снегоход, пробег небольшой, состояние идеальное. Торг уместен.",
  "Ищу попутчиков до Якутска на следующую среду. Выезд рано утром, есть два места.",
  "В местном доме культуры пройдет выставка народных промыслов. Вход свободный для всех.",
  "Кто знает график работы почтового отделения на праздничные дни? Поделитесь плиз.",
  "На центральной улице нашли ключи от машины. Верну владельцу при описании брелка."
]

100.times do |i|
  author = users.sample

  # Создаем запись. Контент передаем сразу, чтобы сработала валидация content_length
  entry = Entry.new(
    user: author,
    entryable_type: "Post",
    entryable_attributes: {
      premiera: i.days.ago,
      setting: { no_comments: [ true, false ].sample }
    },
    created_at: (100 - i).hours.ago,
    content: topics.sample # Валидатор в Entry::Content проверит эту строку
  )

  unless entry.save
    puts "Ошибка при создании записи #{i}: #{entry.errors.full_messages.join(', ')}"
    next
  end

  # Каждую вторую чужую запись помечаем как прочитанную вами
  if i.even? && author != admin
    admin.entry_reads.create!(entry: entry, read_at: (i + 1).hours.ago)
  end

  print "." if i % 10 == 0
end

puts "\n--- Готово! Проверка валидаций пройдена ---"
puts "Всего постов: #{Entry.count}"
