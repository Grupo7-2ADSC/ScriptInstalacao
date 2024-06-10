# Função para barra de progresso
progress_bar() {
    local duration=$1
    already_done() { for ((done=0; done<$elapsed; done++)); do printf "▇"; done }
    remaining() { for ((remain=$elapsed; remain<$duration; remain++)); do printf " "; done }
    percentage() { printf "| %s%%" $(( (($elapsed)*100)/($duration)*100/100 )); }
    clean_line() { printf "\r"; }
    for ((elapsed=1; elapsed<=$duration; elapsed++))
    do
        already_done; remaining; percentage
        sleep 1
        clean_line
    done
    printf "\n"
}

clear

# Função bot_message (assumindo que você tenha algo para lidar com isso)
bot_message() {
    echo "$1"
}

bot_success() {
    echo "$1"
}

bot_message "Olá! Seja bem-vindo(a) ao ambiente de instalação da Sentinel System. Vou te auxiliar no processo de instalação."
sleep 3

echo "Podemos iniciar o processo de instalação? [s/n]"
read confirmation

if [[ "$confirmation" =~ ^[Ss]$ ]]; then
    echo "Iniciando instalação"
    sleep 3
    sudo apt update -y && sudo apt upgrade -y

    echo "Primeira etapa concluída. Agora precisamos verificar se você possui o Java instalado"
    sleep 3
    java --version
    if [ $? -eq 0 ]; then
        echo "Você já possui o Java instalado!"
    else
        echo "Verificamos que você não possui o Java instalado."
        sleep 2
        echo "Gostaria de instalar o Java? [s/n]"
        read get_java
        if [[ "$get_java" =~ ^[Ss]$ ]]; then
            sudo apt install -y openjdk-17-jre
            (progress_bar 10) &
            pid=$!
            wait $pid
            echo "Java instalado com sucesso!"
            sleep 3
        fi
    fi

    # Verificar se o Docker está instalado
    echo "Agora vamos verificar se você possui o Docker instalado."
    if ! [ -x "$(command -v docker)" ]; then
        echo "Notamos que você não possui o Docker instalado, vamos dar início à instalação!"
        sleep 3
        progress_bar 3
        sudo apt-get update
        sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
        sudo apt-get update
        sudo apt-get install -y docker-ce
    fi

    # Verificar se o Docker Compose está instalado
    if ! [ -x "$(command -v docker-compose)" ]; then
        echo "Você também não possui o Docker Compose em sua máquina, vamos dar sequência na instalação."
        sleep 3
        progress_bar 3
        sudo curl -L "https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        clear
    fi

    # Verificar se o Maven está instalado
    if ! [ -x "$(command -v mvn)" ]; then
        echo "Maven não está instalado. Instalando Maven..."
        sleep 3
        progress_bar 3
        sudo apt-get install -y maven
        clear
    fi

    # Criar diretório para yml
    mkdir -p dockerCompose

    # Ir para o diretório
    cd dockerCompose

    # Clonar o repositório GitHub
    echo "Vamos clonar o repositório para funcionamento do sistema"
    sleep 3
    progress_bar 5
    git clone https://github.com/Grupo7-2ADSC/Jar-Gp7.git
    clear

    # Construir o projeto usando Maven
    echo "Construindo o projeto Maven"
    sleep 3
    progress_bar 5
    cd Jar-Gp7
    mvn clean install
    clear

    # Verificar se o JAR foi criado corretamente
    if [ ! -f "SSS.jar" ]; then
        echo "Erro: Não foi possível localizar o arquivo JAR após a construção do Maven."
        exit 1
    fi

    # Voltar para o diretório dockerCompose
    cd ..

    # Criar o arquivo docker-compose.yml
    bot_message "Criando o arquivo docker-compose.yml..."
    progress_bar 3
    cat <<EOL > docker-compose.yml
version: '3.3'
services:
  mysql:
    container_name: containerBD
    image: mysql:5.7
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: urubu100
      MYSQL_DATABASE: root
    volumes:
      - ./init-scripts:/docker-entrypoint-initdb.d
    ports:
      - "3306:3306"
  java:
    image: openjdk:17
    container_name: javaSentinelSystem
    depends_on:
      - mysql
    volumes:
      - ./Jar-Gp7:/JAR Grupo
    working_dir: /JAR Grupo
    command: ["java", "-jar", "SSS.jar"]
EOL

    # Criar diretório init-scripts
    echo "Agora estamos dando sequência ao procedimento para perfeita execução do sistema"
    sleep 2
    progress_bar 3
    mkdir -p init-scripts

    # Iniciar Docker
    echo "Iniciando o Docker ..."
    sleep 2
    sudo systemctl start docker

    # Iniciar Docker Compose
    echo "Iniciando o Docker Compose..."
    sleep 2
    progress_bar 5
    sudo docker-compose up -d

    # Aguardar os containers iniciarem
    echo "Aguardando os containers iniciarem..."
    sleep 2
    progress_bar 5
    sleep 5

    # Verificar se os containers estão em execução
    if [ "$(sudo docker inspect -f '{{.State.Running}}' javaSentinelSystem)" == "true" ]; then
        echo "Todos os containers estão em execução."
        sleep 2
    else
        echo "O container Java não está em execução. Verifique os logs para mais detalhes."
        sleep 2
        sudo docker-compose logs
        exit 1
    fi

    # Perguntar ao usuário se ele deseja executar o JAR
    echo "Deseja executar o arquivo JAR agora (S/N)?"
    read exec_jar

    if [[ "$exec_jar" =~ ^[Ss]$ ]]; then
        echo "Executando o arquivo JAR..."
        sleep 2
        sudo docker-compose exec java java -jar SSS.jar
    else
        echo "Você optou por não executar o JAR agora. Até a próxima!"
        sleep 2
    fi

    # Adicionar alias ao arquivo .bashrc
    echo "Adicionando apelido para facilitar a execução do JAR."
    sleep 2
    echo "alias executar='sudo docker-compose exec java java -jar SSS.jar'" >> ~/.bashrc
    source ~/.bashrc

    bot_success "Instalação concluída!"
fi

