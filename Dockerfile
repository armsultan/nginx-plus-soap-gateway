FROM alpine:3.11

LABEL maintainer="armand@f5.com"

# Define NGINX versions for NGINX Plus and NGINX Plus modules
# Uncomment this block and the versioned nginxPackages in the main RUN
# instruction to install a specific release
ENV NGINX_VERSION 22      
# https://nginx.org/en/docs/njs/changes.html
ENV NJS_VERSION   0.4.3   
# https://plus-pkgs.nginx.com
ENV PKG_RELEASE   r1

## Install Nginx Plus
# Download certificate and key from the customer portal https://cs.nginx.com
# and copy to the build context and set correct permissions
COPY etc/ssl/nginx/nginx-repo.crt /etc/apk/cert.pem
COPY etc/ssl/nginx/nginx-repo.key /etc/apk/cert.key
RUN set -x \
    chmod 644 /etc/apk/cert* \
    # Create nginx user/group first, to be consistent throughout Docker variants
    && addgroup -g 101 -S nginx \
    && adduser -S -D -H -u 101 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx \
    # Check signing key
    && KEY_SHA512="e7fa8303923d9b95db37a77ad46c68fd4755ff935d0a534d26eba83de193c76166c68bfe7f65471bf8881004ef4aa6df3e34689c305662750c0172fca5d8552a *stdin" \
    && apk add --no-cache --virtual .cert-deps \
        openssl \
    && wget -O /tmp/nginx_signing.rsa.pub https://nginx.org/keys/nginx_signing.rsa.pub \
    && if [ "$(openssl rsa -pubin -in /tmp/nginx_signing.rsa.pub -text -noout | openssl sha512 -r)" = "$KEY_SHA512" ]; then \
        echo "key verification succeeded!"; \
        mv /tmp/nginx_signing.rsa.pub /etc/apk/keys/; \
    else \
        echo "key verification failed!"; \
        exit 1; \
    fi \
    && apk del .cert-deps \
    # Bring in gettext so we can get `envsubst`, then throw
    # the rest away. To do this, we need to install `gettext`
    # then move `envsubst` out of the way so `gettext` can
    # be deleted completely, then move `envsubst` back.
        && apk add --no-cache --virtual .gettext gettext \
        && mv /usr/bin/envsubst /tmp/ \
        \
        && runDeps="$( \
            scanelf --needed --nobanner /tmp/envsubst \
                | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
                | sort -u \
                | xargs -r apk info --installed \
                | sort -u \
        )" \
        && apk add --no-cache $runDeps \
        && apk del .gettext \
        && mv /tmp/envsubst /usr/local/bin/ \
        # Bring in tzdata so users could set the timezones through the environment
        # variables
        && apk add --no-cache tzdata \
        ## Optional: Install Tools
        # Bring in curl and ca-certificates to make registering on DNS SD easier
        && apk add --no-cache curl ca-certificates \
    # Prepare repo config and install NGINX Plus https://docs.nginx.com/nginx/admin-guide/installing-nginx/installing-nginx-plus/
    && wget -O /etc/apk/keys/nginx_signing.rsa.pub https://nginx.org/keys/nginx_signing.rsa.pub \
    && printf "https://plus-pkgs.nginx.com/alpine/v`egrep -o '^[0-9]+\.[0-9]+' /etc/alpine-release`/main\n" | tee -a /etc/apk/repositories \
    && apk update \
    #
    ## Install the latest release of NGINX Plus and/or NGINX Plus modules
    ## Optionally use versioned packages over defaults to specify a release
    # List available versions: 
    && apk search -v --description 'nginx-plus' \ 
    ## Uncomment one:
    #&& apk add nginx-plus \
    && apk add nginx-plus=${NGINX_VERSION}-${PKG_RELEASE} \
    #
    ## Optional: Install NGINX Plus Dynamic Modules (3rd-party) from repo
    ## See https://www.nginx.com/products/nginx/modules
    ## Some modules include debug binaries, install module ending with "-dbg"
    ## Uncomment one:
    ## njs dynamic modules
    #nginx-plus-module-njs \
    && apk add nginx-plus-module-njs=${NGINX_VERSION}.${NJS_VERSION}-${PKG_RELEASE} \
    # Remove default nginx config
    && rm /etc/nginx/conf.d/default.conf \
    # Optional: Create cache folder and set permissions for proxy caching
    && mkdir -p /var/cache/nginx \
    && chown -R nginx /var/cache/nginx \
    # Optional: Create State file folder and set permissions
    && mkdir -p /var/lib/nginx/state \
    && chown -R nginx /var/lib/nginx/state \
    # Set permissions
    && chown -R nginx:nginx /etc/nginx \
    # Forward request and error logs to Docker log collector
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log \
    # Clear apk cache and clean up!
    && rm -rf /var/cache/apk/* \
    && rm -f /etc/apk/keys/nginx_signing.rsa.pub \
    # **Remove the Nginx Plus cert/keys from the image**
    && rm /etc/apk/cert.pem /etc/apk/cert.key

# Optional: COPY over any of your SSL certs for HTTPS servers
# e.g.
#COPY etc/ssl/www.example.com.crt /etc/ssl/www.example.com.crt
#COPY etc/ssl/www.example.com.key /etc/ssl/www.example.com.key

# COPY /etc/nginx (Nginx configuration) directory
COPY etc/nginx /etc/nginx

# EXPOSE ports, HTTP 80, HTTPS 443 and, Nginx status page 8080
EXPOSE 80 443 8080
STOPSIGNAL SIGTERM
CMD ["nginx", "-g", "daemon off;"]