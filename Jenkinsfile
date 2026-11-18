// MIDTERM pipeline: GitHub push -> retrain -> test -> Docker build -> deploy on EC2 -> email
pipeline {
  agent any

  options {
    timestamps()
    timeout(time: 15, unit: 'MINUTES')
  }

  environment {
    // >>> EDIT THESE TWO <<<
    SENDER_EMAIL = 'hadiyamurad04@gmail.com'      // must equal the address you submit in the Google Form
    EC2_HOST     = '16.170.67.170'        // used only for the link in the email
    RECIPIENT    = 'qasimalik@gmail.com'
    CONTAINER    = 'midterm-app'
  }

  stages {
    stage('Fetch Latest Data') {
      steps {
        checkout scm
        script {
          env.GIT_COMMIT_FULL = sh(script: 'git rev-parse HEAD', returnStdout: true).trim()
          env.GIT_SHORT       = env.GIT_COMMIT_FULL.take(7)
          env.REG_NO          = sh(script: "python3 -c \"import json;print(json.load(open('config.json'))['student_id'])\"",
                                   returnStdout: true).trim()
          env.IMAGE           = "midterm-${env.REG_NO.toLowerCase()}"
        }
        sh 'echo "Commit: $GIT_COMMIT_FULL  Reg: $REG_NO"; wc -l dataset/train.csv'
      }
    }

    stage('Train') {
      steps {
        sh '''
          python3 -m venv venv
          . venv/bin/activate
          pip install --quiet --upgrade pip
          pip install --quiet -r requirements.txt
          GIT_COMMIT="$GIT_COMMIT_FULL" python train.py
        '''
      }
    }

    stage('Test') {
      steps {
        sh '. venv/bin/activate && python -m pytest -q tests'
      }
    }

    stage('Docker Build') {
      steps {
        sh 'docker build -t ${IMAGE}:${BUILD_NUMBER} -t ${IMAGE}:latest .'
      }
    }

    stage('Deploy') {
      steps {
        sh '''
          docker rm -f ${CONTAINER} || true
          docker run -d --name ${CONTAINER} --restart unless-stopped -p 8000:8000 ${IMAGE}:latest
          for i in $(seq 1 20); do
            if curl -fs http://localhost:8000/metrics > /tmp/metrics_${BUILD_NUMBER}.json; then
              echo "Deployed OK:"; cat /tmp/metrics_${BUILD_NUMBER}.json; exit 0
            fi
            sleep 3
          done
          echo "Deployment health check failed"; docker logs ${CONTAINER}; exit 1
        '''
      }
    }
  }

  post {
    always {
      script {
        def metrics = fileExists('artifacts/metrics.json') ? readFile('artifacts/metrics.json') : 'n/a (training did not finish)'
        def reg = env.REG_NO ?: 'UNKNOWN-REG'
        emailext(
          from: env.SENDER_EMAIL,
          to: env.RECIPIENT,
          subject: "[${reg}] MIDTERM Build #${env.BUILD_NUMBER} - ${currentBuild.currentResult}",
          body: """Student Reg No: ${reg}
Build result:   ${currentBuild.currentResult}
Build number:   ${env.BUILD_NUMBER}
Git commit:     ${env.GIT_COMMIT_FULL}
Metrics URL:    http://${env.EC2_HOST}:8000/metrics
Build URL:      ${env.BUILD_URL}

Training metrics:
${metrics}
"""
        )
      }
    }
  }
}
