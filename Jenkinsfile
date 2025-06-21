pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/afarhan5/ONECLICK_INFRA.git'
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Apply') {
            steps {
                sh 'terraform apply -auto-approve'
            }
        }

        stage('Extract IP') {
            steps {
                script {
                    def ip = sh(script: "terraform output -raw public_ip", returnStdout: true).trim()
                    writeFile file: 'ansible/inventory', text: "[grafana]\n${ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/your-key.pem"
                }
            }
        }

        stage('Run Ansible') {
            steps {
                sh 'ansible-playbook -i ansible/inventory ansible/install-grafana.yml'
            }
        }
    }

    post {
        success {
            echo 'Grafana deployed successfully!'
        }
        failure {
            echo 'Deployment failed!'
        }
    }
}
