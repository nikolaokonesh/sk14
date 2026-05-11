# frozen_string_literal: true

module User::Validate
  extend ActiveSupport::Concern

  RESERVED_NAMES = %w[Админ Менеджер Автор Агент майл Майл Инфо инфо].freeze
  NAME_FORMAT = /^[A-Za-zА-Яа-яЁё"\s-]+$/
  SLUG_FORMAT = /^[a-z0-9-]+$/

  included do
    validates_length_of :email, maximum: 50
    normalizes :email, with: ->(email) { email.strip.downcase }
    validates :email, presence: true, uniqueness: true

    validates :name,
              presence: { message: "Напишите свое имя, фамилию, отчество" },
              format: {
                with: NAME_FORMAT,
                multiline: true,
                message: "Только буквы, цифры и дефис -"
              },
              exclusion: {
                in: RESERVED_NAMES,
                message: "%<value>s - запрещено использовать это имя."
              },
              length: { maximum: 50 },
              on: :update

    validates :slug,
              presence: true,
              uniqueness: true,
              format: {
                with: SLUG_FORMAT,
                multiline: true,
                message: "Только англ.буквы и цифры с дефисом"
              },
              length: { maximum: 50 },
              on: :update
  end
end
