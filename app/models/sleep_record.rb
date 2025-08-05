class SleepRecord < ApplicationRecord
  belongs_to :user

  def duration
    return unless sleep_at && wake_up_at
    wake_up_at - sleep_at
  end
end
