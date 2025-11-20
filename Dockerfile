FROM eclipse-temurin:21-jdk AS builder

WORKDIR /opt/cruise-control

# Copy core Cruise Control
COPY . /opt/cruise-control

# Build Cruise Control server
RUN ./gradlew clean jar copyDependantLibs -x test

# Build UI
RUN apt-get update && apt-get install -y curl gnupg git && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    git clone https://github.com/linkedin/cruise-control-ui.git ui && \
    cd ui && \
    npm install && \
    npm run build

FROM eclipse-temurin:21-jdk

WORKDIR /opt/cruise-control

# Copy Cruise Control build artifacts
COPY --from=builder /opt/cruise-control /opt/cruise-control

# Move UI bundle where Cruise Control expects it
RUN mkdir -p /opt/cruise-control/cruise-control-ui/dist && \
    cp -r /opt/cruise-control/ui/dist/* /opt/cruise-control/cruise-control-ui/dist/

# Your properties file
COPY config/cruisecontrol.properties /opt/cruise-control/config/cruisecontrol.properties

EXPOSE 9090

CMD ["bash", "-c", "./kafka-cruise-control-start.sh config/cruisecontrol.properties"]
