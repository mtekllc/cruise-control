FROM eclipse-temurin:11-jdk
WORKDIR /opt/cruise-control
COPY .git /opt/cruise-control/.git
COPY . /opt/cruise-control

# Force Cruise Control Reporter to compile as Java 11
RUN sed -i '/java {/a \
tasks.withType(JavaCompile).configureEach { \
    sourceCompatibility = "11"; \
    targetCompatibility = "11"; \
}' cruise-control-metrics-reporter/build.gradle

RUN ./gradlew clean jar copyDependantLibs -x test
COPY config/cruisecontrol.properties /opt/cruise-control/config/cruisecontrol.properties
EXPOSE 9090
CMD ["bash", "-c", "./kafka-cruise-control-start.sh config/cruisecontrol.properties"]
