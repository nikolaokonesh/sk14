# frozen_string_literal: true

class Components::Subscriptions::Button < Components::Base
  def initialize(
    user:,
    followable:
  )
    @user = user
    @followable = followable
  end

  def view_template
    div(id: dom_id(@followable, :subscription_button), class: "inline-flex items-center gap-4") do
      if @user.following?(@followable)
        render_unfollow_button
      else
        render_follow_button
      end
      render Components::Subscriptions::Counter.new(followable: @followable)
    end
  end

  private

  def render_follow_button
    button_to subscriptions_path(followable_id: @followable.id, followable_type: @followable.class.name),
      method: :post,
      class: "btn btn-primary" do
        plain "Подписаться"
    end
  end

  def render_unfollow_button
    subscription = @user.subscriptions.find_by(followable: @followable)
    button_to subscription_path(subscription),
      method: :delete,
      class: "btn btn-neutral" do
        plain "Отписаться"
    end
  end
end
