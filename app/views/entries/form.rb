# frozen_string_literal: true

class Views::Entries::Form < Views::Base
  def initialize(entry:)
    @entry = entry
  end

  def page_title = @entry.new_record? ? "Новый пост" : "Изменить пост"

  def view_template
    is_afisha = @entry.entryable.is_afisha

    # Подключаем контроллер post-form для управления видимостью полей
    div(class: "py-4", data_controller: "post-form") do
      h1(class: "text-3xl font-black mb-4 px-2 tracking-tight") { page_title }

      form_with(model: @entry, class: "space-y-6") do |form|
        # --- БЛОК СОДЕРЖАНИЯ ---
        div(class: "form-control") do
          if @entry.errors[:content].any?
            p(class: "text-error text-sm font-bold mb-2") { @entry.errors[:content].join(", ") }
          else
            form.label :content, "Содержание", class: "label font-bold opacity-70 mb-2"
          end

          div(class: "relative") do
            render Components::Shared::BgGradient.new
            plain form.rich_text_area :content, placeholder: "Добавить описание", require: true, class: "lexxy-content"
          end
        end

        form.fields_for :entryable do |fields|
          # --- 1. ПЕРЕКЛЮЧАТЕЛЬ РЕЖИМА АФИША ---
          div(class: "form-control bg-cyan-500/10 m-2 rounded-md p-2") do
            label(class: "label cursor-pointer justify-between py-2 px-4 bg-cyan-500/20 rounded-xl") do
              div(class: "flex items-center gap-4") do
                plain raw lucide_icon("calendar-days", class: "text-cyan-500")
                span(class: "font-bold text-cyan-500 uppercase text-sm tracking-widest") { "Режим АФИША" }
              end
              # Чекбокс-триггер для Stimulus
              plain fields.check_box :is_afisha,
                    {
                      class: "toggle toggle-accent",
                      data: {
                        post_form_target: "checkbox",
                        action: "change->post-form#toggle"
                      }
                    }
            end
          end

          # --- 2. ПОЛЯ АФИШИ (Скрыты по умолчанию) ---
          #
          div(class: [ "m-2 mb-6", ("hidden" unless is_afisha) ], data_post_form_target: "afishaFields") do
            div(class: "bg-cyan-800 p-4 rounded-md border-2 border-cyan-800/30") do
              # Вывод ошибки валидации
              if @entry.entryable.errors[:event_date].any?
                p(class: "text-error text-sm font-bold mb-2") { @entry.entryable.errors[:event_date].join(", ") }
              else
                label(class: "label font-bold opacity-70") { "Дата и время события" }
              end
              plain fields.datetime_field :event_date,
                    class: [
                      "input input-border border-cyan-500 w-full bg-base-300/70 rounded-xl text-lg",
                      ("input-error" if @entry.entryable.errors[:event_date].any?) # Подсветка рамки красным
                    ]
              p(class: "text-[10px] mt-2 text-center uppercase font-bold") do
                span(class: "badge badge-error badge-xs rounded-full mr-1") { }
                span(class: "opacity-50") { "Пост появится за неделю до события и будет автоматически удален после завершения." }
              end
            end
          end

          # --- 3. СТАНДАРТНЫЕ ПОЛЯ (Срок и Категории) ---
          div(class: [ "", ("hidden" if is_afisha) ], data_post_form_target: "standardFields") do
            # Срок публикации
            div(class: "form-control bg-success/20 m-2 rounded-md p-2") do
              div(class: "flex items-center justify-between") do
                label(class: "label font-bold opacity-70 mr-2") do
                  plain raw lucide_icon("clock-fading", class: "mr-2 size-4")
                  plain "Срок публикации"
                end
                plain fields.select :duration,
                      [
                        [ "Навсегда", "forever" ],
                        [ "на 3 дня", "three" ],
                        [ "Неделя", "week" ],
                        [ "Месяц", "month" ],
                        [ "Полгода", "half_year" ],
                        [ "Год", "year" ]
                      ],
                      {},
                      { class: "select select-bordered bg-base-300/70 rounded-xl select-sm" }
              end
              div(class: "block text-[10px] opacity-40 w-full text-center mt-1") { "По истечении срока пост будет удален" }
            end

            # Категории (Твои чекбоксы с тегами)
            div(class: "form-control bg-accent/20 m-2 rounded-md p-2") do
              div(class: "form-control", data_controller: "form-select-tags") do
                label(class: "label font-bold opacity-70") do
                  plain raw lucide_icon("tags", class: "mr-2 size-4")
                  plain "Категории сообщения"
                end

                div(class: "flex flex-wrap gap-2 p-2 bg-base-300/20 rounded-2xl") do
                  Post::TAG_CONFIG.each do |key, data|
                    is_selected = @entry.entryable.send(key)

                    label(class: "cursor-pointer group", data_action: "click->form-select-tags#toggle") do
                      plain fields.check_box key, {
                        checked: is_selected,
                        class: "hidden",
                        data: { form_select_tags_target: "checkbox" }
                      }

                      div(
                        class: [
                          "badge badge-lg border-2 transition-all duration-200 font-bold",
                          (is_selected ? "#{data[:color]} border-transparent scale-105" : "badge-ghost opacity-50")
                        ],
                        data_active_color: data[:color]
                      ) { data[:label] }
                    end
                  end
                end
              end
            end
          end # Конец стандартных полей

          # --- 4. НАСТРОЙКИ КОММЕНТАРИЕВ (Всегда видны) ---
          div(class: "form-control bg-info/20 m-2 rounded-md p-2") do
            label(class: "label cursor-pointer justify-start gap-4 py-2 bg-base-300/30 rounded-xl px-4") do
              plain raw lucide_icon("messages-square", class: "size-4")
              span(class: "label-text font-medium") { "Без комментариев" }
              plain fields.check_box :no_comments, checked: @entry.entryable.no_comments?, class: "checkbox checkbox-primary"
            end
          end
        end

        form.hidden_field :entryable_type, value: "Post"

        # --- КНОПКИ ДЕЙСТВИЯ ---
        div(class: "flex items-center gap-3 pt-4 px-2") do
          plain form.submit "Опубликовать",
                class: "btn btn-primary shadow-lg shadow-primary/20 flex-1 md:flex-none h-14 rounded-2xl text-lg font-black",
                data: { turbo_submits_with: "Публикация..." }

          a(href: @entry.new_record? ? root_path : entry_path(@entry),
            class: "btn btn-ghost h-14 rounded-2xl",
            data: { turbo_prefetch: "false" }) { "Отмена" }
        end
      end
    end
  end
end
