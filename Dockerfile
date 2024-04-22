FROM ruby:3.1.0

RUN mkdir /ascenda-challenge
WORKDIR /ascenda-challenge

RUN apt-get update

# BUILD DOCKER IMAGE ascenda-challenge
# docker build -t 'ascenda-challenge' -f /path/to/local/code/Dockerfile .

# BUILD CONTAINER ascenda-challenge
# docker run --expose 3000 -p 3000:3000 --name ascenda-challenge -it -v /path/to/local/code:/ascenda-challenge -d ascenda-challenge

# START CONTAINER ascenda-challenge
# docker start ascenda-challenge

# LOG IN TO CONTAINER ascenda-challenge
# docker exec -it ascenda-challenge bash

# RUN FOLLOWING COMMANDS
#   - bundle install
#   - rails db:migrate RAILS_ENV=development
#   - apt-get -y install --no-install-recommends sqlite3 //optional but helps in visualizing db data
#   - rails db:seed // optional, to populate developement data
#   - rspec // optional, to check that all test cases are passing

# RUN rails server
# rails s -b 0.0.0.0 -p 3000

# APIs accessible at: http://localhost:3000/