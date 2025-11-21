FROM alpine:latest

USER root

# Environment
ENV ENV="/etc/profile"
RUN echo "alias ll='ls -la'" > /etc/profile.d/00-aliases.sh

# Samba
RUN apk add samba-server

# Workdir
WORKDIR /srv

# Expose
EXPOSE 445/tcp

# Done
COPY src/health.sh /health.sh
RUN chmod +x /health.sh
HEALTHCHECK --start-period=60s --start-interval=10s --interval=30s --retries=3 --timeout=10s \
    CMD /health.sh
COPY src/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
