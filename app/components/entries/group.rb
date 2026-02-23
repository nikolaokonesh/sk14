class Components::Entries::Group < Components::Base
  def initialize(
      user:,
      bubbles_id: nil,
      wrapper_class: "chat chat-start items-end m-1",
      wrapper_data: {},
      avatar_data: {},
      bubbles_class: "flex flex-col -ml-2",
      avatar_sticky_class: "sticky bottom-2",
      group_wrapper_id: nil
    )
    @user = user
    @bubbles_id = bubbles_id
    @wrapper_class = wrapper_class
    @wrapper_data = wrapper_data
    @avatar_data = avatar_data
    @bubbles_class = bubbles_class
    @avatar_sticky_class = avatar_sticky_class
    @group_wrapper_id = group_wrapper_id
  end

  def view_template
    div(id: @group_wrapper_id, class: @wrapper_class, data: @wrapper_data) do
      div(class: "chat-image avatar flex items-and  #{@avatar_sticky_class}", data: @avatar_data) do
        div(class: "w-10 rounded-full transition-all") do
          render Components::Users::Avatar.new(user: @user)
        end
      end
      div(id: @bubbles_id, class: @bubbles_class) do
        yield if block_given?
      end
    end
  end
end
