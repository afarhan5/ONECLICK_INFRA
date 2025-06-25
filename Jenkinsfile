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

        stage('Terraform Apply Approval') {
            steps {
                input message: "Do you want to apply Terraform changes?"
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

        stage('Generate Inventory') {
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

        stage('Ansible Run Approval') {
            steps {
                input message: "Do you want to run the Ansible playbook?"
            }
        }

        stage('Ansible Provisioning') {
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
