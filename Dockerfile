FROM amacneil/dbmate:latest
COPY ./db/migrations /db/migrations
ENTRYPOINT ["dbmate"]
