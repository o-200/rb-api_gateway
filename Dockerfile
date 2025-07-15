# Build stage
FROM crystallang/crystal:latest AS builder

WORKDIR /rb-api_gateway

COPY . .

RUN shards install --verbose

RUN crystal build src/api_gateway.cr --verbose --release --no-debug --static -o rb-api_gateway

# Final stage
FROM alpine:latest

RUN apk add --no-cache libgcc libssl3 pcre

WORKDIR /rb-api_gateway

COPY --from=builder /rb-api_gateway/rb-api_gateway .

EXPOSE 3000

CMD ["./rb-api_gateway"]
