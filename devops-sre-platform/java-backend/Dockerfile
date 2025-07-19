# -------- Stage 1: Build the Spring Boot app --------
FROM eclipse-temurin:17-jdk-alpine AS build
WORKDIR /app

# Copy project files and download dependencies
COPY mvnw pom.xml ./
COPY .mvn .mvn
RUN ./mvnw dependency:go-offline

# Copy the source and build the project
COPY src src
RUN ./mvnw package -DskipTests

# -------- Stage 2: Run the application --------
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Copy the fat JAR from the builder stage
COPY --from=build /app/target/*.jar app.jar

# Expose the default port
EXPOSE 8080

# Run the Spring Boot app
ENTRYPOINT ["java", "-jar", "app.jar"]