# Set defaults

ARG COMPOSER_IMAGE="composer:1.6.4"
ARG BASE_IMAGE="php:7.2-alpine"
ARG PACKAGE_NAME="phpstan/phpstan"
ARG PACKAGE_VERSION="0.9.2"
ARG TOOL_NAME="phpstan"

# Download with Composer - https://getcomposer.org/

FROM ${COMPOSER_IMAGE} as composer
ARG PACKAGE_NAME
ARG PACKAGE_VERSION
RUN COMPOSER_HOME="/composer" \
    composer global require --prefer-dist --no-progress --dev ${PACKAGE_NAME}:${PACKAGE_VERSION}

# Build image

FROM ${BASE_IMAGE}
ARG TOOL_NAME
ARG INTERNAL_TAG
ARG BUILD_DATE
ARG VCS_REF
ARG IMAGE_NAME

# Install Tini - https://github.com/krallin/tini

RUN apk add --no-cache tini

# Install PHPStan - https://github.com/phpstan/phpstan

COPY --from=composer "/composer/vendor" "/vendor/"
ENV PATH /vendor/bin:${PATH}

# Add entrypoint script

COPY ./docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Add image labels

LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.vendor="phpqa" \
      org.label-schema.name="${TOOL_NAME}" \
      org.label-schema.version="${INTERNAL_TAG}" \
      org.label-schema.build-date="${BUILD_DATE}" \
      org.label-schema.url="https://github.com/phpqa/${TOOL_NAME}" \
      org.label-schema.usage="https://github.com/phpqa/${TOOL_NAME}/README.md" \
      org.label-schema.vcs-url="https://github.com/phpqa/${TOOL_NAME}.git" \
      org.label-schema.vcs-ref="${VCS_REF}" \
      org.label-schema.docker.cmd="docker run --rm --volume \${PWD}:/app --workdir /app ${IMAGE_NAME}"

# Package container

WORKDIR "/app"
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["phpstan"]
