# tpm2-ssh
Download Code
```
git clone https://github.com/sedillo/tpm2-ssh.git
cd tpm2-ssh
```
Build and run the containers
```
mkdir -p voldir
docker build -t tpm-build --build-arg SOPIN=mysopin --build-arg USERPIN=myuserpin .
docker run -d -it --rm --name tpmssh -v $(pwd)/voldir:/tpm2/voldir -v /dev/tpm0:/dev/tpm0 -v /dev/tpmrm0:/dev/tpmrm0 --privileged build-tpm
```
Copy the key to cameras
```
docker exec -it tpmssh ssh-copy-id -f -i my.pub root@172.16.222.33 -p 49155
```
Use the container to execute ssh 
```
docker exec -it tpmssh ssh -I /usr/local/lib/libtpm2_pkcs11.so 172.16.222.33 -p 49155
```
Debug Container 
```
docker exec -it tpmssh bash
```
