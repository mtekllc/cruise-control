FROM eclipse-temurin:21-jdk
WORKDIR /opt/cruise-control
COPY . /opt/cruise-control

# Build with Java 21
RUN ./gradlew clean jar copyDependantLibs -x test

COPY config/cruisecontrol.properties /opt/cruise-control/config/cruisecontrol.properties

EXPOSE 9090
CMD ["bash", "-c", "./kafka-cruise-control-start.sh config/cruisecontrol.properties"]
