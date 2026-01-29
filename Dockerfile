# Stage 1: Build stage
FROM maven:3.9-eclipse-temurin-17 AS builder

WORKDIR /app

# Copy pom.xml and source code
COPY pom.xml .
COPY src ./src

# Build the application
RUN mvn clean package -DskipTests

# Stage 2: Runtime stage
FROM eclipse-temurin:17-jre-slim

WORKDIR /app

# Copy the JAR from the builder stage
COPY --from=builder /app/target/student-management-0.0.1-SNAPSHOT.jar app.jar

# Expose the port specified in application.properties
EXPOSE 8089

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD java -cp app.jar org.springframework.boot.loader.JarLauncher curl http://localhost:8089/student || exit 1

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
