#!/usr/bin/bash

install_requirements(){
    sudo yum update -y
    sudo yum install git -y
    sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo    sudo systemctl start docker
    sudo dnf install --nobest docker-ce
    sudo dnf install docker-ce -y
    sudo systemctl disable firewalld
    sudo systemctl enable --now docker
    sudo curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o docker-compose
    sudo mv docker-compose /usr/local/bin && sudo chmod +x /usr/local/bin/docker-compose
    sudo dnf install python3-pip
    pip3.6 install docker-compose --user
    HOST=$(curl ifconfig.me)
}

# color pallet
readonly cf="\\033[0m"
readonly red="\\033[0;31m"
readonly green="\\033[1;32m"

# color functions
colorGreen(){
    echo -ne $green$1$clear
}

colorred(){
    echo -ne $red$1$clear
}

installDvwa(){
    install_requirements
    sudo docker run -d --rm -p 8001:80 vulnerables/web-dvwa
    echo "Running Dvwa at http://$HOST:8001"
}

installOwaspJuiceShop(){
    install_requirements
    sudo docker run -d --rm -p 3000:3000 bkimminich/juice-shop
    echo "Running Owasp Juice shop at http://$HOST:3000"
}

cleanup(){
    sudo docker stop $(docker ps -a -q)
    sudo docker images -a
    sudo docker rmi $(docker images -a -q)
    sudo docker system prune -a -f
}

printf """$green
            .__                                        
___  ____ __|  |   ______  _  _______    ____________  
\  \/ /  |  \  |  /  _ \ \/ \/ /\__  \  /  ___/\____ \ 
 \   /|  |  /  |_(  <_> )     /  / __ \_\___ \ |  |_> >
  \_/ |____/|____/\____/ \/\_/  (____  /____  >|   __/ 
                                     \/     \/ |__|                                                              
                                                                                                                    
"""

main(){
    echo -ne "
    $(colorGreen '1)') DVWA
    $(colorGreen '2)') Owasp Juice Shop
    $(colorGreen '3)') Clean
    $(colorGreen '0)') EXIT

    $(colorGreen 'Choose an option to run:') 
    "
    read a
    case $a in
        1) installDvwa ; main ;;
        2) installOwaspJuiceShop ; main ;;
        3) cleanup ; main ;;
        0) exit 0 ;;
    *) echo -e $red"Wrong option."$clear;
    esac
}

main
