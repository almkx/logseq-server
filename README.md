# logseq-server
Logseq server apps for self-hosting

This is similar in spirit to other Logseq self-hosting repos, but much simpler, with minimal build steps, dependencies, and mount requirements.  
It should be easier to understand, modify, and deploy on appliance systems like TrueNAS.

## Build
1. Log Docker in to your registry. The `Makefile` header shows how for GHCR, using a classic Personal Access Token with the `write:packages` scope.
2. Set `REGISTRY` in the `Makefile`. For GHCR, just replace `almkx` with your username.
3. Build and push using the usage guide at the top of the `Makefile`.

GHCR packages are private by default. _**Make them public if you want them openly available.**_

## Setup
Use Docker Compose or your system's UI for custom apps.  
These are the *minimal* requirements, and they assume the default writable (not read-only) image filesystem.  
Ports are set by `ARG PORT` at the top of each `Dockerfile`: 6001 (sync), 6002 (publish), 6003 (web).
Expose, bind, or reverse proxy them as needed.

### sync
- User: `nonroot` (UID `65532`) by default.
    - If changed, **the `data` volume's permissions must match the user**.
    - On TrueNAS, you can use `568`, the built-in `apps` user.
- Volume `data`: mount at `/data`, read/write for UID `65532` (`nonroot`), or match the image's user if changed.

Required environment variables:
```bash
COGNITO_ISSUER=https://cognito-idp.us-east-1.amazonaws.com/us-east-1_dtagLnju8
COGNITO_CLIENT_ID=69cs1lgme7p8kbgld8n5kseii6
COGNITO_JWKS_URL=https://cognito-idp.us-east-1.amazonaws.com/us-east-1_dtagLnju8/.well-known/jwks.json
```

If behind a reverse proxy, also set your public URL:
```bash
DB_SYNC_BASE_URL=https://sync.example.com
```

### publish
- User: `node` (UID `1000`) by default.
    - Keep the default, as any other user can't write to `/app/worker`.
- Volume `data`: mount at `/data`, read/write for UID `1000` (`node`).

Required environment variables:
```bash
COGNITO_ISSUER=https://cognito-idp.us-east-1.amazonaws.com/us-east-1_dtagLnju8
COGNITO_CLIENT_ID=69cs1lgme7p8kbgld8n5kseii6
COGNITO_JWKS_URL=https://cognito-idp.us-east-1.amazonaws.com/us-east-1_dtagLnju8/.well-known/jwks.json
```

### web
No special setup.
