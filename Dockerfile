FROM ubuntu:latest AS builder

# Install Spigot dependencies
# This installs normal dependencies, sets up zulu apt repository and installs zulu21-jdk
RUN apt-get update && apt-get install -y \
    curl \
    git \
    wget \
    bash \
    gnupg \
    ca-certificates \
    && curl -s https://repos.azul.com/azul-repo.key | gpg --dearmor -o /usr/share/keyrings/azul.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/azul.gpg] https://repos.azul.com/zulu/deb stable main" | tee /etc/apt/sources.list.d/zulu.list \
    && apt-get update && apt-get install -y zulu21-jdk

WORKDIR /minecraft

# Setup spigot.jar
# This downloads BuildTools.jar and uses that to build a new spigot.jar
RUN mkdir buildtools \
    && cd buildtools \
    && wget https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar \
    && java -jar BuildTools.jar --rev latest \
    && mv spigot-*.jar /minecraft/spigot.jar \
    && rm -rf /minecraft/buildtools

# Accept EULA
RUN echo "eula=true" > /minecraft/eula.txt

FROM alpine:latest AS runner

COPY --from=builder /minecraft /minecraft

RUN apk add --no-cache openjdk21-jre eudev

WORKDIR /minecraft

# Move spigot to server directory
EXPOSE 25565

CMD /bin/sh -c "java -Xmx2G -Xms512M -jar /minecraft/spigot.jar nogui > /minecraft/logs/output.log 2> /minecraft/logs/error.log"