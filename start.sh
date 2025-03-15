#!/bin/bash

# Nome do projeto (para isolar recursos no Docker)
PROJECT_NAME="desafio_devops"

# Função para exibir o menu
show_menu() {
    echo "----------------------------------"
    echo "  Gerenciamento do ambiente Docker"
    echo "----------------------------------"
    echo "1) Subir infraestrutura (build)"
    echo "2) Derrubar infraestrutura"
    echo "3) Limpar imagens não utilizadas"
    echo "4) Limpar volumes órfãos"
    echo "5) Resetar tudo (Down + Limpeza Completa)"
    echo "6) Sair"
    echo -n "Escolha uma opção: "
}

# Função para iniciar os containers com build
start_containers() {
    echo "Subindo a infraestrutura..."
    docker compose -p "$PROJECT_NAME" up --build -d
    echo "Infraestrutura iniciada com sucesso!"
}

# Função para parar e remover os containers
stop_containers() {
    echo "Derrubando a infraestrutura..."
    docker compose -p "$PROJECT_NAME" down
    echo "Infraestrutura removida!"
}

# Função para limpar imagens não utilizadas
clean_images() {
    echo "Removendo imagens não utilizadas..."
    docker image rm `docker image ls -q`
    echo "Imagens limpas!"
}

# Função para limpar volumes órfãos
clean_volumes() {
    echo "Removendo volumes não utilizados..."
    docker volume prune -f
    echo "Volumes limpos!"
}

# Função para resetar tudo
reset_all() {
    stop_containers
    clean_images
    clean_volumes
    echo "Infraestrutura completamente resetada!"
}

# Loop do menu
while true; do
    show_menu
    read -r choice
    case $choice in
        1) start_containers ;;
        2) stop_containers ;;
        3) clean_images ;;
        4) clean_volumes ;;
        5) reset_all ;;
        6) echo "Saindo..."; exit 0 ;;
        *) echo "Opção inválida, tente novamente." ;;
    esac
done
