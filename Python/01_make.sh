
CURRENT_TIME='date +"%H:%M:%S"'

echo "####start  sh 01_make.sh     `$CURRENT_TIME` ####"

#docker build --network=host -t cuda11.docker.repository.cloudera.com/cdsw/engine:13 . -f  01.02.cuda10.Dockerfile

docker build --network=host -t cuda11.docker.repository.cloudera.com/cdsw/engine:13 . -f 01.01.cuda11.Dockerfile

echo "####end  sh 01_make.sh     `$CURRENT_TIME` ####"
