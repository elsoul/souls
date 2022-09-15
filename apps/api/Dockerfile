FROM ruby:3.1.2-slim-buster

RUN apt-get update -qq && apt-get install -y redis-server libcurl3-dev
RUN apt update && apt install -y \
        build-essential libpq-dev  \
     && rm -rf /var/lib/apt/lists/*
     
USER root

RUN mkdir /myapp
WORKDIR /myapp

COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN gem install bundler:2.3.22
RUN bundle --without development test
COPY . /myapp

CMD ["foreman", "start"]