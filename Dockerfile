ARG BUILD_FROM=hassioaddons/base:7.2.0
FROM ${BUILD_FROM}

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Setup base
RUN apk add --no-cache \
    gcc \
    wget \
    libc-dev \
    libstdc++ \
    build-base \
    lapack-dev \
    libffi-dev \
    libpng-dev \
    libgfortran \
    python3-dev \
    freetype-dev \
    openblas-dev

# Set alias
RUN ln -s $(which pip3) /usr/bin/pip
RUN ln -s $(which python3) /usr/bin/python
RUN ln -s $(which xlocale) /usr/bin/locale

# Install Python packages
RUN pip3 install -U pip setuptools wheel --no-cache-dir
RUN pip3 install -U numpy --no-cache-dir
RUN pip3 install -U cython --no-cache-dir

# Install scipy from source (v1.4.1 is broken)
RUN wget -L -O /tmp/scipy.tar.gz https://github.com/scipy/scipy/archive/master.tar.gz
RUN tar -xf /tmp/scipy.tar.gz -C /tmp

WORKDIR /tmp/scipy-master

RUN chmod a+x ./setup.py
RUN python3 ./setup.py install

# Install Rasa NLU
RUN pip3 install -U rasa-nlu --no-cache-dir

# Set entrypoint
CMD ["python", "-m", "rasa_nlu.server"]

# Build arguments
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_REF
ARG BUILD_VERSION

# Labels
LABEL \
    maintainer="Rok Mohar <rok.mohar@gmail.com" \
    io.hass.name="Rasa NLU" \
    io.hass.description="Rasa Open Source NLU for Home Assistant" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    org.opencontainers.image.title="Rasa NLU" \
    org.opencontainers.image.description="Rasa Open Source NLU for Home Assistant" \
    org.opencontainers.image.vendor="Rok Mohar" \
    org.opencontainers.image.authors="Rok Mohar <rok.mohar@gmail.com" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.url="https://github.com/rokmohar/hassio-rasa-nlu" \
    org.opencontainers.image.source="https://github.com/rokmohar/hassio-rasa-nlu" \
    org.opencontainers.image.documentation="https://github.com/rokmohar/hassio-rasa-nlu/blob/master/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}
