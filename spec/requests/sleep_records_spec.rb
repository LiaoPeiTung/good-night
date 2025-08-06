require 'rails_helper'

RSpec.describe "SleepRecords API", type: :request do
  let!(:user) { User.create!(name: "Tester") }

  describe "POST /clock_in" do
    context "when user has no active sleep record" do
      it "creates a new sleep record and returns all records" do
        post '/clock_in', params: { user_id: user.id }
        expect(response).to have_http_status(:success)

        json = JSON.parse(response.body)
        expect(json).to be_an(Array)
        expect(json.first['sleep_at']).not_to be_nil
        expect(json.first['wake_up_at']).to be_nil
      end
    end

    context "when previous record is completed" do
      before do
        user.sleep_records.create!(sleep_at: 2.days.ago, wake_up_at: 1.day.ago)
      end

      it "creates a new sleep record and returns all records" do
        post '/clock_in', params: { user_id: user.id }
        expect(response).to have_http_status(:success)

        json = JSON.parse(response.body)
        expect(json).to be_an(Array)
        expect(json.first['sleep_at']).not_to be_nil
        expect(json.first['wake_up_at']).not_to be_nil
        expect(json.last['sleep_at']).not_to be_nil
        expect(json.last['wake_up_at']).to be_nil
      end
    end 

    context "when user already clocked in without clocking out" do
      before do
        user.sleep_records.create!(sleep_at: 1.hour.ago)
      end

      it "returns error preventing duplicate clock in" do
        post '/clock_in', params: { user_id: user.id }
        expect(response).to have_http_status(:bad_request)

        json = JSON.parse(response.body)
        expect(json['error']).to eq('You have already clocked in and not yet clocked out.')
      end
    end
  end

  describe "PATCH /clock_out" do
    context "when user has an active sleep record" do
      before do
        user.sleep_records.create!(sleep_at: 1.hour.ago)
      end

      it "clocks out the last sleep record and returns all records" do
        patch '/clock_out', params: { user_id: user.id }
        expect(response).to have_http_status(:success)

        json = JSON.parse(response.body)
        last_record = json.last
        expect(last_record['wake_up_at']).not_to be_nil
      end
    end

    context "when user has no active sleep record to clock out" do
      it "returns error when no sleep record to clock out" do
        patch '/clock_out', params: { user_id: user.id }
        expect(response).to have_http_status(:bad_request)

        json = JSON.parse(response.body)
        expect(json['error']).to eq('No sleep record found to clock out.')
      end
    end
  end

  describe "GET /users/:user_id/friends_sleep_records" do
    let!(:user) { User.create!(name: "User A") }
    let!(:friend_1) { User.create!(name: "Friend 1") }
    let!(:friend_2) { User.create!(name: "Friend 2") }
    let!(:non_friend) { User.create!(name: "Stranger") }

    before do
      # Establish following relationships
      Follow.create!(follower: user, followee: friend_1)
      Follow.create!(follower: user, followee: friend_2)

      # Valid sleep records
      friend_1.sleep_records.create!(
        sleep_at: 3.days.ago.change(hour: 22),
        wake_up_at: 2.days.ago.change(hour: 4)
      )
      friend_2.sleep_records.create!(
        sleep_at: 2.days.ago.change(hour: 23),
        wake_up_at: 1.days.ago.change(hour: 7)
      )

      # Invalid sleep records
      non_friend.sleep_records.create!(
        sleep_at: 2.days.ago.change(hour: 21),
        wake_up_at: 1.days.ago.change(hour: 6)
      )
      friend_1.sleep_records.create!(sleep_at: 1.day.ago)  # without clock_out
      friend_1.sleep_records.create!(  # more than 1 week
        sleep_at: 10.days.ago,
        wake_up_at: 9.days.ago
      )
    end

    it "returns valid records of followees from the past week, ordered by duration desc" do
      get "/users/#{user.id}/friends_sleep_records"
      expect(response).to have_http_status(:success)

      json = JSON.parse(response.body)
      expect(json).to be_an(Array)
      expect(json.length).to eq(2)

      # Ensure correct sorting by sleep duration
      expect(json.first["user_name"]).to eq("Friend 2")
      expect(json.first["duration"].round(2)).to eq(8.0)
      expect(json.last["user_name"]).to eq("Friend 1")
      expect(json.last["duration"].round(2)).to eq(6.0)
       
      # Ensure unfollowed users are not included
      expect(json.map { |r| r["user_name"] }).not_to include("Stranger")
    end
  end
end
