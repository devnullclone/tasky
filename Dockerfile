# Building the binary of the App
FROM golang:1.19 AS build

WORKDIR /go/src/tasky
COPY . .
RUN go mod download
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /go/src/tasky/tasky

# Set environment variables for MongoDB connection
ENV MONGO_USERNAME=admin \
    MONGO_PASSWORD=password \
    MONGO_HOST=10.0.1.193 \
    MONGO_PORT=27017 \
    MONGO_DB=codeonedigest-springboot-mongodb-emo

# Create .env file with MongoDB connection string
RUN echo "DB_URI=mongodb://${MONGO_USERNAME}:${MONGO_PASSWORD}@${MONGO_HOST}:${MONGO_PORT}/${MONGO_DB}?\
retryWrites=true&\
w=majority&\
authSource=admin&\
ssl=false" >> .env

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