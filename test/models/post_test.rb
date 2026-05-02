require "test_helper"

class PostTest < ActiveSupport::TestCase
  test "syncs afisha_status for upcoming afisha" do
    post = Post.create!(
      is_afisha: true,
      event_date: 2.days.from_now,
      event_duration: 2
    )

    assert_equal "upcoming", post.afisha_status
    assert_equal :upcoming, post.afisha_state
  end

  test "sets afisha_status to finished when manual_finished is true" do
    post = Post.create!(
      is_afisha: true,
      event_date: 1.day.from_now,
      event_duration: 2,
      manual_finished: true
    )

    assert_equal "finished", post.afisha_status
    assert_equal :finished, post.afisha_state
  end

  test "clears afisha_status when converted to regular post" do
    post = Post.create!(
      is_afisha: true,
      event_date: 1.day.from_now,
      event_duration: 2
    )

    post.update!(is_afisha: false)

    assert_nil post.afisha_status
  end
end
