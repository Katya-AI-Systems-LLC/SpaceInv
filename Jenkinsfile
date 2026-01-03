name: Jenkins Pipeline

pipeline {
    agent any
    
    environment {
        FLUTTER_VERSION = '3.16.0'
        ANDROID_HOME = "${env.HOME}/Android/Sdk"
        GRADLE_OPTS = '-Dorg.gradle.daemon=false'
    }
    
    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 30, unit: 'MINUTES')
        timestamps()
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Setup Flutter') {
            steps {
                script {
                    sh '''
                        git clone https://github.com/flutter/flutter.git -b stable ${env.WORKSPACE}/flutter
                        export PATH="${env.WORKSPACE}/flutter/bin:${env.PATH}"
                        flutter channel stable
                        flutter upgrade
                        flutter doctor
                    '''
                }
            }
        }
        
        stage('Install Dependencies') {
            steps {
                script {
                    sh '''
                        export PATH="${env.WORKSPACE}/flutter/bin:${env.PATH}"
                        flutter pub get
                    '''
                }
            }
        }
        
        stage('Test') {
            parallel {
                stage('Unit Tests') {
                    steps {
                        script {
                            sh '''
                                export PATH="${env.WORKSPACE}/flutter/bin:${env.PATH}"
                                flutter test --coverage
                                genhtml coverage/lcov.info -o coverage/html
                            '''
                        }
                        post {
                            always {
                                publishHTML([
                                    allowMissing: false,
                                    alwaysLinkToLastBuild: true,
                                    keepAll: true,
                                    reportDir: 'coverage/html',
                                    reportFiles: 'index.html',
                                    reportName: 'Coverage Report'
                                ])
                            }
                        }
                    }
                }
                
                stage('Analysis') {
                    steps {
                        script {
                            sh '''
                                export PATH="${env.WORKSPACE}/flutter/bin:${env.PATH}"
                                flutter analyze
                                dart format --set-exit-if-changed .
                            '''
                        }
                    }
                }
            }
        }
        
        stage('Build') {
            parallel {
                stage('Build Web') {
                    steps {
                        script {
                            sh '''
                                export PATH="${env.WORKSPACE}/flutter/bin:${env.PATH}"
                                flutter build web --web-renderer canvaskit --release
                            '''
                        }
                        post {
                            success {
                                archiveArtifacts artifacts: 'build/web/**', fingerprint: true
                            }
                        }
                    }
                }
                
                stage('Build Android') {
                    steps {
                        script {
                            sh '''
                                export PATH="${env.WORKSPACE}/flutter/bin:${env.PATH}"
                                flutter build apk --release
                                flutter build appbundle --release
                            '''
                        }
                        post {
                            success {
                                archiveArtifacts artifacts: 'build/app/outputs/**', fingerprint: true
                            }
                        }
                    }
                }
            }
        }
        
        stage('Deploy') {
            when {
                branch 'main'
            }
            steps {
                script {
                    sh '''
                        echo "Deploying to production environment"
                        # Add your production deployment script here
                    '''
                }
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
        success {
            script {
                currentBuild.result = 'SUCCESS'
                echo 'Pipeline completed successfully!'
            }
        }
        failure {
            script {
                currentBuild.result = 'FAILURE'
                echo 'Pipeline failed!'
            }
        }
    }
}
