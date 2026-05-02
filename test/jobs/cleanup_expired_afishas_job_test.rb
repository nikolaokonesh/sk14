require "test_helper"

class CleanupExpiredAfishasJobTest < ActiveJob::TestCase
  test "updates afisha_status for expired afisha" do
    post = Post.create!(
      is_afisha: true,
      event_date: 3.hours.ago,
      event_duration: 1
    )
    post.update_column(:afisha_status, "ongoing")

    CleanupExpiredAfishasJob.perform_now

    assert_equal "finished", post.reload.afisha_status
  end

  test "does not overwrite manual_finished for automatically finished afisha" do
    post = Post.create!(
      is_afisha: true,
      event_date: 3.hours.ago,
      event_duration: 1,
      manual_finished: false
    )
    post.update_column(:afisha_status, "ongoing")

    CleanupExpiredAfishasJob.perform_now

    assert_equal false, post.reload.manual_finished
    assert_equal "finished", post.afisha_status
  end
end
