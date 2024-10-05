FROM alpine:latest

ARG VERSION=0.22.21
# OS component from --platform, e.g. linux. This is automatically set by Docker when 
# using buildx.
ARG TARGETOS=linux
# ARCH component from --platform, e.g. amd64. This is automatically set by Docker when 
# using buildx.
ARG TARGETARCH=amd64

# Install ca-certificates to allow the application to make HTTPS requests
RUN apk --update --no-cache add ca-certificates unzip \
  && update-ca-certificates 2>/dev/null || true
# Install wget to allow health checks on the container. Then clean up the apt cache to reduce the image size.
# e.g. `wget -nv -t1 --spider 'http://localhost:8080/health' || exit 1`
RUN apk add --no-cache wget && rm -rf /var/cache/apk/*

# download and unzip PocketBase
ADD https://github.com/pocketbase/pocketbase/releases/download/v${VERSION}/pocketbase_${VERSION}_${TARGETOS}_${TARGETARCH}.zip /tmp/pb.zip
RUN unzip /tmp/pb.zip -d /pb/

# uncomment to copy the local pb_migrations dir into the image
# see: https://pocketbase.io/docs/go-migrations/#migration-file
# COPY ./pb_migrations /pb/pb_migrations

# uncomment to copy the local pb_hooks dir into the image
# COPY ./pb_hooks /pb/pb_hooks

# Set the port that the application will listen on and the user to run the application
ENV PORT=8080
EXPOSE ${PORT}

# Start PocketBase
CMD ["/pb/pocketbase", "serve", "--http=0.0.0.0:${PORT}", "--encryptionEnv=${PB_ENCRYPTION_KEY}"]
