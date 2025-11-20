# Multi stage Cruise Control build with UI, slim final image

FROM eclipse-temurin:21-jdk AS builder

WORKDIR /opt/cruise-control

# Copy entire Cruise Control repo
COPY . /opt/cruise-control

# Build Cruise Control server
RUN ./gradlew clean jar copyDependantLibs -x test

# Build Cruise Control UI
RUN apt-get update && \
        apt-get install -y curl gnupg git && \
        curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
        apt-get install -y nodejs && \
        git clone https://github.com/linkedin/cruise-control-ui.git ui && \
        cd ui && npm install && npm run build

# Final runtime image
FROM eclipse-temurin:21-jdk

WORKDIR /opt/cruise-control

# Copy Cruise Control build artifacts
COPY --from=builder /opt/cruise-control/cruise-control/build/libs/ /opt/cruise-control/libs/
COPY --from=builder /opt/cruise-control/cruise-control/build/dependant-libs/ /opt/cruise-control/dependant-libs/
COPY --from=builder /opt/cruise-control/kafka-cruise-control-start.sh /opt/cruise-control/

# Copy configs
COPY config/ /opt/cruise-control/config/

# Add UI bundle
COPY --from=builder /opt/cruise-control/ui/dist/ /opt/cruise-control/cruise-control-ui/dist/

EXPOSE 9090

CMD ["bash", "-c", "./kafka-cruise-control-start.sh config/cruisecontrol.properties"]
