FROM alpine:latest

USER root

# Environment
ENV ENV="/etc/profile"
RUN echo "alias ll='ls -la'" > /etc/profile.d/00-aliases.sh

# Samba
RUN apk add samba-server

# Executables
WORKDIR /app
COPY src/init.sh samba
RUN chmod +x samba

# Workdir
WORKDIR /srv

# Expose
EXPOSE 445/tcp

# Done
ENTRYPOINT [ "/app/samba" ]
