#!/bin/bash

# Função para exibir a barra de progresso
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

echo "Olá! Seja bem-vindo(a) ao ambiente de instalação da Sentinel System. Vou te auxiliar no processo de instalação."
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

    echo "Agora precisamos fazer a instalação do Docker e a criação de containers. Essas ferramentas vão garantir que nosso sistema funcione adequadamente e com um melhor desempenho."
    sleep 4
    echo "Podemos iniciar? [s/n]"
    read get
    if [[ "$get" =~ ^[Ss]$ ]]; then 
        sudo apt install -y docker.io
        (progress_bar 10) & 
        pid=$!
        wait $pid
                
        echo "Docker já instalado, agora iremos iniciá-lo"
        sudo systemctl start docker
        sudo systemctl enable docker
        sleep 3
        (progress_bar 10) & 
        pid=$!
        wait $pid

        echo "Docker iniciado!"
        sleep 4

        echo "Agora que já temos nosso ambiente Docker, vamos criar um contêiner para rodar o Git."
        sleep 3

        sudo docker run -it --name git-container ubuntu:latest bash -c "apt update && apt install -y git && git clone https://github.com/Grupo7-2ADSC/Jar-Gp7.git"
        (progress_bar 5) & 
        pid=$!
        wait $pid

        echo "Clonagem do repositório concluída com sucesso"
        sleep 3

        echo "Nosso próximo passo é instalar um banco de dados. Isso permite que possamos armazenar os dados capturados, criar gráficos dinâmicos e gerar relatórios"
        sleep 4

        sudo docker run -d -p 3306:3306 --name ContainerBD -e "MYSQL_DATABASE=sentinel_system" -e "MYSQL_ROOT_PASSWORD=@Thigas844246" mysql:5.7
        echo "Esperando o contêiner inicializar..."
        sleep 30 # Ajuste conforme necessário para garantir que o MySQL esteja pronto

        echo "Excelente!! Os containers e Docker já foram criados e a conexão com o banco está pronta."
        sleep 4
        echo "Instalação finalizada! Pressione Enter para sair."
        read
    else
        echo "Infelizmente você não quis prosseguir e isso pode gerar falhas na execução do sistema. Caso mude de ideia, estamos prontos para continuar a instalação."
        sleep 4
    fi
else
    echo "Instalação abortada pelo usuário."
    sleep 2
fi

