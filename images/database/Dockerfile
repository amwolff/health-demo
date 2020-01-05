FROM postgres:10.6-alpine

LABEL maintainer="artur.wolff@student.wat.edu.pl"

ENV POSTGRES_USER=admin
ENV POSTGRES_PASSWORD=admin
ENV POSTGRES_DB=health36rc3

COPY 0-create.sql 1-gnuhealth-36rc3-demo.sql /docker-entrypoint-initdb.d/
