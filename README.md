# README

# Good Night API

A simple RESTful Rails API to help users clock in/out sleep records, follow/unfollow friends, and view friends’ weekly sleep durations.

## Tech Stack

- Ruby on Rails 7
- PostgreSQL
- RSpec (for testing)
- Gitpod (for cloud development)

---

## Getting Started

Click to start development in browser:
[Open in Gitpod](https://gitpod.io/#https://github.com/LiaoPeiTung/good-night)

---

## API Endpoints

| Action                 | Method   | Endpoint                                | Description                                                             |
| ---------------------- | -------- | --------------------------------------- | ----------------------------------------------------------------------- |
| Clock In               | `POST`   | `/clock_in`                             | Record `sleep_at` time                                                  |
| Clock Out              | `PATCH`  | `/clock_out`                            | Update latest record with `wake_up_at`                                  |
| Follow User            | `POST`   | `/users/:user_id/follow/:followee_id`   | Follow another user                                                     |
| Unfollow User          | `DELETE` | `/users/:user_id/unfollow/:followee_id` | Unfollow another user                                                   |
| Friends’ Sleep Records | `GET`    | `/users/:user_id/friends_sleep_records` | View sleep records of followed users in past 7 days, sorted by duration |


## Running Tests

- bundle exec rspec

---