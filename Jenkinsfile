pipeline {
    agent any

    environment {
        TF_DIR = "terraform"
        ANSIBLE_DIR = "ansible"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/afarhan5/ONECLICK_INFRA.git'
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-creds', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    dir("${TF_DIR}") {
                        sh '''
                            export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                            export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                            terraform init
                            terraform apply -auto-approve
                        '''
                    }
                }
            }
        }

        stage('Generate Inventory') {
            steps {
                dir("${TF_DIR}") {
                    script {
                        def publicIP = sh(script: "terraform output -raw public_ip", returnStdout: true).trim()
                        writeFile file: "../${ANSIBLE_DIR}/inventory.ini", text: """
[grafana]
${publicIP} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/grafana-key.pem
"""
                    }
                }
            }
        }

        stage('Ansible Provisioning') {
            steps {
                sshagent (credentials: ['grafana-key']) {
                    dir("${ANSIBLE_DIR}") {
                        sh 'ansible-playbook -i inventory.ini grafana.yml'
                    }
                }
            }
        }
    }
}
