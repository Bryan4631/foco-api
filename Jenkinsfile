// CI/CD de la API de Foco (Rails 8.1 en modo API + PostgreSQL) para jenkins.frubilarz.cl.
//
// El servidor Jenkins tiene un solo executor y Docker disponible. Las etapas de CI corren
// dentro de contenedores efimeros conectados a la red Docker externa `course-net`; la base
// de datos de test es un contenedor PostgreSQL levantado por build y destruido al terminar.
//
// Flujo:
//   Checkout -> Test DB -> Install deps -> Lint -> Security -> Test -> Build image
//   (solo rama `production`) -> Deploy -> Health Check
//
// Produccion: el contenedor se publica en 127.0.0.1:4108 y el reverse proxy del servidor
// (Nginx + Certbot) expone https://apifoco.frubilarz.cl hacia ese puerto.
// Las migraciones las corre bin/docker-entrypoint al arrancar el contenedor.
//
// Credenciales de Jenkins que necesita el Deploy (tipo "Secret text"):
//   foco-database-url     DATABASE_URL completa hacia el PostgreSQL de produccion
//   foco-secret-key-base  SECRET_KEY_BASE (JWT_SECRET cae a este valor si no se define)
//
// Nota: los scripts de bin/ tienen shebang `ruby.exe` (creados en Windows); el Dockerfile lo
// corrige con sed, y aqui se invocan con `ruby bin/<script>` para no depender del shebang.
pipeline {
    agent any

    options {
        disableConcurrentBuilds()
        timeout(time: 30, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '20'))
    }

    environment {
        DOCKER_NETWORK = 'course-net'
        APP_NAME       = 'foco-api'
        POSTGRES_IMAGE = 'postgres:16-alpine'
        RUBY_IMAGE     = 'ruby:3.3.12-slim'
        BUNDLE_VOLUME  = 'foco-api-bundle'
        DEPLOY_PORT    = '4108'
        PUBLIC_URL     = 'https://apifoco.frubilarz.cl'
        CORS_ORIGINS   = 'https://focoweb.frubilarz.cl'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                script {
                    def safeBranch = env.BRANCH_NAME.replaceAll(/[^A-Za-z0-9_.-]/, '-').toLowerCase()
                    env.SAFE_BRANCH  = safeBranch
                    env.DB_CONTAINER = "${APP_NAME}-test-db-${safeBranch}-${env.BUILD_NUMBER}"
                    env.IMAGE_TAG    = "${APP_NAME}:${safeBranch}-${env.BUILD_NUMBER}"
                }
            }
        }

        stage('Test DB') {
            steps {
                sh '''
                    docker rm -f "$DB_CONTAINER" >/dev/null 2>&1 || true
                    docker run -d --name "$DB_CONTAINER" --network "$DOCKER_NETWORK" \
                      -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres \
                      "$POSTGRES_IMAGE"
                    for i in $(seq 1 30); do
                      if docker exec "$DB_CONTAINER" pg_isready -U postgres >/dev/null 2>&1; then
                        echo "PostgreSQL listo"; exit 0
                      fi
                      sleep 1
                    done
                    echo "PostgreSQL no respondio a tiempo"; docker logs "$DB_CONTAINER"; exit 1
                '''
            }
        }

        stage('Build & Test') {
            environment {
                RAILS_ENV    = 'test'
                DATABASE_URL = "postgres://postgres:postgres@${env.DB_CONTAINER}:5432"
                BUNDLE_PATH  = '/usr/local/bundle'
            }
            steps {
                script {
                    docker.image(env.RUBY_IMAGE).inside("--network ${env.DOCKER_NETWORK} -u root:root -v ${env.BUNDLE_VOLUME}:/usr/local/bundle") {
                        try {
                            stage('Install deps') {
                                sh '''
                                    apt-get update -qq
                                    apt-get install -y -qq --no-install-recommends build-essential git libpq-dev libvips libyaml-dev pkg-config curl >/dev/null
                                    gem install bundler -v "$(tail -1 Gemfile.lock | tr -d ' ')" --no-document >/dev/null
                                    bundle config set --local without ""
                                    bundle install --jobs 4 --retry 3
                                '''
                            }
                            stage('Lint') {
                                sh 'ruby bin/rubocop'
                            }
                            stage('Security') {
                                sh 'bundle exec brakeman --no-pager'  // sin --ensure-latest de bin/brakeman
                                sh 'ruby bin/bundler-audit'
                            }
                            stage('Test') {
                                sh 'ruby bin/rails db:test:prepare test'
                            }
                        } finally {
                            // El contenedor corre como root: sin esto los archivos creados en el
                            // workspace (tmp/, log/) quedan de root y Jenkins (uid 1000) no puede
                            // borrarlos en el siguiente checkout.
                            sh 'chown -R 1000:1000 "$WORKSPACE" || true'
                        }
                    }
                }
            }
        }

        stage('Build image') {
            steps {
                sh 'docker build -t "$IMAGE_TAG" -t "$APP_NAME:$SAFE_BRANCH" .'
            }
        }

        stage('Deploy') {
            when { branch 'production' }
            steps {
                withCredentials([
                    string(credentialsId: 'foco-database-url',    variable: 'PROD_DATABASE_URL'),
                    string(credentialsId: 'foco-secret-key-base', variable: 'PROD_SECRET_KEY_BASE')
                ]) {
                    sh '''
                        docker rm -f "$APP_NAME" || true
                        docker run -d \
                          --name "$APP_NAME" \
                          --network "$DOCKER_NETWORK" \
                          --restart unless-stopped \
                          -p 127.0.0.1:$DEPLOY_PORT:3000 \
                          -e RAILS_ENV=production \
                          -e DATABASE_URL="$PROD_DATABASE_URL" \
                          -e SECRET_KEY_BASE="$PROD_SECRET_KEY_BASE" \
                          -e CORS_ORIGINS="$CORS_ORIGINS" \
                          "$IMAGE_TAG"
                    '''
                }
            }
        }

        stage('Health Check') {
            when { branch 'production' }
            steps {
                // El curl corre DENTRO del contenedor: el 127.0.0.1 de Jenkins no es el del host.
                // production.rb tiene assume_ssl = true, asi que /up responde 200 sin cabeceras
                // extra aunque la peticion llegue por http.
                sh '''
                    for i in $(seq 1 40); do
                      if docker exec "$APP_NAME" curl -fsS http://127.0.0.1:3000/up >/dev/null; then
                        echo "$APP_NAME OK"; break
                      fi
                      if [ "$(docker inspect -f '{{.State.Running}}' "$APP_NAME" 2>/dev/null)" != "true" ]; then
                        echo "El contenedor $APP_NAME no esta corriendo"; docker logs --tail 50 "$APP_NAME"; exit 1
                      fi
                      if [ "$i" = 40 ]; then echo "Timeout: $APP_NAME no respondio en 120 s"; docker logs --tail 50 "$APP_NAME"; exit 1; fi
                      sleep 3
                    done
                    # Verificacion publica a traves del reverse proxy (no bloquea si aun no esta configurado).
                    curl -fsS -o /dev/null "$PUBLIC_URL/up" && echo "$PUBLIC_URL OK" \
                      || echo "AVISO: $PUBLIC_URL/up no responde; revisar Nginx/DNS/Certbot en el servidor"
                '''
            }
        }
    }

    post {
        always {
            sh 'docker rm -f "$DB_CONTAINER" >/dev/null 2>&1 || true'
        }
    }
}
