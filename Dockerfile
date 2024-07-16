# build final image, just copying stuff inside
FROM docker.io/amazoncorretto:21.0.2-alpine3.19 AS publish

# Build ARGS
ARG UID=1000
ARG GID=1000
ARG OSM_FILE=./ors-api/src/test/files/heidelberg.osm.gz
ARG ORS_HOME=/home/ors

EXPOSE 8082

# Set the default language
ENV LANG='en_US' LANGUAGE='en_US' LC_ALL='en_US'

# Setup the target system with the right user and folders.
RUN apk update && apk add --no-cache bash yq jq && \
    addgroup ors -g ${GID} && \
    mkdir -p ${ORS_HOME}/logs ${ORS_HOME}/files ${ORS_HOME}/graphs ${ORS_HOME}/elevation_cache  && \
    adduser -D -h ${ORS_HOME} -u ${UID} --system -G ors ors  && \
    chown ors:ors ${ORS_HOME} \
    # Give all permissions to the user
    && chmod -R 777 ${ORS_HOME}

# Copy over the needed bits and pieces from the other stages.
COPY --chown=ors:ors ./ors-api/target/ors.jar /ors.jar
COPY --chown=ors:ors ./ors-config.yml /example-ors-config.yml
COPY --chown=ors:ors ./ors-config.env /example-ors-config.env
COPY --chown=ors:ors ./$OSM_FILE /heidelberg.osm.gz
COPY --chown=ors:ors ./docker-entrypoint.sh /entrypoint.sh


ENV BUILD_GRAPHS="False"
ENV REBUILD_GRAPHS="False"
# Set the ARG to an ENV. Else it will be lost.
ENV ORS_HOME=${ORS_HOME}

WORKDIR ${ORS_HOME}
# Start the container
ENTRYPOINT ["/bin/bash","/entrypoint.sh"]