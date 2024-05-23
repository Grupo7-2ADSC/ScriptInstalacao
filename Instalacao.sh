#!/bin/bash

echo "Olá! Seja bem-vindo(a) ao ambiente de instalação da Sentinel System, vou te auxiliar no processo de instalação."
sleep 2
echo "Podemos iniciar o processo de instalação? [s/n]"
read confirmation
if [ "$confirmation" = "S" ] || [ "$confirmation" = "s" ]; 
then
    echo "Iniciando instalação"
    sleep 3
    sudo apt upgrade && sudo apt update -y
    echo "Primeira etapa concluída. Agora precisamos verificar se você possui o Java instalado"
    sleep 3
    java --version
    if [ $? = 0 ]; 
then
	echo "       "
        echo "Você já possui o Java instalado!"
    else
        echo "Verificamos que você não possui o Java instalado."
        sleep 2
	echo "    "
        echo "Gostaria de instalar o Java? [s/n]"
        read get_java
        if [ "$get_java" == "s" ]; 
then
            sudo apt install openjdk-17-jre -y
	    echo "   "
            echo "Java instalado com sucesso!"
            sleep 3
        fi
    fi
	echo "    "
    echo "O próximo passo é verificar o mySQL em sua máquina"
    sleep 3
    mysql --version
    if [ $? = 0 ]; 
then
	echo "         "
        echo "Você já possui o MySQL!

"
    else
	echo "      "
        echo "Percebemos que você ainda não tem o MySQL instalado"
        sleep 2
	echo "       "
        echo "Gostaria de instalar o MySQL? [s/n]"
        read get_mysql
        if [ "$get_mysql" == "s" ]; 
then
            sudo apt install mysql-server -y
	    echo "   "
            echo "MySQL instalado com sucesso!"
        else
	    echo "      "
            echo "O MySQL não será instalado, isso pode acarretar eventual erro"
        fi
    fi
	echo "     "
    echo "O último passo é verificarmos se você possui o GIT instalado. O GIT é o sistema que utilizamos para manter nossa aplicação atualizada e acrescentarmos novas features."
    sleep 3

    git --version
    if [ $? = 0 ]; 
then
        if [ -d "Jar" ]; 
then
		echo "     "
            echo "Você já possui o GIT e nossa aplicação!"
            sleep 3
		echo "    "
            cd "Jar" && git pull && cd ..
            echo "Aplicação atualizada e pronta para uso"
sleep 3
        else
		echo "      "
            echo "Você possui o GIT mas precisamos instalar nossa aplicação, aguarde um instante"
            sleep 3
            git clone https://github.com/Grupo7-2ADSC/Jar-Gp7.git
        fi
    else
	echo "        "
        echo "Você não possui o GIT instalado, deseja instalar agora? [s/n]"
        read get
        if [ "$get" = "S" ] || [ "$get" = "s" ]; 
then
            sudo apt install git
            git clone https://github.com/Grupo7-2ADSC/Jar-Gp7.git
		echo "       "
            echo "Instalação concluída com sucesso"
            sleep 3
        else
		echo "     "
            echo "Que pena! Estaremos aguardando caso mude de ideia"
            sleep 3
        fi
    fi
fi

echo "      "
echo "Instalação finalizada! Pressione Enter para sair."
read
