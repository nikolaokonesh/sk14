# app/lib/keyword_extractor.rb
class KeywordExtractor
  # Расширенный список слов-паразитов для объявлений
  STOP_WORDS = %w[
    этот очень меня тебе чтобы если когда только было будет есть был были
    фото видео цена рубль рубля рублей цена звоните пишите номер телефон
    состояние хороший отличный новый бу подержанный срочно торг обмен
    просьба добрый день здравствуйте привет пожалуйста спасибо через
    могу можно нельзя один два три пять десять много мало самый очень
    какой такой который весь свой наш ваш ихний его ее ваш
    вообще просто прямо сейчас здесь там тут где куда откуда
    внимание осмотр самовывоз доставка область район город улица
  ].freeze

  def self.call(text)
    return [] if text.blank?

    clean_text = ActionController::Base.helpers.strip_tags(text.to_s).downcase
    # Берем слова от 4 букв, исключая цифры и спецсимволы
    words = clean_text.scan(/[а-яё]{4,}/)

    intents = []
    objects = Hash.new(0)
    intent_map = ListingsDictionary.stemmed_map

    words.each do |word|
      stem = RussianStemmer.stem(word)

      # 1. Если это "Намерение" (Продажа/Покупка) - берем всегда
      if (base_intent = intent_map[stem])
        intents << base_intent
      # 2. Если слова нет в словаре И оно не в стоп-листе - это кандидат в "Предметы"
      elsif !STOP_WORDS.include?(word) && !STOP_WORDS.include?(stem)
        objects[stem] += 1
      end
    end

    # Сортируем предметы по частоте (самые важные вперед)
    top_objects = objects.sort_by { |_, count| -count }.first(3).map(&:first)

    # Итого: Намерения + топ-3 предмета (всего не более 6 тегов)
    (intents.uniq + top_objects).uniq.first(6)
  end
end
