FROM ruby:3.1.0

# Create working directory in the container
RUN mkdir /ascenda-challenge

# Set the working directory in the container
WORKDIR /ascenda-challenge

# Get update
RUN apt-get update

# Copy Gemfile and Gemfile.lock into the container
COPY Gemfile Gemfile.lock ./

# Install dependencies using bundler
RUN bundle install

# Copy the rest of the application code into the container
COPY . .

# Expose port 3000 to the outside world
EXPOSE 3000

# Command to start the Rails server
CMD ["rails", "server", "-b", "0.0.0.0", "-p", "3000"]

# APIs accessible at: http://localhost:3000/