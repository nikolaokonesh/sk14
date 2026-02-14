module User::Validate
  extend ActiveSupport::Concern

  included do
    validates_length_of :email, maximum: 50

    noname = %w[Админ Менеджер Автор Агент майл Майл Инфо инфо]

    validates :name,
              presence: { message: "Напишите свое имя, фамилию, отчество" },
              format: {
                with: /^[A-Za-zА-Яа-яЁё"\s-]+$/,
                multiline: true,
                message: "Только буквы, цифры и дефис -"
              },
              exclusion: {
                in: noname,
                message: "%<value>s - запрещено использовать это имя."
              },
              length: {
                maximum: 50
              },
              on: :update

    validates :slug,
              presence: true,
              uniqueness: true,
              format: {
                with: /^[a-z0-9-]+$/,
                multiline: true,
                message: "Только англ.буквы и цифры с дефисом"
              },
              length: {
                maximum: 50
              },
              on: :update
  end
end
