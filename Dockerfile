FROM ruby:3.0.3 as ruby

RUN apt-get update -qq && apt-get install -y nodejs mariadb-client

RUN mkdir /root/.ssh

RUN chmod 700 /root/.ssh

RUN mkdir /srv/Alithya-ANM-WEB

WORKDIR /srv/Alithya-ANM-WEB

COPY Gemfile /srv/Alithya-ANM-WEB

RUN bundle install

COPY . /srv/Alithya-ANM-WEB

RUN rm -rf Gemfile.lock

RUN bundle exec rake assets:precompile

EXPOSE 3000

ENTRYPOINT ./tools/wait_for_db_then_launch.sh