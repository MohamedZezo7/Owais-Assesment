pipeline {
    agent any
    tools {
        jdk 'jdk'
        nodejs 'nodejs'
    }
    environment {
        Dockerhub_Cred = credentials('Docker-cred')
        REPOSITORY_URI = "mohamedabdelaziz10"
        IMAGE_NAME     = "owais-backend"
        DOCKER_TAG     = "${BUILD_NUMBER}" 
        DOCKER_IMAGE   = "${REPOSITORY_URI}/${IMAGE_NAME}:${DOCKER_TAG}"
    }

    stages {
        stage('Clean WorkSpace') {
            steps {
                cleanWs()
            }
        }
        
        stage('Checkout Git') {
            steps {
                git branch: 'main', url: 'https://github.com/MohamedZezo7/Owais-Assesment.git'
            }
        }
        
        stage('Test') {
            steps {
                dir('nodejs-api-template/'){
                sh 'npm install'
                sh 'npm test'
                }
            }
        }
        
        stage('OWASP Dependency-Check Scan') {
            steps {
                dir('nodejs-api-template/') {
                    dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit', odcInstallation: 'DP-Check'
                    dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
                }
            }
        }
        
        stage('Trivy File Scan') {
            steps {
                dir('nodejs-api-template/') {
                    sh 'trivy fs . > ../trivyfs-backend-job-${BUILD_NUMBER}-${BUILD_ID}.txt'
                }
            }
        }
        
        stage('Docker Image Build') {
            steps {
                script {
                    dir('nodejs-api-template/') {
                        sh 'docker system prune -f'
                        sh 'docker container prune -f'
                        sh 'docker build -t ${IMAGE_NAME} .'
                    }
                }
            }
        }
        
        stage('Trivy Scan Image') {
            steps {
                script {
                    sh "trivy image ${IMAGE_NAME} > trivyimage-backend-job-${BUILD_NUMBER}-${BUILD_ID}.txt"
                }
            }
        }
        
        stage('Push Image to Docker Hub') {
            steps {
                withDockerRegistry([credentialsId: 'Docker-cred', url: 'https://index.docker.io/v1/']) {
                    script {
                        sh 'docker tag ${IMAGE_NAME} ${DOCKER_IMAGE}'
                        sh 'docker push ${DOCKER_IMAGE}'
                    }
                }
            }
        }
        
        stage('Update Deployment file') {
            environment {
                GIT_REPO_NAME = "Owais-Assesment"
                GIT_USER_NAME = "MohamedZezo7"
            }
            steps {
                dir('k8s/') {
                    withCredentials([string(credentialsId: 'github', variable: 'GITHUB_TOKEN')]) {
                        sh '''
                            git config user.email "mohamedabdelazizk10@gmail.com"
                            git config user.name "Mohamed Abdelaziz"
                            imageTag=$(grep -oP '(?<=backend:)[^ ]+' Deploy-app.yml)
                            sed -i "s/${IMAGE_NAME}:${imageTag}/${IMAGE_NAME}:*/g" Deploy-app.yml
                            git add Deploy-app.yml
                            git commit -m "Update deployment Image to version ${BUILD_NUMBER}"
                            git push https://${GITHUB_TOKEN}@github.com/${GIT_USER_NAME}/${GIT_REPO_NAME} HEAD:main
                        '''
                    }
                }
            }
        }
        
        stage('Deploy The New Version') {
            steps {
                script {
                    sh "kubectl apply -f k8s/Deploy-app.yml"
                }
            }
        }

        // Add OWASP ZAP Scan Stage after Deployment
        
    }

    post {
        always {
            script {
                emailext attachLog: true,
                    subject: "'${currentBuild.result}'",
                    body: "Project: ${env.JOB_NAME}<br/>" +
                        "Build Number: ${env.BUILD_NUMBER}<br/>" +
                        "URL: ${env.BUILD_URL}<br/>",
                    to: 'mohamedabdelazizk10@gmail.com',  
                    attachmentsPattern: 'trivyfs-backend-job-*.txt, trivyimage-backend-job-*.txt, zap-report-${BUILD_NUMBER}.html'
            }
        }
    }
}
