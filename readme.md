# NiFi Docker Compose Setup with TLS

# Installation

## First step
Run generate_key.sh to create the necessary certificates and keystores.

## Second step

Run the following command to start the NiFi service:

```bash
docker-compose up -d
```

## Accessing NiFi

Open your web browser and navigate to `https://localhost:8443`.

in docker logs, you will find the initial admin identity:

```
nifi  | Generated Username [828070a3-15d6-469b-b959-83ec6aa7f8c9]
nifi  | Generated Password [fWlWjWPNUjd1JCAmfv1VENB6K4F9pDl0]
```

# References

https://github.com/apache/nifi