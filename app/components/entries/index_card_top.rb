# frozen_string_literal: true

class Components::Entries::IndexCardTop < Components::Base
  def view_template
    div(class: "relative group mx-auto m-8 max-w-md") do
      # Эффектное свечение
      div(class: "absolute -inset-1 bg-gradient-to-r from-cyan-500 via-indigo-500 to-purple-600 rounded-2xl blur-xl opacity-60 transition duration-1000")
      
      div(class: "relative card bg-base-200 -rotate-1 shadow-2xl border border-white/5") do
        unless current_user
          div(class: "card-body p-8") do
            div(class: "flex justify-between items-start mb-6") do
              div do
                h2(class: "text-4xl font-black tracking-tighter bg-gradient-to-tr from-red-400 to-purple-600 bg-clip-text text-transparent") { "SK14" }
                span(class: "badge badge-primary badge-sm font-bold tracking-widest") { "СРЕДНЕКОЛЫМСК" }
              end
              span(class: "text-[10px] font-bold py-1 px-2 bg-success/10 text-success rounded-full uppercase") { "Free Access" }
            end

            ul(class: "flex flex-col gap-4 text-sm") do
              li(class: "text-xs font-bold text-base-content/40 uppercase tracking-widest") { "Твои возможности" }
              
              render_feature("Голос города", "Публикуй важные новости и личные объявления")
              render_feature("Прямой диалог", "Задавай вопросы сообществу и получай ответы")
              render_feature("Эпицентр событий", "Создавай стильные афиши и собирай людей")

              li(class: "text-xs font-bold text-base-content/40 uppercase tracking-widest mt-4") { "Технологии комфорта" }
              
              render_feature("Умный редактор", "Безупречное оформление твоего контента")
              render_feature("SEO-буст", "Автоподбор ключевых слов для охвата")
              render_feature("Машина времени", "Отложенная публикация по таймеру")
            end
          end
        end
        
        div(class: "p-4") do
          a(href: new_entry_path, class: "btn btn-primary w-full shadow-lg shadow-primary/20 text-lg normal-case") do
            current_user ? "Создать публикацию" : "Присоединиться к сообществу"
          end
        end
      end
    end
  end

  private

  def render_feature(title, description)
    li(class: "flex gap-3") do
      div(class: "mt-1") do
        plain raw lucide_icon("check-circle-2", class: "size-5 text-success/80")
      end
      div do
        p(class: "font-bold leading-none mb-1") { title }
        p(class: "text-xs text-base-content/60") { description }
      end
    end
  end
end
