FROM maven:3.8.4-openjdk-17-slim as builder
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn package

FROM amazoncorretto:17-alpine
WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
