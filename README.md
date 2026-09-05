# God's Eye View — Docker addon

This repository is a small, independent container wrapper for the original
[God's Eye View](https://github.com/bilawalsidhu/gods-eye-view) project. It does
not carry or modify the application source. Each image build fetches the
original repository directly and packages it for Docker.

## Run

```bash
docker run --rm -p 4173:4173 \
  -v "$(pwd)/data:/data" \
  ghcr.io/tubalainen/gods-eye-view-docker:latest
```

Open <http://localhost:4173>.

With Docker Compose:

```bash
docker compose up -d
```

> [!IMPORTANT]
> Put the `.env` file in the **same folder as `docker-compose.yaml`**. Do not
> place it inside `./data`.

No API keys are required. To enable optional providers, add the variables
documented in the original project's
[`.env.example`](https://github.com/bilawalsidhu/gods-eye-view/blob/main/.env.example)
to that `.env` file.

```text
gods-eye-view-docker/
├── docker-compose.yaml
├── .env
└── data/
```

The local `./data` directory preserves the application's `.env`, caches, and
logs across container replacements. To update the app:

```bash
docker compose pull
docker compose up -d
```

## Build locally

The default build packages the original repository's current `main` branch:

```bash
docker build -t gods-eye-view .
```

Build a particular upstream branch, tag, or commit with:

```bash
docker build --build-arg GEV_REF=<ref> -t gods-eye-view .
```

## Published image

GitHub Actions checks upstream daily and publishes AMD64 and ARM64 images to
`ghcr.io/tubalainen/gods-eye-view-docker`. Every publication is pinned to the
resolved upstream commit and tagged as both `latest` and
`upstream-<commit-sha>`.

God's Eye View is created by Bilawal Sidhu and distributed under its original
MIT license. This repository only supplies the container packaging.
