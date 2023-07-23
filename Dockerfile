# Multi stage Docker build

# The first stage uses golang:1.19-alpine as build
# The AS keywords names the current build as "build", to be referenced later in the second stage

FROM golang:1.19-alpine AS build

WORKDIR /home

COPY ./pkg .

RUN go mod download

# ARG COMMIT_SHA
# ENV COMMIT_SHA=$COMMIT_SHA
RUN  go build -o bookstore -ldflags "-X main.commitSHA=$(COMMIT_SHA)"

# RUN echo ${COMMIT_SHA}
EXPOSE 8080

# The Second stage uses its base as alpine:latest
# All the steps from the first build  are discarded, and only necessary  artifacts are copied in this stage
# When required

FROM alpine:latest 

WORKDIR /root
# ARG COMMIT_SHA
# ENV COMMIT_SHA=$COMMIT_SHA

# COPY copies the artifacts from the ealier "build" stage to relevant directories of this build process

COPY --from=build /home/bookstore /root
COPY --from=build /home/main.go /root
COPY --from=build /home/image /root/image
COPY --from=build /home/templates/. /root/templates

ENTRYPOINT ["./bookstore"]

