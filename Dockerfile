# ======== 1️⃣ Build Stage ========
FROM maven:3.9.6-eclipse-temurin-17 AS builder
WORKDIR /app

# Copy only pom.xml first to leverage Docker cache
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Now copy source and build
COPY src ./src
RUN mvn clean package -DskipTests

# ======== 2️⃣ Runtime Stage ========
FROM eclipse-temurin:17-jdk AS runtime

# Install native libraries required for OpenCV
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgtk2.0-0 \
    libcanberra-gtk-module \
    libx11-6 \
    ffmpeg \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app
# Copy the built jar from the builder stage
COPY --from=builder /app/target/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
