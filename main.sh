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

installNodegoat(){
    install_requirements
    git clone https://github.com/OWASP/NodeGoat.git
    cd NodeGoat
    docker-compose build
    docker-compose up -d
    echo "Running Nodegoat at http://$HOST:4000"
    cd ../
}

installDVGraphql(){
    install_requirements
    docker pull dolevf/dvga
    docker run -d -p 5000:5000 -e WEB_HOST=0.0.0.0 dolevf/dvga
    echo "Running Damm Vulnerable GraphQL at http://$HOST:5000"
}

installOAuth(){
    install_requirements
    git clone https://github.com/koenbuyens/Vulnerable-OAuth-2.0-Applications
    cd Vulnerable-OAuth-2.0-Applications/insecureapplication
    docker-compose up -d
    echo "Running attacker: http://$HOST:1337, photoprint: http://$HOST:3000, gallery http://$HOST:3005"
    cd ..
}

cleanup(){
    sudo docker stop $(docker ps -a -q)
    sudo docker images -a
    sudo docker rmi $(docker images -a -q)
    sudo docker system prune -a -f
    sudo rm -rf NodeGoat
    sudo rm -rf Vulnerable-OAuth-2.0-Applications
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
    $(colorGreen '3)') Nodegoat
    $(colorGreen '4)') Damm Vulnerable GraphQL
    $(colorGreen '5)') Vulnerable OAuth 2.0 Applications
    $(colorGreen '6)') Clean
    $(colorGreen '0)') EXIT

    $(colorGreen 'Choose an option to run:') 
    "
    read a
    case $a in
        1) installDvwa ; main ;;
        2) installOwaspJuiceShop ; main ;;
        3) installNodegoat ; main ;;
        4) installDVGraphql ; main ;;
        5) installOAuth ; main ;;
        6) cleanup ; main ;;
        0) exit 0 ;;
    *) echo -e $red"Wrong option."$clear;
    esac
}

main
