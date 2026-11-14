module PostsHelper
  # Умная метка времени с учётом часового пояса улуса
  def smart_time(post)
    time = post.published_at || post.created_at
    return "" if time.nil?

    # Конвертируем в часовой пояс улуса
    district = post.district
    local = district ? time.in_time_zone(district.time_zone) : time.in_time_zone

    now = Time.current
    diff = now - local

    case
    when diff < 5.minutes
      "только что"
    when diff < 1.hour
      "#{(diff / 60).to_i} мин назад"
    when local.to_date == Date.current
      "сегодня #{local.strftime('%H:%M')}"
    when local.to_date == Date.current - 1
      "вчера #{local.strftime('%H:%M')}"
    when diff < 7.days
      days = (Date.current - local.to_date).to_i
      "#{days} #{plural_ru(days, 'день', 'дня', 'дней')} назад"
    when local.year == now.year
      "#{local.day} #{RU_MONTHS_SHORT[local.month]}"
    else
      local.strftime("%d.%m.%y")
    end
  end

  def freshness_class(post)
    time = post.published_at || post.created_at
    return "badge-ghost" if time.nil?

    # Конвертируем в часовой пояс улуса
    district = post.district
    local = district ? time.in_time_zone(district.time_zone) : time.in_time_zone

    case Time.current - local
    when 0..1.day   then "badge-success"
    when 1.day..3.days then "badge-info"
    when 3.days..14.days then "badge-ghost"
    else "badge-ghost opacity-50"
    end
  end

  def time_badge(post, css: "badge badge-sm")
    time = post.published_at || post.created_at
    return "" if time.nil?

    # Конвертируем в часовой пояс улуса
    district = post.district
    local = district ? time.in_time_zone(district.time_zone) : time.in_time_zone

    tag.time(
      smart_time(post),
      datetime: time.iso8601,
      title: l(local, format: :full),
      class: "#{css} #{freshness_class(post)}"
    )
  end

  private

  RU_MONTHS_SHORT = {
    1 => "янв", 2 => "фев", 3 => "мар", 4 => "апр",
    5 => "мая", 6 => "июн", 7 => "июл", 8 => "авг",
    9 => "сен", 10 => "окт", 11 => "ноя", 12 => "дек"
  }.freeze

  def plural_ru(n, one, few, many)
    n = n.abs % 100
    n1 = n % 10
    return many if n > 10 && n < 20
    return few  if n1 > 1 && n1 < 5
    return one  if n1 == 1
    many
  end
end