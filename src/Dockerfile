FROM alpine:latest

USER root

# Samba
RUN apk add samba-server

# Expose
EXPOSE 445/tcp

# Executables
WORKDIR /app
COPY src/init.sh init
RUN chmod +x init

# Workdir
WORKDIR /srv

# Done
ENTRYPOINT ["/app/init"]
