# Spring PetClinic – End-to-End CI/CD with GitHub Actions & JFrog

This repository demonstrates how to automate the build, containerization, and security scanning of the [Spring PetClinic](https://github.com/spring-projects/spring-petclinic) application using GitHub Actions, Docker, and JFrog Artifactory + Xray.

---

## Project Overview

This project uses:

- **Java 17** with Spring Boot for backend application
- **Maven** to manage dependencies and build
- **Docker** to containerize the application
- **JFrog Artifactory** to host both Maven dependencies and Docker images
- **JFrog Xray** to scan Docker images for vulnerabilities
- **GitHub Actions** as the CI/CD tool

---

## 🔧 Prerequisites

- Java 17 (Temurin recommended)
- Docker
- Git
- GitHub account
- JFrog SaaS trial account (https://jfrog.com/start/)

---

## How to Run Locally

### Step 1: Build the Application

```bash
./mvnw clean package
```

### Step 2: Build and Run Docker Container

```bash
docker build -t spring-petclinic:latest .
docker run -p 8080:8080 spring-petclinic:latest
```

Visit the app at: [http://localhost:8080](http://localhost:8080)

---

## How to Set Up CI/CD

### Step 1: Set Up JFrog

1. **Create Repositories**
   - Docker (Local): `docker-local`
   - Maven (Remote): `maven-remote` with URL `https://repo1.maven.org/maven2`

2. **Generate Access Token or use Username/Password**

---

### Step 2: Push Code to GitHub

```bash
git init
git remote add origin https://github.com/<your-username>/spring-petclinic-pipeline.git
git remote set-url origin git@github.com:<your-username>/spring-petclinic-pipeline.git
git push -u origin main
```

---

### Step 3: Configure GitHub Secrets

Go to: **Settings → Secrets → Actions** in your repo

Add these secrets:

| Secret Name      | Value                         |
|------------------|-------------------------------|
| `JFROG_URL`      | https://<account>.jfrog.io    |
| `JFROG_USERNAME` | Your JFrog username           |
| `JFROG_PASSWORD` | Your JFrog password/token     |
| `MAVEN_REPO`     | maven-remote                  |
| `DOCKER_REPO`    | docker-local                  |
| `JFROG_PROJECT`  | (optional)                    |

---

## CI/CD Workflow (GitHub Actions)

Located at: `.github/workflows/ci.yml`

### Steps:

1. Checkout source code
2. Set up Java and Maven
3. Resolve dependencies from Artifactory
4. Build Docker image
5. Push to JFrog Docker repo
6. Trigger Xray scan
7. Poll for scan completion
8. Save scan results to `.github/xray-scan-report.json`
9. Commit scan report back to GitHub if changed

---

## Dockerfile

```dockerfile
FROM eclipse-temurin:17-jdk-alpine as build
WORKDIR /app
COPY .mvn/ .mvn
COPY mvnw pom.xml ./
RUN ./mvnw dependency:go-offline
COPY src ./src
RUN ./mvnw package -DskipTests

FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /app/target/spring-petclinic-*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

---

## Files Overview

| File                              | Purpose                                       |
|-----------------------------------|-----------------------------------------------|
| `.github/workflows/ci.yml`        | GitHub Actions CI/CD pipeline                 |
| `.jfrog/settings.xml`             | Maven config for dependency resolution        |
| `Dockerfile`                      | Container build definition                    |
| `.github/xray-scan-report.json`   | Output of the JFrog Xray scan                 |

---

## Output

- Docker image: `jfrog.io/docker-local/spring-petclinic:latest`
- Security report: `.github/xray-scan-report.json`
- CI logs: GitHub → Actions tab

---

## Notes

- No modification needed to the core Spring PetClinic app
- Licenses like "http://" flagged by Xray can be filtered via policy

---

## Summary of Manual Setup (Local + Cloud)

- Installed Java 17
- Ran `./mvnw clean package`
- Wrote Dockerfile
- Built and ran container on localhost
- Created JFrog trial and repositories
- Set up GitHub repo and pushed code
- Added GitHub Actions workflow
- Added secrets and triggered CI

##   Command to obtain and run the docker image
### Pull the image from JFrog Artifactory
docker pull <your-jfrog-url>/<docker-repo>/spring-petclinic:latest

### Run the container
docker run -p 8080:8080 <your-jfrog-url>/<docker-repo>/spring-petclinic:latest
