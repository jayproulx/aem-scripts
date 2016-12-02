#!/bin/bash
clear

#todo: need an option to pass in the AEM install folder (the prefix to crx-quickstart)
#todo: repository folder may be incorrect on some servers, since it seems to be repository/repository instead.

echo "Online KB -> https://docs.adobe.com/docs/en/aem/6-2/deploy/platform/storage-elements-in-aem-6.html"
echo
echo "Download oak-run tool from maven repository -> http://mvnrepository.com/artifact/org.apache.jackrabbit/oak-run"
echo

## Define an explicite version of java
#export JAVA_HOME=/opt/jdk/jdk1.8.0_101/
#export PATH=$JAVA_HOME/bin:$PATH
java -version

now="$(date +'%d-%m-%Y')"
logfile="compact-$now.log"
installfolder="/data/tomcat"
aemfolder="$installfolder/crx-quickstart"
repositoryfolder="$aemfolder/repository"
oakrunversion="1.4.9"
oakrun="$installfolder/oak-run.jar"

if [ ! -e "${oakrun}" ]; then
	wget http://central.maven.org/maven2/org/apache/jackrabbit/oak-run/${oakrunversion}/oak-run-${oakrunversion}.jar -O "${oakrun}"
fi

## Shutdown AEM
printf "Shutting down AEM.\n"
$aemfolder/bin/stop
now="$(date)"
echo "AEM Shutdown at: $now" >> $installfolder/$logfile

## Find old checkpoints
printf "Finding old checkpoints.\n"
java -Dtar.memoryMapped=true -Xms8g -Xmx8g -jar $oakrun checkpoints $repositoryfolder/segmentstore >> $installfolder/$logfile

## Delete unreferenced checkpoints: rm-unreferenced
## Delete all checkpoints and force full re-index: rm-all
printf "Deleting checkpoints.\n"
java -Dtar.memoryMapped=true -Xms8g -Xmx8g -jar $oakrun checkpoints $repositoryfolder/segmentstore rm-all >> $installfolder/$logfile

## Run compaction
printf "Running compaction. This may take a while.\n"
java -Dtar.memoryMapped=true -Doak.compaction.eagerFlush=true  -Dupdate.limit=5000000 -Dcompress-interval=10000000 -Dcompaction-progress-log=1500000 -Dlogback.configurationFile=$aemfolder/logback.xml -Xmx8g -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=$aemfolder/dumps -jar $oakrun compact $repositoryfolder/segmentstore >> $installfolder/$logfile

cd  $repositoryfolder/segmentstore
rm *.bak >> $installfolder/$logfile
rm *.lock >> $installfolder/$logfile
cd $repositoryfolder
rm -rf index >> $installfolder/$logfile

## Report Completed
printf "Compaction complete. Please check the log at:\n"
printf "$installfolder/$logfile\n"

## Uncomment bellow to start AEM after compaction.
## Start AEM back up
#now="$(date)"
#printf "Starting up AEM.\n"
#$aemfolder/bin/start
#echo "AEM Startup at: $now" >> $installfolder/$logfile