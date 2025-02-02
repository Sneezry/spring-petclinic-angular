ARG DOCKER_HUB="docker.io"
ARG NGINX_VERSION="1.20.0"
ARG NODE_VERSION="18.18.2"

FROM $DOCKER_HUB/library/node:$NODE_VERSION as build

COPY . /workspace/

ARG NPM_REGISTRY="https://registry.npmjs.org"

RUN echo "registry = \"$NPM_REGISTRY\"" > /workspace/.npmrc                              && \
    cd /workspace/                                                                       && \
    npm install --force                                                                  && \
    npm run build

FROM $DOCKER_HUB/library/nginx:$NGINX_VERSION AS runtime

COPY --from=build /workspace/dist/ /usr/share/nginx/html/
COPY start.sh /start.sh
RUN chmod +x /start.sh

RUN chown -R nginx:nginx /usr/share/nginx/html/                                 && \
    chmod a+rwx /var/cache/nginx /var/run /var/log/nginx                        && \
    sed -i.bak 's/listen\(.*\)80;/listen 8080;/' /etc/nginx/conf.d/default.conf && \
    sed -i.bak 's/^user/#user/' /etc/nginx/nginx.conf

EXPOSE 8080

USER nginx

CMD [ "/start.sh", "/usr/share/nginx/html/main.js" ]

HEALTHCHECK CMD [ "service", "nginx", "status" ]
