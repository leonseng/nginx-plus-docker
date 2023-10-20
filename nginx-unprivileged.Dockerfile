ARG NGINX_PLUS_IMAGE
FROM $NGINX_PLUS_IMAGE

# Extracted from https://github.com/nginxinc/docker-nginx-unprivileged/blob/bbcebe8dd03e5cfdfe02279c49da29bc29c5f1bb/stable/debian/Dockerfile#L108-L117
# implement changes required to run NGINX as an unprivileged user
RUN sed -r -i 's/listen([[:blank:]]+)80/listen\18080/' /etc/nginx/conf.d/default.conf \
  && sed -i '/user  nginx;/d' /etc/nginx/nginx.conf \
  && sed -i 's,/var/run/nginx.pid,/tmp/nginx.pid,' /etc/nginx/nginx.conf \
  && sed -i "/^http {/a \    proxy_temp_path /tmp/proxy_temp;\n    client_body_temp_path /tmp/client_temp;\n    fastcgi_temp_path /tmp/fastcgi_temp;\n    uwsgi_temp_path /tmp/uwsgi_temp;\n    scgi_temp_path /tmp/scgi_temp;\n" /etc/nginx/nginx.conf \
  # nginx user must own the cache and etc directory to write cache and tweak the nginx config
  && chown -R $UID:0 /var/cache/nginx \
  && chmod -R g+w /var/cache/nginx \
  && chown -R $UID:0 /etc/nginx \
  && chmod -R g+w /etc/nginx

EXPOSE 8080

STOPSIGNAL SIGQUIT

CMD ["nginx", "-g", "daemon off;"]