FROM alpine:latest

USER root

# Samba
RUN apk add samba-server

# Directories
RUN mkdir /share/

# Expose
EXPOSE 445/tcp

# Executables
WORKDIR /app
COPY src/init.sh /app/init
RUN chmod +x /app/init

# Done
ENTRYPOINT ["/app/init"]
