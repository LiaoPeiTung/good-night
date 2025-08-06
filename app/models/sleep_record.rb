class SleepRecord < ApplicationRecord
  belongs_to :user

  validate :wake_up_after_sleep

  private

  def wake_up_after_sleep
    return if wake_up_at.blank? || sleep_at.blank?
    if wake_up_at <= sleep_at
      errors.add(:wake_up_at, "must be after sleep_at")
    end
  end
end
