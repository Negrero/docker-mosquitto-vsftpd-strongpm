


docker build -t vsftpd-mosquito-strongpm .

docker stop vsftp-mosquito;docker rm vsftp-mosquito

docker run -d  -p 8701:8701 -p 3000-3010:3000-3010 -p 20-22:20-22 -p 9001:9001 -p 8080:8080 -p 4559-4564:4559-4564 -p 1883:1883 --name vsftp-mosquito -h vsftp-mosquito -e FTP_USER=andres -e FTP_PASSWORD=andres -e FTP_USERS_ROOT vsftpd-mosquito-strongpm 
