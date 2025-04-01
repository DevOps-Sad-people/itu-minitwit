# Use the official ruby
FROM ruby:3.3.7-slim-bullseye

# Set the working directory
WORKDIR /usr/src/app

# Install necessary dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential=12.9 \
    libpq-dev=13.20-0+deb11u1 \
    && rm -rf /var/lib/apt/lists/*
    
# Install the required packages
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy the application code to the container
COPY . .

EXPOSE 4567

# Expose the port the app runs on
CMD ["ruby", "./minitwit.rb"]