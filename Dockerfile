FROM eclipse-temurin:27-jdk

ARG KEYCLOAK_DIST=quarkus/dist/target/keycloak-26.8.0.tar.gz

WORKDIR /opt

COPY ${KEYCLOAK_DIST} /tmp/keycloak.tar.gz

RUN tar -xzf /tmp/keycloak.tar.gz -C /opt && \
    rm -f /tmp/keycloak.tar.gz && \
    mv /opt/keycloak-* /opt/keycloak && \
    mkdir -p /opt/keycloak/data && \
    chmod -R g+rwX /opt/keycloak && \
    useradd -u 1000 -r -g 0 -m -d /opt/keycloak -s /sbin/nologin keycloak

USER 1000
EXPOSE 8080

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
