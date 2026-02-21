pipeline {
    agent any

    tools {
        maven 'Maven'
        jdk 'JDK'
    }

    stages {
        stage('Checkout') {
            steps {
                echo '========== Checking out code =========='
                checkout scm
                echo '========== Checkout completed =========='
            }
        }

        stage('Build & Run Tests') {
            steps {
                echo '========== Running tests =========='
                sh 'mvn clean test'
                echo '========== Tests completed =========='
            }
        }

        stage('Build Application') {
            steps {
                echo '========== Building application (skipping tests) =========='
                sh 'mvn package -DskipTests'
                echo '========== Build completed =========='
            }
        }
        stage('Build Docker Image') {
            steps {
                echo '========== Building Docker image =========='
                sh 'docker build -t student-management:latest .'
                echo '========== Docker image built =========='
            }
        }

        stage('Archive Artifacts') {
            steps {
                echo '========== Archiving build artifacts =========='
                archiveArtifacts artifacts: 'target/student-management-0.0.1-SNAPSHOT.jar',
                                   allowEmptyArchive: false
                echo '========== Artifacts archived =========='
            }
        }
    }
    stage('Push to Docker Hubb') {
        steps {
            withCredentials([usernamePassword(
                credentialsId: 'dockerhub-creds',
                usernameVariable: 'DOCKER_USER',
                passwordVariable: 'DOCKER_PASS'
            )]) {

                sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'

                sh 'docker tag student-management:latest $DOCKER_USER/student-management:latest'

                sh 'docker push $DOCKER_USER/student-management:latest'
            }
        }
    }

    post {
        always {
            echo '========== Pipeline execution completed =========='
            junit testResults: '**/target/surefire-reports/*.xml',
                  skipPublishingChecks: true,
                  allowEmptyResults: true
        }

        success {
            echo '✓ Pipeline completed successfully'
        }

        failure {
            echo '✗ Pipeline failed'
        }
    }
}