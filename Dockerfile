FROM docker.io/library/eclipse-temurin:27-jdk

ARG KEYCLOAK_DIST=quarkus/dist/target/keycloak-26.8.0.tar.gz

WORKDIR /opt

COPY ${KEYCLOAK_DIST} /tmp/keycloak.tar.gz

RUN tar -xzf /tmp/keycloak.tar.gz -C /opt && \
    rm -f /tmp/keycloak.tar.gz && \
    mv /opt/keycloak-* /opt/keycloak && \
    mkdir -p /opt/keycloak/data && \
    /opt/keycloak/bin/kc.sh build --db=postgres --health-enabled=true && \
    chown -R 1000:0 /opt/keycloak && \
    chmod -R g+rwX /opt/keycloak

ENV HOME=/opt/keycloak
USER 1000:0
EXPOSE 8080

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
