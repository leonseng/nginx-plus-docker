FROM debian:bullseye-slim

LABEL maintainer="NGINX Docker Maintainers <docker-maint@nginx.com>"

# Define NGINX versions for NGINX Plus and NGINX Plus modules
# Uncomment this block and the versioned nginxPackages block in the main RUN
# instruction to install a specific release
# ENV NGINX_VERSION   29
# ENV NJS_VERSION     0.7.12
# ENV PKG_RELEASE     1~bullseye

# Download certificate and key from the customer portal (https://account.f5.com)
# and copy to the build context
RUN --mount=type=secret,id=nginx-crt,dst=nginx-repo.crt \
    --mount=type=secret,id=nginx-key,dst=nginx-repo.key \
    set -x \
    # Create nginx user/group first, to be consistent throughout Docker variants
    # && addgroup --system --gid 101 nginx \
    # && adduser --system --disabled-login --ingroup nginx --no-create-home --home /nonexistent --gecos "nginx user" --shell /bin/false --uid 101 nginx \
    && apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -y \
    wget \
    ca-certificates \
    gnupg2 \
    lsb-release \
    apt-transport-https \
    debian-archive-keyring \
    && wget -qO - https://cs.nginx.com/static/keys/nginx_signing.key | gpg --dearmor > /usr/share/keyrings/nginx-archive-keyring.gpg  \
    && wget https://cs.nginx.com/static/keys/app-protect-security-updates.key && apt-key add app-protect-security-updates.key \
    && wget -P /etc/apt/apt.conf.d https://cs.nginx.com/static/files/90pkgs-nginx \
    # Install the latest release of NGINX Plus and/or NGINX Plus modules
    # Uncomment individual modules if necessary
    # Use versioned packages over defaults to specify a release
    && nginxPackages=" \
    nginx-plus \
    nginx-plus-module-njs \
    app-protect \
    app-protect-dos \
    " \
    && printf "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] https://pkgs.nginx.com/plus/debian `lsb_release -cs` nginx-plus\n" > /etc/apt/sources.list.d/nginx-plus.list \
    && printf "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] https://pkgs.nginx.com/app-protect/debian `lsb_release -cs` nginx-plus\n" > /etc/apt/sources.list.d/nginx-app-protect.list \
    && printf "deb https://pkgs.nginx.com/app-protect-security-updates/debian `lsb_release -cs` nginx-plus\n" > /etc/apt/sources.list.d/app-protect-security-updates.list \
    && printf "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] https://pkgs.nginx.com/app-protect-dos/debian `lsb_release -cs` nginx-plus\n" > /etc/apt/sources.list.d/nginx-app-protect-dos.list \
    && mkdir -p /etc/ssl/nginx \
    && cat nginx-repo.crt > /etc/ssl/nginx/nginx-repo.crt \
    && cat nginx-repo.key > /etc/ssl/nginx/nginx-repo.key \
    && apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -y \
    $nginxPackages \
    curl \
    gettext-base \
    && apt-get remove --purge -y lsb-release \
    && apt-get remove --purge --auto-remove -y \
    && rm -rf /var/lib/apt/lists/* \
    /etc/apt/sources.list.d/nginx-plus.list \
    /etc/apt/sources.list.d/nginx-app-protect.list \
    /etc/apt/sources.list.d/app-protect-security-updates.list \
    /etc/apt/sources.list.d/nginx-app-protect-dos.list \
    && rm -rf /etc/apt/apt.conf.d/90nginx /etc/ssl/nginx \
    # Forward request logs to Docker log collector
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80

STOPSIGNAL SIGQUIT

CMD ["nginx", "-g", "daemon off;"]