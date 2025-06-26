# Use a multi-stage build for a smaller final image
# Stage 1: Build the Spring Boot application
FROM eclipse-temurin:17-jdk-jammy AS builder

WORKDIR /app

COPY .mvn/ .mvn
COPY mvnw pom.xml ./
RUN ./mvnw dependency:go-offline

COPY src ./src

RUN ./mvnw clean install -DskipTests

# Stage 2: Create the final image
FROM eclipse-temurin:17-jre-jammy 
WORKDIR /app

# Copy the built JAR from the builder stage
COPY --from=builder /app/target/*.jar app.jar

# Expose the port Spring Boot runs on (5000 for EB, but 8080 is common in K8s)
EXPOSE 8080

# Command to run the application
ENTRYPOINT ["java", "-jar", "app.jar"]