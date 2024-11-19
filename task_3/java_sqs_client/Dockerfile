FROM maven:3.8.4-openjdk-11-slim as builder
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn package

FROM openjdk:11-jre-slim
WORKDIR /app
COPY --from=builder /app/target/imagegenerator-0.0.1-SNAPSHOT.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
