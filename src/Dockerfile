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
COPY src/health.sh health
RUN chmod +x samba
RUN chmod +x health

# Workdir
WORKDIR /srv

# Expose
EXPOSE 445/tcp

# Done
HEALTHCHECK --start-period=60s --start-interval=10s --interval=30s --retries=3 --timeout=10s \
    CMD /app/health
ENTRYPOINT [ "/app/samba" ]
