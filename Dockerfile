# Dockerfile para producción (multi-stage)
FROM ruby:3.2.3 AS builder

RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev curl && \
    curl -fsSL https://deb.nodesource.com/setup_16.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g yarn

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install --without development test

# Instala dependencias JS
COPY package.json yarn.lock ./
RUN yarn install --ignore-engines

COPY . .

# Precompila assets
RUN bundle exec rails assets:precompile

# Imagen final
FROM ruby:3.2.3

RUN apt-get update -qq && \
    apt-get install -y libpq-dev nodejs

WORKDIR /app

COPY --from=builder /app .

EXPOSE 3000

CMD ["bash", "-c", "rm -f tmp/pids/server.pid && bundle exec rails server -e production -b 0.0.0.0 -p 3000"]
