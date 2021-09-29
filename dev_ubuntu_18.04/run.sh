#sudo docker run --privileged -it --rm dev_ubuntu:18.04 /bin/bash

docker run      --mount type=bind,src=/home/mike/txb_files,dst=/root/sv \
	                --name vc_sv -it --net host txblaster /bin/bash
