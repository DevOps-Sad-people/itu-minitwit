# Use the official ruby
FROM ruby:3.3

# Set the working directory
WORKDIR /usr/src/app

# Install the required packages
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy the application code to the container
COPY . .

EXPOSE 4567

# Expose the port the app runs on
CMD ["ruby", "./minitwit.rb"]