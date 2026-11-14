class PostParser
  POST_TYPE_KEYWORDS = {
    news: ["внимание!", "внимание", "срочно", "объявляем", "официально", "сообщаем", "информация", "важная информация"],
    gratitude: ["спасибо", "благодарю", "благодарность", "огромное спасибо", "низкий поклон", "спасибо большое"],
    question: ["подскажите", "кто знает", "где можно", "как найти", "вопрос", "помогите советом", "посоветуйте"]
  }.freeze

  ACTION_KEYWORDS = {
    sale: ["продам", "продаю", "продажа", "отдам", "сдам в аренду"],
    purchase: ["куплю", "ищу", "требуется", "нужен", "нужна", "нужно", "покупаю", "разыскивается"],
    exchange: ["обменяю", "обмен", "поменяю", "меняю"],
    gift: ["отдам даром", "бесплатно", "в подарок", "даром"],
    service: ["услуги", "сделаю", "выполню", "помогу", "предлагаю услуги"],
    rent: ["сдам", "сниму", "аренда", "прокат"]
  }.freeze

  def initialize(text, district = nil)
    @text = text.to_s.downcase.strip
    @district = district
  end

  def call
    result = {
      post_type: determine_post_type,
      action_type: nil,
      category: nil
    }

    # 🆕 Логируем для отладки
    Rails.logger.info "🔍 PostParser: post_type=#{result[:post_type]}"

    if [:news, :gratitude, :question].include?(result[:post_type])
      result[:category] = Category.find_by(slug: result[:post_type].to_s)
    else
      if result[:post_type] == :announcement
        result[:action_type] = determine_action_type
      end
      
      result[:category] = find_category

      if result[:category].nil?
        result[:category] = Category.find_by(slug: "general")
      end
    end

    Rails.logger.info "🔍 PostParser: category=#{result[:category]&.name}"
    result
  end

  private

  # ✅ ИСПРАВЛЕНО: используем \p{L} для работы с кириллицей
  def match_whole_word?(text, keyword)
    # (?<!\p{L}) — перед словом не должно быть буквы
    # (?!\p{L}) — после слова не должно быть буквы
    # Это работает с ЛЮБОЙ Unicode-буквой (кириллица, латиница и т.д.)
    regex = /(?<!\p{L})#{Regexp.escape(keyword)}(?!\p{L})/i
    text.match?(regex)
  end

  def determine_post_type
    POST_TYPE_KEYWORDS.each do |type, keywords|
      keywords.each do |keyword|
        if match_whole_word?(@text, keyword)
          Rails.logger.info "  → Найдено ключевое слово '#{keyword}' для типа :#{type}"
          return type
        end
      end
    end
    :announcement
  end

  def determine_action_type
    scores = {}
    
    ACTION_KEYWORDS.each do |action, keywords|
      score = 0
      keywords.each do |keyword|
        if match_whole_word?(@text, keyword)
          score += keyword.length
        end
      end
      scores[action] = score if score > 0
    end

    scores.max_by { |_, score| score }&.first
  end

  def find_category
    keywords = CategoryKeyword.includes(:category).to_a
    scores = Hash.new(0)
    
    keywords.each do |keyword|
      # Для категорий используем тот же метод match_whole_word?
      if match_whole_word?(@text, keyword.word.downcase)
        scores[keyword.category_id] += keyword.weight
      end
    end

    return nil if scores.empty?
    
    winning_category_id = scores.max_by { |_, score| score }.first
    Category.find_by(id: winning_category_id)
  end
end