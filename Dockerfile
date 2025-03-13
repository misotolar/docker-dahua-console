FROM misotolar/alpine:3.21.3

LABEL org.opencontainers.image.url="https://github.com/misotolar/docker-dahua-console"
LABEL org.opencontainers.image.authors="Michal Sotolar <michal@sotolar.com>"

ARG CONSOLE_VERSION=5f8f35b13437d06e6e9b01f63bc151303939eda2
ARG CONSOLE_SHA256=81a53d79c667162c6c1f7601e2327d5307ab2ef11f8f3e89c2b652262cb508a8
ADD https://github.com/mcw0/DahuaConsole/archive/${CONSOLE_VERSION}.tar.gz /tmp/console.tar.gz

COPY resources/patches /tmp/patches

WORKDIR /usr/local/console

RUN set -ex; \
    apk add --no-cache \
        py3-openssl \
        py3-packaging \
        py3-pycryptodome \
        py3-psutil \
        py3-tzlocal \
        py3-requests \
    ; \
    apk add --no-cache --virtual .build-deps \
        patch \
        py3-pip \
    ; \
    echo "$CONSOLE_SHA256 */tmp/console.tar.gz" | sha256sum -c -; \
    tar -xf /tmp/console.tar.gz --strip-components=1; \
    patch -p1 < /tmp/patches/0001-dahua-console-issue43.patch; \
    pip install --break-system-packages -r requirements.txt; \
    \
    apk del --no-network .build-deps; \
    rm -rf \
        /build \
        /usr/local/janus/etc \
        /var/cache/apk/* \
        /var/tmp/* \
        /tmp/*

ENTRYPOINT ["/usr/local/console/Console.py"]
