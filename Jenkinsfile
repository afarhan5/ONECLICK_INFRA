pipeline {
    agent any

    environment {
        TF_DIR = "terraform"
        ANSIBLE_DIR = "ansible"
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/afarhan5/ONECLICK_INFRA.git'
            }
        }

        stage('Approval to Apply Terraform') {
            steps {
                input message: "Proceed with Terraform apply?"
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds'
                ]]) {
                    dir("${TF_DIR}") {
                        sh '''
                            terraform init
                            terraform apply -auto-approve
                        '''
                    }
                }
            }
        }

        stage('Generate Ansible Inventory') {
            steps {
                dir("${TF_DIR}") {
                    script {
                        def publicIP = sh(script: "terraform output -raw public_ip", returnStdout: true).trim()
                        writeFile file: "../${ANSIBLE_DIR}/inventory.ini", text: """
[grafana]
${publicIP} ansible_user=ubuntu
"""
                    }
                }
            }
        }

        stage('Approval to Run Ansible Playbook') {
            steps {
                input message: "Proceed with Ansible provisioning?"
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                sshagent (credentials: ['grafana-key']) {
                    dir("${ANSIBLE_DIR}") {
                        sh 'ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory.ini install-grafana.yml'
                    }
                }
            }
        }
    }
}
