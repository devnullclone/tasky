# Building the binary of the App
FROM golang:1.19 AS build

WORKDIR /go/src/tasky
COPY . .
RUN go mod download
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /go/src/tasky/tasky

# Create a new text file
RUN echo "All who wander are not lost." > /go/src/tasky/wizexercise.txt

FROM alpine:3.17.0 as release

WORKDIR /app
COPY --from=build  /go/src/tasky/tasky .
COPY --from=build  /go/src/tasky/assets ./assets
# Copy the text file from the build stage
COPY --from=build  /go/src/tasky/wizexercise.txt .
# Copy the .env file from the build stage
COPY --from=build  /go/src/tasky/.env .
EXPOSE 8080 27017
ENTRYPOINT ["/app/tasky"]