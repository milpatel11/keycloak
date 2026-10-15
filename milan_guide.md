# local: rebuild dist with the moved CSS, then upload
scp keycloak\quarkus\dist\target\keycloak-26.8.0.tar.gz <SSH_USER>@auth.shreekrupa.net:~/keycloak-upload/quarkus/dist/target/

sudo cp -r ~/keycloak-upload/* /home/api-runner/keycloak/ 

sudo chown -R api-runner:api-runner /home/api-runner/keycloak

sudo -u api-runner -i && cd ~/keycloak && podman compose up -d --build

podman compose build --no-cache keycloak
podman compose up -d --force-recreate