# Deployment Guide: auth.shreekrupa.net (Keycloak on Java 27)

Deployment instructions for the custom Keycloak fork (`milan/shreekrupa-login`) with Java 27 runtime on host port **8181**, connecting to an external PostgreSQL database. 

- **Transfer/SSH User**: Your regular SSH/admin user (e.g., `milan` or your personal user with sudo access).
- **Execution User**: `api-runner` (dedicated non-privileged service user that runs containers and owns the deployment).

---

## 1. Prerequisites on Target Server

- OS: Linux (Debian/Ubuntu/RHEL)
- SSH user (e.g. `milan`) with sudo access to transfer files and manage service users.
- Dedicated service user: `api-runner` (home directory: `/home/api-runner`).
- Container engine: `docker` + `docker compose` (with `api-runner` in `docker` group) OR rootless `podman` + `podman compose`.
- Keycloak's dedicated PostgreSQL database and login provisioned by the database
  deployment; follow [database/README.md](../database/README.md).
- Public domain and reverse proxy:
  - Domain: `auth.shreekrupa.net`
  - Reverse proxy (Nginx/Caddy) routing traffic for `auth.shreekrupa.net` to `http://127.0.0.1:8181`

---

## 2. Prepare Local Build Artifacts

Before transferring to the server, ensure the Java 27 build archive exists locally:
- Built file: `keycloak/quarkus/dist/target/keycloak-26.8.0.tar.gz`
- Theme registered: `shreekrupa` in `keycloak/themes/src/main/resources/META-INF/keycloak-themes.json`

If rebuilding locally at any point:
```powershell
$env:JAVA_HOME = "C:\Program Files\Java\jdk-27"
Set-Location keycloak
.\mvnw.cmd -pl quarkus/deployment,quarkus/dist -am -DskipTests -DskipDocs clean install
```

---

## 3. Transfer Files to Server (Using SSH User)

Transfer the deployment bundle using your regular SSH user (e.g. `milan`), then stage and transfer ownership to `api-runner`:

### Step 3.1: Upload from local machine
```bash
# Upload to your user's home directory (e.g. milan)
ssh milan@YOUR_SERVER_IP "mkdir -p ~/keycloak-upload/quarkus/dist/target"

# Copy container configuration files
scp keycloak/Dockerfile milan@YOUR_SERVER_IP:~/keycloak-upload/
scp keycloak/compose.yaml milan@YOUR_SERVER_IP:~/keycloak-upload/
scp keycloak/.env.example milan@YOUR_SERVER_IP:~/keycloak-upload/

# Copy the built Java 27 Keycloak distribution archive
scp keycloak/quarkus/dist/target/keycloak-26.8.0.tar.gz milan@YOUR_SERVER_IP:~/keycloak-upload/quarkus/dist/target/
```

### Step 3.2: Move into `api-runner` directory and set permissions
Log in to the server as your SSH user:
```bash
ssh milan@YOUR_SERVER_IP
```

Move the directory to `/home/api-runner/keycloak` and hand ownership over to `api-runner`:
```bash
# Ensure target directory exists
sudo mkdir -p /home/api-runner/keycloak

# Move uploaded files into api-runner workspace
sudo cp -r ~/keycloak-upload/* /home/api-runner/keycloak/
rm -rf ~/keycloak-upload

# Set ownership to api-runner
sudo chown -R api-runner:api-runner /home/api-runner/keycloak
```

---

## 4. Server Configuration (Switch to `api-runner`)

Switch to the `api-runner` service user:
```bash
sudo -u api-runner -i
cd ~/keycloak
```

Create `.env` from the template:
```bash
cp .env.example .env
chmod 600 .env
```

Edit `.env` with your real database credentials:
```bash
nano .env
```

Ensure parameters match your external PostgreSQL:
```dotenv
KC_HOSTNAME=https://auth.shreekrupa.net
KC_DB_URL=jdbc:postgresql://<EXTERNAL_DB_HOST_OR_IP>:5432/keycloak
KC_DB_USERNAME=keycloak
KC_DB_PASSWORD=<SECURE_DB_PASSWORD>
KEYCLOAK_ADMIN=admin
KEYCLOAK_ADMIN_PASSWORD=<SECURE_ADMIN_PASSWORD>
```

*(Note: If PostgreSQL is running on the host itself, use host IP or `host.docker.internal` / `host.containers.internal` as appropriate).*

---

## 5. Build and Launch Container

As `api-runner`:

```bash
# Build the Java 27 container and launch detached
docker compose up -d --build
# OR with podman:
# podman compose up -d --build
``` :

Monitor initial startup and database migrations:
```bash
docker compose logs -f keycloak
# OR:
# podman compose logs -f keycloak
```

Wait until you see:
```text
Running the server in [production] mode.
Keycloak ... started on http://0.0.0.0:8080
```

---

## 6. Local Host Verification

From the server shell, verify that port **8181** responds:
```bash
curl -I http://127.0.0.1:8181/health/ready
```

Expected HTTP response: `HTTP/1.1 200 OK`

---

## 7. Nginx Reverse Proxy Configuration

Configure Nginx on the server for `auth.shreekrupa.net`:

```nginx
server {
    server_name auth.shreekrupa.net;

    location / {
        proxy_pass http://127.0.0.1:8181;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $remote_addr;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Port $server_port;
        proxy_set_header Connection "";
        proxy_read_timeout 120s;
        proxy_buffer_size 128k;
        proxy_buffers 4 256k;
        proxy_busy_buffers_size 256k;
    }

    listen 443 ssl;
    # ssl_certificate ...
    # ssl_certificate_key ...
}
```

Reload Nginx:
```bash
sudo nginx -t && sudo systemctl reload nginx
```

---

## 8. Final Verification & Theme Activation

1. Open `https://auth.shreekrupa.net` in your browser.
2. Log in with the bootstrap credentials configured in `.env` (`KEYCLOAK_ADMIN` / `KEYCLOAK_ADMIN_PASSWORD`).
3. Select your target realm (e.g. `aum`).
4. Navigate to **Realm settings** → **Themes**.
5. Set **Login theme** to **shreekrupa**.
6. Click **Save**.
7. Open a private/incognito window, trigger a login flow for the realm, and verify the custom Shreekrupa styling and branding.
