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
end
