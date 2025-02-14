FROM alpine:latest

USER root

# Samba
RUN apk add samba-server

# Expose
EXPOSE 445/tcp

# Environment
ENV ENV=/etc/profile
RUN echo "alias ll='ls -la'" > /etc/profile.d/alias.sh

# Executables
WORKDIR /app
COPY src/init.sh init
RUN chmod +x init

# Workdir
WORKDIR /srv

# Done
ENTRYPOINT ["/app/init"]
