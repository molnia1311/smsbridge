FROM rust:alpine AS build
RUN apk add --no-cache musl-dev gcc cmake
WORKDIR /src
COPY . .
RUN cargo build --release

FROM scratch
COPY --from=build /src/target/release/smsbridge /smsbridge
EXPOSE 9095
ENTRYPOINT ["/smsbridge"]
