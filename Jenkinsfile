pipeline{
    agent any

    stages{

        stage('get cloud creds'){
            steps{
                script{
                    def token = sh(
                        script: '''
                          sudo /root/yandex-cloud/bin/yc iam create-token --impersonate-service-account-id ajehae27q6mo0mq2tmdi
                        ''',
                        returnStdout: true
                    ).trim()

                    def cloud_id = sh(
                        script: '''
                          sudo /root/yandex-cloud/bin/yc config get cloud-id
                        ''',
                        returnStdout: true
                    ).trim()

                    def folder_id = sh(
                        script: '''
                          sudo /root/yandex-cloud/bin/yc config get folder-id
                        ''',
                        returnStdout: true
                    ).trim()

                    env.TF_VAR_yc_token = token
                    env.YC_TOKEN = token

                    env.TF_VAR_cloud_id = cloud_id
                    env.YC_CLOUD_ID = cloud_id

                    env.TF_VAR_folder_id = folder_id
                    env.YC_FOLDER_ID = folder_id
                }
            }
        }

        stage('get project'){
            steps{
                script {
                    //if (!fileExists('outwork/.git')) {
                        sh "git clone 'https://github.com/wipefree/outwork.git'"
                    //} else {
                    //    echo "[!] Репозиторий уже склонирован, пропускаем клонирование"
                    //}
                }
            }
        }

        stage('terraform init'){
            steps{
                dir('outwork'){
                    echo "[env.TF_VAR_yc_token ] -> ${env.TF_VAR_yc_token.substring(0, 20)} ........ secret......"
                    echo "[env.TF_VAR_cloud_id ] -> ${env.TF_VAR_cloud_id}"
                    echo "[env.TF_VAR_folder_id] -> ${env.TF_VAR_folder_id}"
                    sh 'terraform init'
                }
            }
        }

        stage ('terraform plan'){
            steps{
                dir('outwork') {
                    sh "terraform plan -out=tfplan"
               }
            }
        }

        stage('terraform apply'){
            steps{
                dir('outwork') {
                    sh "terraform apply -auto-approve tfplan"
               }
            }
        }

        stage('terraform ip vm'){
            steps{
                dir('outwork') {
                    script {
                        // Get IP addresses of created vm
                        def ipString = sh(
                        script: '''
                        terraform show | grep 'nat_ip_address' | cut -d'"' -f2
                        ''',
                         returnStdout: true
                        ).trim()

// Create inventory for Ansible
writeFile file: 'inventory.ini', text: """
[web_servers]
${ipString.replace('\n', '\n')}
[web_servers:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/id_ed25519
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
"""

                       sh 'cat inventory.ini'
                       sleep 30 // wait 30 seconds for nodes is started
                    }
                }
            }
        }

        stage('run Ansible'){
            steps{
                dir('outwork'){
                    sh 'sudo cp /root/.ssh/key.json /tmp/ansible_key.json'
                    sh 'sudo chmod 644 /tmp/ansible_key.json'
                    sh 'cp ./Dockerfile.builder /tmp/Dockerfile'

                    //sh '''
                    //ansible -i inventory.ini web_servers[0] -m ping
                    //ansible -i inventory.ini web_servers[0] -m shell -a "hostname && uname -a"
                    //ansible -i inventory.ini web_servers[1] -m ping
                    //ansible -i inventory.ini web_servers[1] -m shell -a "hostname && uname -a"
                    //'''

                    sh 'ansible-playbook -i inventory.ini build_dcr.yaml -v'
                    sh 'ansible-playbook -i inventory.ini web_prod.yaml -v'
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }

}
