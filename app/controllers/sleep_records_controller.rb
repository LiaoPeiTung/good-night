class SleepRecordsController < ApplicationController
  def clock_in
    user = User.find(params[:user_id])
    last_record = user.sleep_records.order(:created_at).last

    if last_record.present? && last_record.wake_up_at.nil?
      render json: { error: 'You have already clocked in and not yet clocked out.' }, status: :bad_request
    else
      record = user.sleep_records.create!(sleep_at: Time.zone.now)
      render json: user.sleep_records.order(:created_at)
    end
  end

  def clock_out
    user = User.find(params[:user_id])
    record = user.sleep_records.where(wake_up_at: nil).order(:created_at).last

    if record.nil?
      render json: { error: 'No sleep record found to clock out.' }, status: :bad_request
    else
      record.update!(wake_up_at: Time.zone.now)
      render json: user.sleep_records.order(:created_at)
    end
  end

  def friends_sleep_records
    user = User.find(params[:user_id])

    records = FriendsSleepRecordsService.new(user).call

    render json: records
  end
end
