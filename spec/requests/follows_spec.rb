require 'rails_helper'

RSpec.describe "Follows API", type: :request do
  let!(:user) { User.create!(name: "LiaoPeiTung") }
  let!(:other_user) { User.create!(name: "Tester") }

  describe "POST /users/:user_id/follow/:followee_id" do
    context "when following another user" do
      it "creates a follow relationship" do
        post "/users/#{user.id}/follow/#{other_user.id}"

        expect(response).to have_http_status(:success)
        expect(Follow.exists?(follower: user, followee: other_user)).to be true
        expect(JSON.parse(response.body)["message"]).to eq("Followed successfully.")
      end
    end

    context "when trying to follow self" do
      it "returns an error" do
        post "/users/#{user.id}/follow/#{user.id}"

        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)["error"]).to eq("You cannot follow yourself.")
      end
    end

    context "when following the same user twice" do
      before do
        Follow.create!(follower: user, followee: other_user)
      end

      it "returns an error" do
        post "/users/#{user.id}/follow/#{other_user.id}"

        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)["error"]).to include("Already following this user")
      end
    end
  end

  describe "DELETE /users/:user_id/unfollow/:followee_id" do
    context "when unfollowing an existing followee" do
      before do
        Follow.create!(follower: user, followee: other_user)
      end

      it "destroys the follow relationship" do
        delete "/users/#{user.id}/unfollow/#{other_user.id}"

        expect(response).to have_http_status(:success)
        expect(Follow.exists?(follower: user, followee: other_user)).to be false
        expect(JSON.parse(response.body)["message"]).to eq("Unfollowed successfully.")
      end
    end

    context "when unfollowing a non-followed user" do
      it "returns not found error" do
        delete "/users/#{user.id}/unfollow/#{other_user.id}"

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)["error"]).to eq("Follow relation not found.")
      end
    end
  end
end
