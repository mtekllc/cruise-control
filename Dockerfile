FROM eclipse-temurin:17-jdk
WORKDIR /opt/cruise-control
COPY .git /opt/cruise-control/.git
COPY . /opt/cruise-control
RUN ./gradlew clean jar copyDependantLibs -x test
COPY config/cruisecontrol.properties /opt/cruise-control/config/cruisecontrol.properties
EXPOSE 9090
CMD ["bash", "-c", "./kafka-cruise-control-start.sh config/cruisecontrol.properties"]
