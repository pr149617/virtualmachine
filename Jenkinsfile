pipeline {
    agent any

    environment {
        PROJECT_ID = 'canvas-primacy-466005-f9'
        GOOGLE_IMPERSONATE_SERVICE_ACCOUNT = 'terraform-svc@canvas-primacy-466005-f9.iam.gserviceaccount.com'
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Authenticate Jenkins to GCP') {
            steps {
                withCredentials([file(credentialsId: 'jenkinssvckey', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                    bat '''
                        echo Authenticating with service account key
                        gcloud auth activate-service-account --key-file="%GOOGLE_APPLICATION_CREDENTIALS%"
                        gcloud config set project %PROJECT_ID%
                        echo Impersonating: %GOOGLE_IMPERSONATE_SERVICE_ACCOUNT%
                        gcloud auth list
                    '''
                }
            }
        }

        stage('Terraform Init') {
            steps {
                withCredentials([file(credentialsId: 'jenkinssvckey', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                    bat '''
                        set GOOGLE_APPLICATION_CREDENTIALS=%GOOGLE_APPLICATION_CREDENTIALS%
                        terraform init -backend-config="impersonate_service_account=%GOOGLE_IMPERSONATE_SERVICE_ACCOUNT%"
                    '''
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([file(credentialsId: 'jenkinssvckey', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                    bat '''
                        set GOOGLE_APPLICATION_CREDENTIALS=%GOOGLE_APPLICATION_CREDENTIALS%
                        terraform plan -out=tfplan.out
                    '''
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                input message: "Apply Terraform changes?"
                withCredentials([file(credentialsId: 'jenkinssvckey', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                    bat '''
                        set GOOGLE_APPLICATION_CREDENTIALS=%GOOGLE_APPLICATION_CREDENTIALS%
                        terraform apply -auto-approve tfplan.out
                    '''
                }
            }
        }
    }

    post {
        always {
            echo 'Terraform pipeline completed'
        }
    }
}