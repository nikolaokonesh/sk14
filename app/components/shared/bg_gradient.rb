# frozen_string_literal: true

class Components::Shared::BgGradient < Components::Base
  def view_template
    # Используем встроенный в Tailwind механизм произвольных значений [...]
    # Мы анимируем background-position, чтобы цвета "плавали"
    div(
      class: [
        "absolute -inset-2 opacity-20 blur-xl rounded-[3rem]",
        "bg-gradient-to-r from-cyan-400 via-indigo-500 via-purple-500 to-pink-500",
        "bg-[length:200%_200%]",
        # Эта магия запускает плавное движение влево-вправо без правок в конфиге
        "animate-[gradient_6s_ease_infinite]"
      ],
      style: "animation: gradient-shift 10s ease infinite; background-size: 400% 400%;"
    )
  end
end
