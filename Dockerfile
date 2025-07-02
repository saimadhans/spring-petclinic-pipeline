# Stage 1: Build the app using Maven
FROM eclipse-temurin:17-jdk-alpine as build

WORKDIR /app

# Copy Maven wrapper and config
COPY .mvn/ .mvn
COPY mvnw pom.xml ./

# Preload dependencies
RUN ./mvnw dependency:go-offline

# Copy source code and package
COPY src ./src
RUN ./mvnw package -DskipTests

# Stage 2: Run the app in a lightweight JDK
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app
COPY --from=build /app/target/spring-petclinic-*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
