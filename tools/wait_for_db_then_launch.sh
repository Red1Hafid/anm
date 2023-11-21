while ! mysql --host=$DATABASE_HOST --port=$DATABASE_PORT --user=$DATABASE_USERNAME --password=$DATABASE_PASSWORD -e "USE $DATABASE_NAME; SELECT 1 LIMIT 1"; do
    sleep 5
done

bundle exec rake db:migrate
bundle exec rake db:seed

# bundle exec rake import:all

bundle exec rails server -b 0.0.0.0
