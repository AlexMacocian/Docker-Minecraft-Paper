FROM ubuntu:latest AS builder

# Install Paper dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    jq \
    bash \
    gnupg \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /minecraft

# Fetch the latest PaperMC version and build dynamically
RUN PAPER_VERSION=$(curl -s https://papermc.io/api/v2/projects/paper | jq -r '.versions[-1]') \
    && PAPER_BUILD=$(curl -s https://papermc.io/api/v2/projects/paper/versions/$PAPER_VERSION | jq -r '.builds[-1]') \
    && wget -O paper.jar https://papermc.io/api/v2/projects/paper/versions/$PAPER_VERSION/builds/$PAPER_BUILD/downloads/paper-$PAPER_VERSION-$PAPER_BUILD.jar

# Accept EULA
RUN echo "eula=true" > eula.txt

FROM alpine:latest AS runner

COPY --from=builder /minecraft /minecraft

RUN apk add --no-cache openjdk21-jre eudev

RUN addgroup -S mcgroup && adduser -S mcuser -G mcgroup -s /bin/sh \ 
    && chown -R mcuser:mcgroup /minecraft \
    && chmod g+s /minecraft

WORKDIR /minecraft

EXPOSE 25565
EXPOSE 8123

CMD /bin/sh -c ' \
    echo Fixing ownership of minecraft directory... && \
    chown -R mcuser:mcgroup /minecraft && \
    echo Starting minecraft server as mcuser && \
    su - mcuser -c "cd /minecraft/ && java -Xmx2G -Xms512M -jar /minecraft/paper.jar nogui"'