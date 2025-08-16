FROM crystallang/crystal:latest-alpine

WORKDIR /rb-api_gateway

COPY shard.yml shard.lock ./
RUN shards install --verbose

COPY . .

EXPOSE 3000

CMD ["crystal", "run", "src/rb-api_gateway.cr"]