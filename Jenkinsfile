pipeline {
  //Run everything on an agent that has docker daemon
  agent {
      node {
          label 'docker'
      }
  }

  environment {
    DOCKER_REGISTRY = "skynet.bah.com"
    IMAGE = "${DOCKER_REGISTRY}/glassfish/glassfish:2.1.1updatedjdk"
  }

  stages {
    stage ('Build docker Image') {
      steps {
          sh "docker build -t $IMAGE ."
      }
    }
    stage('Push docker image') {
      environment {
        ARTIFACTORY = credentials('artifactory-jenkins')
      }
      steps {
        sh "docker login $DOCKER_REGISTRY -u $ARTIFACTORY_USR -p $ARTIFACTORY_PSW"
        sh "docker push $IMAGE"
      }
    }
  }
  post {
    failure {
      mail to: 'ISAPIDev@bah.com',
           subject: "Build failed in Jenkins: ${currentBuild.fullDisplayName}",
           body: "See ${env.BUILD_URL}"
    }
    success {
      echo "Job completed successfully."
    }
    changed {
        echo 'Things were different before...'
    }
  }
}
