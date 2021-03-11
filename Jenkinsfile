pipeline {
    agent {
        label 'dory'
    }
    parameters {
        booleanParam(
            name: 'PUBLISH', defaultValue: false, 
            description: 'Publish docker images on dockerhub')
        integerParam(
            name: 'GPF_BUILD', defaultValue: -1,
            description: 'gpf build number to use for tagging docker images')
        
    }    
    environment {
        GPF_BUILD="$params.GPF_BUILD"
        PUBLISH="$params.PUBLISH"
    }
    options { 
        copyArtifactPermission('/iossifovlab/gpf/*,/iossifovlab/gpf/master,/seqpipe/gpf_documentation/*');
        disableConcurrentBuilds();
    }
    triggers {
        pollSCM('@weekly')
    }
    stages {
        stage ('Start') {
            steps {
                zulipSend(
                    message: "Started build #${env.BUILD_NUMBER} of project ${env.JOB_NAME} (${env.BUILD_URL})",
                    topic: "${env.JOB_NAME}")
            }
        }

        stage ('Build images') {
            steps {
                sh '''
                    echo "WORKSPACE=${WORKSPACE}"
                    cd ${WORKSPACE}
                    ./build_images.sh ${PUBLISH} ${GPF_BUILD}
                '''
            }
        }

    }
    post {
        always {
            zulipNotification(
                topic: "${env.JOB_NAME}"
            )      
        }

    }
}
