class SubscriptionsController < ApplicationController
  include ActionView::RecordIdentifier
  def create
    @followable = find_followable
    Current.user.follow(@followable)

    # if @followable.is_a?(User)
    #   NewFollowerNotifier.with(follower: Current.user).deliver(@followable)
    # end

    render turbo_stream: [
      turbo_stream.replace(dom_id(@followable, :subscription_button),
        Components::Subscriptions::Button.new(user: Current.user, followable: @followable))
    ]
  end

  def destroy
    @subscription = Current.user.subscriptions.find(params[:id])
    @followable = @subscription.followable
    @subscription.destroy

    render turbo_stream: [
      turbo_stream.replace(dom_id(@followable, :subscription_button),
        Components::Subscriptions::Button.new(user: Current.user, followable: @followable))
    ]
  end

  private

  def find_followable
    params[:followable_type].constantize.find(params[:followable_id])
  end
end
