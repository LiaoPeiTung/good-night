class SleepRecordsController < ApplicationController
  def clock_in
    user = User.find(params[:user_id])
    last_record = user.sleep_records.order(:created_at).last

    if last_record.present? && last_record.wake_up_at.nil?
      render json: { error: 'You have already clocked in and not yet clocked out.' }, status: :bad_request
    else
      record = user.sleep_records.create!(sleep_at: Time.current)
      render json: user.sleep_records.order(:created_at)
    end
  end

  def clock_out
    user = User.find(params[:user_id])
    record = user.sleep_records.where(wake_up_at: nil).order(:created_at).last

    if record.nil?
      render json: { error: 'No sleep record found to clock out.' }, status: :bad_request
    else
      record.update!(wake_up_at: Time.current)
      render json: user.sleep_records.order(:created_at)
    end
  end

  def friends_sleep_records
    user = User.find(params[:user_id])

    sleep_records = SleepRecord
      .joins(:user)
      .where(user_id: user.followees.select(:id))
      .where("sleep_at >= ? AND wake_up_at IS NOT NULL", 1.week.ago)
      .select("sleep_records.*, users.name AS user_name, EXTRACT(EPOCH FROM (wake_up_at - sleep_at))/3600 AS duration")
      .order("duration DESC")

    render json: sleep_records.map { |record|
      {
        user_name: record.user_name,
        sleep_at: record.sleep_at,
        wake_up_at: record.wake_up_at,
        duration: record.duration.to_f.round(2)
      }
    }
  end
end
