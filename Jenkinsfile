pipeline {
    agent any

    environment {
        CODACY_PROJECT_TOKEN = credentials('codacy-project-token')
    }

    parameters {
        string(name: 'BRANCH', defaultValue: 'main', description: 'Git branch to build')
    }

    tools {
        nodejs 'NodeJS'
    }

    stages {
        stage('Checkout SCM') {
            steps {
                checkout([$class: 'GitSCM',
                    branches: [[name: "*/${params.BRANCH}"]],
                    doGenerateSubmoduleConfigurations: false,
                    extensions: [],
                    userRemoteConfigs: [[url: 'https://github.com/ShanmukYadav/fullstack-master.git']]
                ])
            }
        }

        stage('Install Frontend Dependencies') {
            steps {
                dir('frontend') {
                    sh 'npm install --no-audit --no-fund'
                }
            }
        }

        stage('Install Backend Dependencies') {
            steps {
                dir('backend') {
                    sh 'npm install --no-audit --no-fund'
                }
            }
        }

        stage('Run Frontend Tests') {
            steps {
                dir('frontend') {
                    sh 'npx jest --passWithNoTests --watchAll=false --coverage'
                }
            }
        }

        stage('Run Backend Tests') {
            steps {
                dir('backend') {
                    sh 'chmod -R +x node_modules/.bin'
                    sh 'npx cross-env NODE_ENV=test jest --detectOpenHandles --forceExit --coverage'
                }
            }
        }

        stage('Upload Coverage to Codacy') {
            steps {
                dir('.') {
                    sh '''
                    curl -Ls https://coverage.codacy.com/get.sh -o get.sh
                    chmod +x get.sh

                    ./get.sh report -r frontend/coverage/lcov.info -t $CODACY_PROJECT_TOKEN

                    if [ -f backend/coverage/lcov.info ]; then
                        ./get.sh report -r backend/coverage/lcov.info -t $CODACY_PROJECT_TOKEN
                    fi
                    '''
                }
            }
        }

        stage('Build & Push Docker Images') {
    steps {
        script {
            withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKERHUB_USERNAME', passwordVariable: 'DOCKERHUB_PASSWORD')]) {
                
                // Login to DockerHub
                sh "echo $DOCKERHUB_PASSWORD | docker login -u $DOCKERHUB_USERNAME --password-stdin"

                // Build & push frontend image
                dir('frontend') {
                    def frontendImage = "adhvyth/devops-pipeline:frontend-latest"
                    sh "docker build -t ${frontendImage} ."
                    sh "docker push ${frontendImage}"
                    echo "Frontend image pushed: ${frontendImage}"
                }

                // Build & push backend image
                dir('backend') {
                    def backendImage = "adhvyth/devops-pipeline:backend-latest"
                    sh "docker build -t ${backendImage} ."
                    sh "docker push ${backendImage}"
                    echo "Backend image pushed: ${backendImage}"
                }
            }
        }
    }
}

    }

    post {
        always {
            script {
                echo "Cleaning up workspace..."
                cleanWs()
            }
        }
        success {
            echo "Pipeline completed successfully!"
        }
        failure {
            echo "Pipeline failed. Check logs!"
        }
    }
}
