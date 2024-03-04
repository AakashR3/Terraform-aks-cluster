pipeline {
    agent {
        any
    }
    environment {
        GIT_SSH_COMMAND = "ssh -o StrictHostKeyChecking=no"
        DOCKER_IMAGE_NAME = "demo-test"
        AKS_CLUSTER_NAME = "aks-testing"
        RESOURCE_GROUP = "Aakash-Rg"
        KUBE_NAMESPACE = "aakash"
        //KUBECONFIG_PATH = "/path/to/your/kubeconfig" // Path to the kubeconfig file
    }
  
    stages {
        stage('git clone') {
            steps {
                git url: "https://github.com/AakashR3/sample-dotnet.git", branch: "main"
            }
        }
        stage('Configure kubectl Agent') {
            steps {
                script {
                    // Install Docker on the Jenkins agent if not already installed
                    // sh 'which docker || (curl -fsSL https://get.docker.com | sh)'
                    // Install kubectl on the Jenkins agent if not already installed
                    sh 'curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl'
                    sh 'chmod +x kubectl'
                    //sh 'mv kubectl /usr/local/bin/'
                }
            }
        }
        stage('Build') {
            steps {
                script {
                    def buildNumber = env.BUILD_NUMBER
                    sh "docker build -t containerregprojectx.azurecr.io/demo-test:${buildNumber} ."
                }
            }
        }
        stage('Login and push image to ACR') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'containerregprojectx', passwordVariable: 'password', usernameVariable: 'username')]) {
                    script {
                        def buildNumber = env.BUILD_NUMBER
                        sh "docker login -u ${username} -p ${password} containerregprojectx.azurecr.io" 
                        sh "docker push containerregprojectx.azurecr.io/demo-test:${buildNumber}"
                    }
                }
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                container('kubectl') {
                    withCredentials([kubeconfigFile(credentialsId: 'aakash-cluster', variable: 'KUBECONFIG')]) {
                        sh '''
                            export KUBECONFIG=$KUBECONFIG
                            kubectl apply -f node-deployment.yaml
                        '''
                    }
                }
            }
        }
    }
}
