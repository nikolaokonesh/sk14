class DeliveryMethods::TurboStream < ApplicationDeliveryMethod
  # To use this delivery method, specify the class option in your notifier.
  #
  #   class MyNotifer < ApplicationNotifier
  #     deliver_by :turbo_stream, class: "TurboStream"
  #   end

  # Specify required options for the deliver_by config block
  # required_options :foo, :bar

  def deliver
    return unless recipient.is_a?(User)
    notification.broadcast_update_to_bell
  end
end
