
SITE_DOMAIN=$1
TODAY=$2

if [ "$TODAY"  == "" ]; then
   TODAY=`date +"%Y%m%d"`
fi


echo "SITE_DOMAIN=$SITE_DOMAIN"

if [ "$SITE_DOMAIN"  == "" ]; then

   echo "example : $0  goodmit.com "
   exit 1
fi

echo "TODAY :   ${TODAY} "

CURRENT_TIME='date +"%H:%M:%S"'
echo "####start  sh save_docker.sh     `$CURRENT_TIME` ####"

# docker save  conda.docker.repository.cloudera.com/cdsw/engine:13  | gzip > conda.docker.repository.cloudera.com.tar.gz 

 docker save  tensorflow2.4.gpu.${SITE_DOMAIN}/cdsw/engine:13.${TODAY}  | gzip > tensorflow2.4.gpu.${SITE_DOMAIN}_${TODAY}.tar.gz 

#  docker save  pytorch1.9.${SITE_DOMAIN}/cdsw/engine:13.${TODAY}  | gzip >  pytorch1.9.${SITE_DOMAIN}_${TODAY}.tar.gz 

# docker save  tensorflow1.15.${SITE_DOMAIN}/cdsw/engine:13.${TODAY}  | gzip > tensorflow1.15.${SITE_DOMAIN}_${TODAY}.tar.gz

echo "####end  sh save_docker.sh     `$CURRENT_TIME` ####"
