class FriendsSleepRecordsService
  def initialize(user)
    @user = user
  end

  def call
    records = SleepRecord
      .joins(:user)
      .where(user_id: @user.followees.select(:id))
      .where("sleep_at >= ? AND wake_up_at IS NOT NULL", 1.week.ago)
      .select("sleep_records.*, users.name AS user_name, EXTRACT(EPOCH FROM (wake_up_at - sleep_at))/3600 AS duration")
      .order("duration DESC")

    records.map do |record|
      {
        user_name: record.user_name,
        sleep_at: record.sleep_at,
        wake_up_at: record.wake_up_at,
        duration: record.duration.to_f.round(2)
      }
    end
  end
end
