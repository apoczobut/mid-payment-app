# Middleware Payment App

A Ruby on Rails middleware service that integrates with a Partner’s Payment API, handles secure redirects, and processes payment returns.

⸻

## Getting Started with Docker

This app is containerized using Docker and Docker Compose.

### 1. Clone the repository

git clone https://github.com/your-org/middleware-payment-app.git
cd middleware-payment-app

### 2. Build the Docker image

```bash
docker-compose build
```
### 3. Run the app in interactive mode

```bash
docker-compose run --rm --service-ports web bash
```
This will start the Rails container and drop you into an interactive shell.

### 4. Install dependencies

```bash
bundle install
```
⸻

## Running Tests (RSpec)

Once inside the Docker container shell:

### 5. Setup the test database

```bash
bundle exec rails db:create db:migrate RAILS_ENV=test
```
### 6. Run the test suite
```bash
bundle exec rspec
```

You should see green specs confirming correct integration and behavior.

To run an individual test file:

```bash
bundle exec rspec spec/requests/payments_spec.rb
```
⸻
## Features
  • POST /api/purchase: Authenticates and initiates a purchase via the partner API.
  • POST /customer/returns: Handles return flows and notifies third-party API.
  • PaymentSession model to securely track and validate return_url.
  • ReturnUrlValidator service to whitelist allowed return domains.
⸻
## Project Structure
```
app/
  controllers/
    payments_controller.rb
  models/
    payment_session.rb
  services/
    partner_client.rb
    return_url_validator.rb
    purchase_notifier.rb
spec/
  requests/
    payments_spec.rb
  rails_helper.rb
  spec_helper.rb
db/
  migrate/
    xxxx_create_payment_sessions.rb
```

## MIT License
⸻
Developed for interview assessment purposes
