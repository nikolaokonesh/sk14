# ==> app/lib/keyword_extractor.rb <==
class KeywordExtractor
  BLACK_LIST = %w[
    состояние цена фото звонить писать номер город район
    вчера сегодня завтра очень хорошо плохой хороший
    просто только этот тот который сообщения звонки
    доставка самовывоз бартер обмен уместен торг
    в наличии под заказ срочно объявление
    пожалуйста спасибо привет здравствуйте добрый день
    полный комплект коробка чек гарантия оригинал
    состоянии идеальном отличном б/у новый пользовались
    реальному покупателю скидка возможен небольшой
    вопросы личку ватсап старый телеграм личку
    связи переездом срочностью может после
  ].freeze

  def self.call(text)
    return [] if text.blank?

    clean_text = ActionController::Base.helpers.strip_tags(text.to_s).downcase
    words = clean_text.scan(/[а-яё]{4,}/)

    intents = []
    objects = Hash.new(0)
    intent_map = ListingsDictionary.stemmed_map

    words.each do |word|
      next if BLACK_LIST.include?(word)

      stem = RussianStemmer.stem(word)
      next if BLACK_LIST.any? { |bad| bad.start_with?(stem) || stem.start_with?(bad) }

      if (base_intent = intent_map[stem])
        intents << base_intent
      else
        objects[word] += 1
      end
    end

    top_objects = objects.sort_by { |_, count| -count }.first(3).map(&:first)
    (intents.uniq + top_objects).uniq.first(5)
  end
end
