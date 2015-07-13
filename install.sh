#!/bin/bash

# Move to /usr/share to download/install the ELK Stack
cd /usr/share

# Create an archive directory
mkdir elkArchive

if [ "$(whoami)" == "root" ]; then
	# Get the end user's username
	echo "What is your username on this system?"
	read -s theuser
else
	echo "This script must be run with superuser permissions.  Try putting sudo infront of it"
	exit 1
fi

# Check for existing versions
existingVersions=`ls | egrep "elasticsearch.*[0-9]$|logstash.*[0-9]$|kibana.*[0-9]$"`
#dlfiledelete=`ls | egrep "elasticsearch.*.tar.gz$|logstash.*.tar.gz$|kibana.*.tar.gz$"`

# Loop over relevantly named directories and move/delete them based on user input
for todelete in $existingVersions; 
do
    echo "$todelete already exists.  Would you like to install over it? (Y/n)";
    read removeExisting ;
    if [[ ("$removeExisting" == "Y") || ("$removeExisting" == "y") ]]; then
	# Install the plugin
	rm -r $todelete
	# Let user know old version was deleted
	echo "Previously installed version of $todelete was deleted."
    else
	# Move the old version into the archive
	mv $todelete elkArchive/${todelete}
	# Let user know it was moved
	echo "Previously installed version of $todelete moved into /usr/share/elkArchive."
    fi ;
done    


# Download Elasticsearch
curl -O https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-1.5.2.tar.gz

# Download Logstash
curl -O http://download.elastic.co/logstash/logstash/logstash-1.5.2.tar.gz

# Download Kibana Distro based on operating system/chipset properties
if [[ `echo $OSTYPE | egrep "([.*x]$)"` != "" ]]; then
    if [[ `uname -m` == "x86_64" ]]; then 
	# For 64 Bit Linux Distros uncomment the line below:
	curl -O https://download.elastic.co/kibana/kibana/kibana-4.1.1-linux-x64.tar.gz 
	tar xvfz kibana-4.1.1-linux-x64.tar.gz
	chown -R $theuser /usr/share/kibana-4.1.1-linux-x86
	ln -s /usr/share/kibana-4.1.1-linux-x64 /usr/share/kibana &
    else 
	# For 32 Bit Linux Distros uncomment the line below:
	curl -O https://download.elastic.co/kibana/kibana/kibana-4.1.1-linux-x86.tar.gz 
	tar xvfz kibana-4.1.1-linux-x86.tar.gz 
	chown -R $theuser /usr/share/kibana-4.1.1-linux-x86
	ln -s /usr/share/kibana-4.1.1-linux-x86 /usr/share/kibana &
    fi
else
    # Install the Mac OSX compatible Kibana
    curl -O https://download.elastic.co/kibana/kibana/kibana-4.1.1-darwin-x64.tar.gz
    tar xvfz kibana-4.1.1-darwin-x64.tar.gz
    chown -R $theuser /usr/share/kibana-4.1.1-darwin-x64
    ln -s /usr/share/kibana-4.1.1-darwin-x64 /usr/share/kibana
fi

# Untar/Decompress each of the files
tar xvfz elasticsearch-1.5.2.tar.gz 
tar xvfz logstash-1.5.2.tar.gz

# Then give yourself ownership/permissions on these directories
# On OSX if your username is billy and you have admin permissions it might look like
chown -R $theuser /usr/share/{elasticsearch-1.5.2,logstash-1.5.2}

# Give read/write/execute permissions to anyone with access to this system
chmod -R a+rwx /usr/share/{elasticsearch-1.5.2,logstash-1.5.2}

# Install the Elasticsearch csv plugin
mkdir -p /usr/share/elasticsearch-1.5.2/{plugins,work,tmp,data}

# Create symlinks to the original untarred/zipped directories
ln -s /usr/share/elasticsearch-1.5.2 /usr/share/elasticsearch 
ln -s /usr/share/logstash-1.5.2 /usr/share/logstash

# Change file permissions for symlinked directories
chown -R $theuser /usr/share/{elasticsearch,logstash,kibana}
chmod -R +rwx /usr/share/{elasticsearch,logstash,kibana}

# Move into Elasticsearch root directory
cd /usr/share/elasticsearch

################################################################################
##################### Language Analyzers #######################################
################################################################################

################################################################################
##################### Officially Supported Plugins #############################
################################################################################

echo "Would you like to install the ICU Analyzer plugin? Enter Y for yes or N for no then hit enter."
read   icuanalyzer
if [[ ("$icuanalyzer" == "Y") || ("$icuanalyzer" == "y") ]]; then
    # Install the plugin
    bin/plugin --install elasticsearch/elasticsearch-analysis-icu/2.5.0
elif [[ ("$icuanalyzer" == "x") ]]; then
    exit 1
else 
    echo “See https://github.com/elasticsearch/elasticsearch-analysis-icu for more info about the ICU Analyzer”
fi

echo "Would you like to install the Japanese Language Analyzer plugin? Enter Y for yes or N for no then hit enter."
read   kuromoji
if [[ ("$kuromoji" == "Y") || ("$kuromoji" == "y") ]]; then
    # Install Japanese language analyzer
    bin/plugin --install elasticsearch/elasticsearch-analysis-kuromoji/2.5.0
else 
    echo “See https://github.com/elasticsearch/elasticsearch-analysis-kuromoji for more info about the Japanese language Analyzer”
fi

echo "Would you like to install the Chinese language analyzer? Enter Y for yes or N for no then hit enter."
read   chinese
if [[ ("$chinese" == "Y") || ("$chinese" == "y") ]]; then
    # Install the Chinese Language Analyzer
    bin/plugin --install elasticsearch/elasticsearch-analysis-smartcn/2.5.0
else 
    echo “See https://github.com/elasticsearch/elasticsearch-analysis-smartcn for more info about the Chinese language analyzer”
fi

echo "Would you like to install the Polish language analyzer? Enter Y for yes or N for no then hit enter."
read   polish
if [[ ("$polish" == "Y") || ("$polish" == "y") ]]; then
    # Install the Polish language analyzer
    bin/plugin --install elasticsearch/elasticsearch-analysis-stempel/2.4.3
else 
    echo “See https://github.com/elasticsearch/elasticsearch-analysis-stempel for more info about the Polish language analyzer”
fi

################################################################################
#####################  Community Supported Plugins #############################
################################################################################

#echo "Would you like to install the Annotation Analyzer? Enter Y for yes or N for no then hit enter."
#read   annotate
#if [[ ("$annotate" == "Y") || ("$annotate" == "y") ]]; then
#    # Install the annotation analyzer plugin
#    bin/plugin —-install annotation-analysis —-url https://github.com/barminator/elasticsearch-analysis-annotation
#else 
#    echo “See https://github.com/barminator/elasticsearch-analysis-annotation for more info about the Annotation Analyzer”
#fi


#echo "Would you like to install the Combo Analyzer plugin? Enter Y for yes or N for no then hit enter."
#read   combo
#if [[ ("$combo" == "Y") || ("$combo" == "y") ]]; then
#    bin/plugin —-install com.yakaz.elasticsearch.plugins/elasticsearch-analysis-combo/1.5.1
#else
#    echo “See https://github.com/yakaz/elasticsearch-analysis-combo/ for more info about the Combo Analyzer”
#fi

#echo "Would you like to install the Hunspell Analyzer? Enter Y for yes or N for no then hit enter."
#read   hunspell
#if [[ ("$hunspell" == "Y") || ("$hunspell" == "y") ]]; then
#    bin/plugin —-install —-url https://github.com/jprante/elasticsearch-analysis-hunspell/1.1.1
#else
#    echo “See https://github.com/jprante/elasticsearch-analysis-hunspell for more info about the Lucene Hunspell Analyzer”
#fi

#echo "Would you like to install the IK Analyzer? Enter Y for yes or N for no then hit enter."
#read   ikanalyzer
#if [[ ("$ikanalyzer" == "Y") || ("$ikanalyzer" == "y") ]]; then
#    bin/plugin —-install —-url https://github.com/medcl/elasticsearch-rtf/tree/master/plugins/analysis-ik
#else 
#    echo “See https://github.com/medcl/elasticsearch-analysis-ik for more info about the Lucene IK Analyzer”
#fi

#echo "Would you like to install the Japanese Language Analyzer? Enter Y for yes or N for no then hit enter."
#read   japanese
#if [[ ("$japanese" == "Y") || ("$japanese" == "y") ]]; then
#    bin/plugin —-install —-url https://github.com/suguru/elasticsearch-analysis-japanese/1.1.0
#else 
#    echo “See https://github.com/suguru/elasticsearch-analysis-japanese for more info about the Japanese Analyzer”
#fi

#echo "Would you like to install the MMSEG Analyzer? Enter Y for yes or N for no then hit enter."
#read   mmseg
#if [[ ("$mmseg" == "Y") || ("$mmseg" == "y") ]]; then
#    bin/plugin —-install —-url https://github.com/medcl/elasticsearch-rtf/tree/master/plugins/analysis-mmseg
#else     
#    echo “See https://github.com/medcl/elasticsearch-analysis-mmseg for more info about the MMSEG Analyzer”
#fi

#echo "Would you like to install the User contributed Polish Language Analyzer? Enter Y for yes or N for no then hit enter."
#read   polish2
#if [[ ("$polish2" == "Y") || ("$polish2" == "y") ]]; then
#    bin/plugin —-install com.github.chytreg/elasticsearch-analysis-morfologik/2.3.1
#else
#    echo “See https://github.com/chytreg/elasticsearch-analysis-morfologik for more info about the Polish Analyzer”
#fi

echo "Would you like to install the Russian/English Morphological Analyzer? Enter Y for yes or N for no then hit enter."
read   morphology
if [[ ("$morphology" == "Y") || ("$morphology" == "y") ]]; then
    bin/plugin --install analysis-morphology --url http://dl.bintray.com/content/imotov/elasticsearch-plugins/org/elasticsearch/elasticsearch-analysis-morphology/1.2.0/elasticsearch-analysis-morphology-1.2.0.zip
else 
    echo “See https://github.com/imotov/elasticsearch-analysis-morphology for more info about the Russian/English Morphological Analyzer”
fi

echo "Would you like to install the Hebrew Language Analyzer? Enter Y for yes or N for no then hit enter."
read   hebrew
if [[ ("$hebrew" == "Y") || ("$hebrew" == "y") ]]; then
    bin/plugin --install analysis-hebrew --url https://bintray.com/artifact/download/synhershko/elasticsearch-analysis-hebrew/elasticsearch-analysis-hebrew-1.7.zip
else    
    echo “See https://github.com/synhershko/elasticsearch-analysis-hebrew for more info about the Hebrew Analyzer”
fi

#echo "Would you like to install the Pinyin Analyzer? Enter Y for yes or N for no then hit enter."
#read   pinyin
#if [[ ("$pinyin" == "Y") || ("$pinyin" == "y") ]]; then
#    bin/plugin —-install —-url https://github.com/medcl/elasticsearch-analysis-pinyin
#else 
#    echo “See https://github.com/medcl/elasticsearch-analysis-pinyin for more info about the Pinyin Analyzer”
#fi

#echo "Would you like to install the String to Integer Analyzer? Enter Y for yes or N for no then hit enter."
#read   strtoint
#if [[ ("$strtoint" == "Y") || ("$strtoint" == "y") ]]; then
#    bin/plugin —-install —-url https://github.com/medcl/elasticsearch-analysis-string2int
#else
#    echo “See https://github.com/medcl/elasticsearch-analysis-string2int for more info about the String to Integer Analyzer” 
#fi

echo "Would you like to install the Vietnamese Language Analyzer? Enter Y for yes or N for no then hit enter."
read   vietnamese
if [[ ("$vietnamese" == "Y") || ("$vietnamese" == "y") ]]; then
    bin/plugin --install analysis-vietnamese --url https://dl.dropboxusercontent.com/u/1598491/elasticsearch-analysis-vietnamese-0.1.zip
else
    echo “See https://github.com/duydo/elasticsearch-analysis-vietnamese for more info about the Vietnamese Analyzer”
fi

################################################################################
#####################  Discovery Plugins #######################################
################################################################################

################################################################################
##################### Officially Supported Plugins #############################
################################################################################

#echo "Would you like to install the AWS Discovery Plugin? Enter Y for yes or N for no then hit enter."
#read   awsdiscover
#if [[ ("$awsdiscover" == "Y") || ("$awsdiscover" == "y") ]]; then
#    bin/plugin —-install elasticsearch/elasticsearch-cloud-aws/2.5.1
#else
#    echo “See https://github.com/elasticsearch/elasticsearch-cloud-aws for more info about the AWS Discovery Plugin“ 
#fi

#echo "Would you like to install the Azure Discovery Plugin? Enter Y for yes or N for no then hit enter."
#read   azure
#if [[ ("$azure" == "Y") || ("$azure" == "y") ]]; then
#    bin/plugin —-install elasticsearch/elasticsearch-cloud-azure/2.6.1
#else
#    echo “See https://github.com/elasticsearch/elasticsearch-cloud-azure for more info about the Azure Discovery Plugin“ 
#fi

#echo "Would you like to install the Google Compute Discovery Plugin? Enter Y for yes or N for no then hit enter."
#read   googlecompute
#if [[ ("$googlecompute" == "Y") || ("$googlecompute" == "y") ]]; then
#    bin/plugin —-install elasticsearch/elasticsearch-cloud-gce/2.5.0
#else
#    echo “See https://github.com/elasticsearch/elasticsearch-cloud-gce for more info about the Google Compute Discovery Plugin“ 
#fi

################################################################################
#####################  Community Supported Plugins #############################
################################################################################

#echo "Would you like to install the ESKKA Discovery Plugin? Enter Y for yes or N for no then hit enter."
#read   eskka
#if [[ ("$eskka" == "Y") || ("$eskka" == "y") ]]; then
#    bin/plugin —-install eskka —-url https://eskka.s3.amazonaws.com/eskka-0.13.0.zip
#else    
#    echo “See https://github.com/shikhar/eskka for more info about the ESKKA Discovery Plugin“ 
#fi

#echo "Would you like to install the DNS/SRV Discovery Plugin? Enter Y for yes or N for no then hit enter."
#read   dnssrv
#if [[ ("$dnssrv" == "Y") || ("$dnssrv" == "y") ]]; then
#    bin/plugin --install srv-discovery --url https://github.com/grantr/elasticsearch-srv-discovery
#else
#    echo “See https://github.com/grantr/elasticsearch-srv-discovery for more info about the DNS/SRV Discovery Plugin“ 
#fi

################################################################################
##################### 		River Plugins	 ################################
################################################################################

echo "Elasticsearch has announced they have deprecated the use of Rivers moving forward;  But they will likely remain supported through at least the next major release to aid in the migration/transition process.  See https://www.elastic.co/blog/deprecating_rivers for additional information"

################################################################################
##################### 	Transport Plugins ###################################
################################################################################

################################################################################
##################### Officially Supported Plugins #############################
################################################################################

echo "See https://github.com/elasticsearch/elasticsearch-transport-wares for more information about the Servlet transport"
echo "Add the following lines to your servlet's POM.XML/Maven Dependency List"
echo "<dependency>"
echo "    <groupId>org.elasticsearch</groupId>"
echo "    <artifactId>elasticsearch-transport-wares</artifactId>"
echo "    <version>2.5.0</version>"
echo "</dependency>"

################################################################################
#####################  Community Supported Plugins #############################
################################################################################

#echo "Would you like to install the ZeroMQ Transport Layer Plugin? Enter Y for yes or N for no then hit enter."
#read   transzeromq
#if [[ ("$transzeromq" == "Y") || ("$transzeromq" == "y") ]]; then
#    bin/plugin --install --url https://github.com/tlrx/transport-zeromq
#else
#    echo "See https://github.com/tlrx/transport-zeromq for more information about the ZeroMQ transport layer plugin"
#fi

echo "Would you like to install the Jetty Transport Layer Plugin? Enter Y for yes or N for no then hit enter."
read   transjetty
if [[ ("$transjetty" == "Y") || ("$transjetty" == "y") ]]; then
    bin/plugin --install elasticsearch-jetty-1.2.1 --url https://oss-es-plugins.s3.amazonaws.com/elasticsearch-jetty/elasticsearch-jetty-1.2.1.zip 
else
    echo "See https://github.com/sonian/elasticsearch-jetty for more information about the Jetty HTTP transport plugin"
fi

echo "Would you like to install the Redis Transport Layer Plugin? Enter Y for yes or N for no then hit enter."
read   transredis
if [[ ("$transredis" == "Y") || ("$transredis" == "y") ]]; then
    bin/plugin --install com.github.kzwang/elasticsearch-transport-redis/2.0.0
else
    echo "See https://github.com/kzwang/elasticsearch-transport-redis for more information about the Redis transport plugin"
fi

################################################################################
##################### 		Scripting Plugins	########################
################################################################################

################################################################################
##################### Officially Supported Plugins #############################
################################################################################

#echo "Would you like to install the Clojure Scripting Plugin? Enter Y for yes or N for no then hit enter."
#read   clojure 
#if [[ ("$clojure" == "Y") || ("$clojure" == "y") ]]; then
#    bin/plugin --install --url https://github.com/hiredman/elasticsearch-lang-clojure
#else
#    echo "See https://github.com/hiredman/elasticsearch-lang-clojure for more information about the Clojure Language Plugin"
#fi

echo "Would you like to install the Groovy Scripting Plugin? Enter Y for yes or N for no then hit enter."
read   groovy
if [[ ("$groovy" == "Y") || ("$groovy" == "y") ]]; then
    bin/plugin --install elasticsearch/elasticsearch-lang-groovy/2.0.0
else
    echo "See https://github.com/elasticsearch/elasticsearch-lang-groovy for more information about the Groovy lang Plugin"
fi

echo "Would you like to install the JavaScript Scripting Plugin? Enter Y for yes or N for no then hit enter."
read   javascript
if [[ ("$javascript" == "Y") || ("$javascript" == "y") ]]; then
    bin/plugin --install elasticsearch/elasticsearch-lang-javascript/2.5.0
else
    echo "See https://github.com/elasticsearch/elasticsearch-lang-javascript for more information about the JavaScript language Plugin"
fi

echo "Would you like to install the Python Scripting Plugin? Enter Y for yes or N for no then hit enter."
read   python
if [[ ("$python" == "Y") || ("$python" == "y") ]]; then
    bin/plugin --install elasticsearch/elasticsearch-lang-python/2.5.0
else
    echo "See https://github.com/elasticsearch/elasticsearch-lang-python for more information about the Python language Plugin"
fi

echo "Would you like to install the SQL Scripting Plugin? Enter Y for yes or N for no then hit enter."
read   sql
if [[ ("$sql" == "Y") || ("$sql" == "y") ]]; then
    bin/plugin --install sql --url https://github.com/NLPchina/elasticsearch-sql/releases/download/1.3.3/elasticsearch-sql-1.3.3.zip 
else
    echo "See https://github.com/NLPchina/elasticsearch-sql/ for more information about the SQL language Plugin"
fi

################################################################################
#####################    Site Plugins	        	########################
################################################################################

################################################################################
##################### Officially Supported Plugins #############################
################################################################################

echo "Would you like to install the Big Desk Site Plugin? Enter Y for yes or N for no then hit enter."
read   bigdesk
if [[ ("$bigdesk" == "Y") || ("$bigdesk" == "y") ]]; then
    bin/plugin --install lukas-vlcek/bigdesk/2.5.0
else
    echo "See https://github.com/lukas-vlcek/bigdesk for more information about the BigDesk Plugin"
fi

echo "Would you like to install the Elasticsearch Head Site Plugin? Enter Y for yes or N for no then hit enter."
read   eshead
if [[ ("$eshead" == "Y") || ("$eshead" == "y") ]]; then
    bin/plugin --install mobz/elasticsearch-head
else
    echo "See https://github.com/mobz/elasticsearch-head for more information about the Elasticsearch Head Plugin"
fi

#echo "Would you like to install the Elasticsearch HQ Site Plugin? Enter Y for yes or N for no then hit enter."
#read   eshq
#if [[ ("$eshq" == "Y") || ("$eshq" == "y") ]]; then
#    bin/plugin --install --url https://github.com/royrusso/elasticsearch-HQ
#else
#    echo "See https://github.com/royrusso/elasticsearch-HQ for more information about the Elasticsearch HQ"
#fi

#echo "Would you like to install the Elasticsearch Hammer Site Plugin? Enter Y for yes or N for no then hit enter."
#read   eshammer
#if [[ ("$eshammer" == "Y") || ("$eshammer" == "y") ]]; then
#    bin/plugin --install --url https://github.com/andrewvc/elastic-hammer
#else
#    echo "See https://github.com/andrewvc/elastic-hammer for more information about the Hammer Plugin"
#fi

echo "Would you like to install the Elasticsearch Inquisitor Site Plugin? Enter Y for yes or N for no then hit enter."
read   esinquisitor
if [[ ("$esinquisitor" == "Y") || ("$esinquisitor" == "y") ]]; then
    bin/plugin --install polyfractal/elasticsearch-inquisitor
else
    echo "See https://github.com/polyfractal/elasticsearch-inquisitor for more information about the Inquisitor Plugin"
fi

#echo "Would you like to install the Elasticsearch Paramedic Site Plugin? Enter Y for yes or N for no then hit enter."
#read   esparamedic
#if [[ ("$esparamedic" == "Y") || ("$esparamedic" == "y") ]]; then
#    bin/plugin --install --url https://github.com/karmi/elasticsearch-paramedic
#else
#    echo "See https://github.com/karmi/elasticsearch-paramedic for more information about the Paramedic Plugin"
#fi

echo "Would you like to install the Elasticsearch SegmentSpy Site Plugin? Enter Y for yes or N for no then hit enter."
read   segspy
if [[ ("$segspy" == "Y") || ("$segspy" == "y") ]]; then
    bin/plugin --install polyfractal/elasticsearch-segmentspy
else
    echo "See https://github.com/polyfractal/elasticsearch-segmentspy for more information about the SegmentSpy Plugin"
fi

echo "Would you like to install the Elasticsearch Whatson Site Plugin? Enter Y for yes or N for no then hit enter."
read   whatson
if [[ ("$whatson" == "Y") || ("$whatson" == "y") ]]; then
    bin/plugin --install xyu/elasticsearch-whatson/0.1.3
else
    echo "See https://github.com/xyu/elasticsearch-whatson for more information about the Whatson Plugin"
fi

################################################################################
#################	Snapshot/Restore Plugins       	  #####################
################################################################################

################################################################################
##################### Officially Supported Plugins #############################
################################################################################

echo "Would you like to install the HDFS Repository Plugin? Enter Y for yes or N for no then hit enter."
read   hdfsrepo
if [[ ("$hdfsrepo" == "Y") || ("$hdfsrepo" == "y") ]]; then
    bin/plugin --install elasticsearch/elasticsearch-repository-hdfs/2.0.2
else
    echo "See https://github.com/elasticsearch/elasticsearch-hadoop/tree/master/repository-hdfs for more information about the Hadoop HDFS Repository Plugin"
fi

echo "Would you like to install the AWS S3 Repository Plugin? Enter Y for yes or N for no then hit enter."
read   awsrepo
if [[ ("$awsrepo" == "Y") || ("$awsrepo" == "y") ]]; then
    bin/plugin --install elasticsearch/elasticsearch-cloud-aws/2.5.1
else
    echo "See https://github.com/elasticsearch/elasticsearch-cloud-aws#s3-repository for more information about the AWS S3 Repository Plugin"
fi

################################################################################
#####################  Community Supported Plugins #############################
################################################################################

echo "Would you like to install the GridFS Repository Plugin? Enter Y for yes or N for no then hit enter."
read   gridfs
if [[ ("$gridfs" == "Y") || ("$gridfs" == "y") ]]; then
    bin/plugin --install com.github.kzwang/elasticsearch-repository-gridfs/1.0.0
else
    echo "See https://github.com/kzwang/elasticsearch-repository-gridfs for more information about the GridFS Repository"
fi

echo "Would you like to install the Openstack Swift Plugin? Enter Y for yes or N for no then hit enter."
read   openstack
if [[ ("$openstack" == "Y") || ("$openstack" == "y") ]]; then
    bin/plugin --install org.wikimedia.elasticsearch.swift/swift-repository-plugin/0.7
else
    echo "See https://github.com/wikimedia/search-repository-swift for more information about the Openstack Swift"
fi


################################################################################
#####################	      	Miscellaneous Plugins 	  ###################
################################################################################

################################################################################
##################### Officially Supported Plugins #############################
################################################################################

echo "Would you like to install the Mapper Attachments Type Plugin? Enter Y for yes or N for no then hit enter."
read   mapper
if [[ ("$mapper" == "Y") || ("$mapper" == "y") ]]; then
    bin/plugin --install elasticsearch/elasticsearch-mapper-attachments/2.5.0
else
    echo "See https://github.com/elasticsearch/elasticsearch-mapper-attachments for more information about the Mapper Attachments Type plugin"
fi

################################################################################
#####################  Community Supported Plugins #############################
################################################################################

echo "Would you like to install the Carrot Plugin? Enter Y for yes or N for no then hit enter."
read   carrot
if [[ ("$carrot" == "Y") || ("$carrot" == "y") ]]; then
    bin/plugin --install org.carrot2/elasticsearch-carrot2/1.8.0
else
    echo "See https://github.com/carrot2/elasticsearch-carrot2 for more information about the carrot2 Plugin"
fi

#echo "Would you like to install the Elasticsearch Changes Plugin? Enter Y for yes or N for no then hit enter."
#read   eschanges
#if [[ ("$eschanges" == "Y") || ("$eschanges" == "y") ]]; then
#    bin/plugin --install derryx/elasticsearch-changes-plugin
#else
#    echo "See https://github.com/derryx/elasticsearch-changes-plugin for more information about the Elasticsearch Changes Plugin"
#fi

echo "Would you like to install the Extended Analyze Plugin? Enter Y for yes or N for no then hit enter."
read   xtndanalyze
if [[ ("$xtndanalyze" == "Y") || ("$xtndanalyze" == "y") ]]; then
    bin/plugin --install info.johtani/elasticsearch-extended-analyze/1.5.2
else
    echo "See https://github.com/johtani/elasticsearch-extended-analyze for more information about the Extended Analyze Plugin"
fi

#echo "Would you like to install the Entity Resolution Plugin? Enter Y for yes or N for no then hit enter."
#read   entres
#if [[ ("$entres" == "Y") || ("$entres" == "y") ]]; then
#    bin/plugin --install entity-resolution --url http://dl.bintray.com/yann-barraud/elasticsearch-entity-resolution/org/yaba/elasticsearch-entity-resolution-plugin/1.4.0.0/#elasticsearch-entity-resolution-plugin-1.4.0.0.jar
#else
#    echo "See https://github.com/YannBrrd/elasticsearch-entity-resolution for more information about the Entity Resolution Plugin" 
#fi

echo "Would you like to install the Graphite Plugin? Enter Y for yes or N for no then hit enter."
read   graphite
if [[ ("$graphite" == "Y") || ("$graphite" == "y") ]]; then
    git clone https://github.com/spinscale/elasticsearch-graphite-plugin
    mvn elasticsearch-graphite-plugin/package && mv elasticsearch-graphite-plugin /usr/share/elasticsearch/plugins/elasticsearch-graphite-plugin
    bin/plugin --install graphite --url /usr/share/elasticsearch/plugins/elasticsearch-graphite-plugin
else
    echo "See https://github.com/spinscale/elasticsearch-graphite-plugin for more information about the Elasticsearch Graphite Plugin"
fi

#echo "Would you like to install the Statsd Plugin? Enter Y for yes or N for no then hit enter."
#read   statsd
#if [[ ("$statsd" == "Y") || ("$statsd" == "y") ]]; then
#    git clone http://github.com/swoop-inc/elasticsearch-statsd-plugin.git
#    mvn elasticsearch-statsd-plugin/package && mv elasticsearch-statsd-plugin /usr/share/elasticsearch/plugins/elasticsearch-statsd-plugin
#    bin/plugin --install statsd --url file:///usr/share/elasticsearch/plugins/elasticsearch-statsd-plugin
#else
#    echo "See https://github.com/swoop-inc/elasticsearch-statsd-plugin for more information about the Elasticsearch Statsd Plugin"
#fi

echo "Would you like to install the Elasticsearch View Plugin? Enter Y for yes or N for no then hit enter."
read   esview
if [[ ("$esview" == "Y") || ("$esview" == "y") ]]; then
    bin/plugin --install view-plugin --url https://oss.sonatype.org/content/repositories/releases/com/github/tlrx/elasticsearch-view-plugin/0.0.2/elasticsearch-view-plugin-0.0.2-zip.zip 
else
    echo "See http://tlrx.github.com/elasticsearch-view-plugin for more information about the Elasticsearch View Plugin"
fi

echo "Would you like to install the Zookeeper Plugin? Enter Y for yes or N for no then hit enter."
read   zookeeper
if [[ ("$zookeeper" == "Y") || ("$zookeeper" == "y") ]]; then
    bin/plugin --install zookeeper --url https://github.com/grmblfrz/elasticsearch-zookeeper/releases/download/v1.4.1/elasticsearch-zookeeper-1.4.1.zip
else
    echo "See https://github.com/sonian/elasticsearch-zookeeper for more information about the ZooKeeper Discovery Plugin"
fi 

echo "Would you like to install the Elasticsearch Image Plugin? Enter Y for yes or N for no then hit enter."
read   image
if [[ ("$image" == "Y") || ("$image" == "y") ]]; then
    bin/plugin --install com.github.kzwang/elasticsearch-image/1.2.0
else
    echo "See https://github.com/kzwang/elasticsearch-image for more information about the Elasticsearch Image Plugin"
fi

echo "Would you like to install the Elasticsearch Experimental Highlighter? Enter Y for yes or N for no then hit enter."
read   highlight
if [[ ("$highlight" == "Y") || ("$highlight" == "y") ]]; then
    bin/plugin --install org.wikimedia.search.highlighter/experimental-highlighter-elasticsearch-plugin/1.5.0
else
    echo "See https://github.com/wikimedia/search-highlighter for more information about the Elasticsearch Experimental Highlighter"
fi

#echo "Would you like to install the Elasticsearch Security Plugin? Enter Y for yes or N for no then hit enter."
#read   security
#if [[ ("$security" == "Y") || ("$security" == "y") ]]; then
#    bin/plugin --install elasticsearch-security-plugin-0.0.2.Beta2 --url https://github.com/salyh/elasticsearch-security-plugin
#else
#    echo "See https://github.com/salyh/elasticsearch-security-plugin for more information about the Elasticsearch Security Plugin#"
#fi

echo "Would you like to install the Elasticsearch Taste Plugin? Enter Y for yes or N for no then hit enter."
read   taste
if [[ ("$taste" == "Y") || ("$taste" == "y") ]]; then
    bin/plugin --install org.codelibs/elasticsearch-taste/1.5.0
else
    echo "See https://github.com/codelibs/elasticsearch-taste for more information about the Elasticsearch Taste Plugin"
fi

echo "Would you like to install the Elasticsearch SIREn Plugin? Enter Y for yes or N for no then hit enter."
read  siren
if [[ ("$siren" == "Y") || ("$siren" == "y") ]]; then
    bin/plugin --install com.sindicetech.siren/siren-elasticsearch/1.4
else
    echo "See http://siren.solutions/siren/downloads/ for more information about the Elasticsearch SIREn Plugin"
fi

###############
# Start up the elasticsearch server
###############

# Move back into main installation directory
cd ../


# Now spin up the elasticsearch server
elasticsearch/bin/elasticsearch -d &

# This will print the configuration file I set up to pipe the output from R into
# Logstash and should save it to a file in the logstash directory
echo 'input {
tcp {
mode => "server"
host => "192.168.1.1"
port => 6983
codec => "json"
}
}
filter {
json {
source => "message"
}
}
output {
elasticsearch {
embedded => false
host => "127.0.0.1"
port => "9300"
protocol => "node"
}
}' >> logstash/injson-outelasticsearch.conf

echo "The next command prints all installed Logstash plugins to the console for your convenience."

# Print all of the codecs installed in with logstash
logstash/bin/plugin list

echo "Will attempt updating the logstash plugins"
logstash/bin/plugin upgrade

# Let the user know these are the commands to install the codecs
echo "cd into /usr/share and then use the commands below to install different logstash codecs"

# Install logstash codecs
echo "logstash/bin/plugin install logstash-codec-compress_spooler"
echo "logstash/bin/plugin install logstash-codec-cloudtrail"
echo "logstash/bin/plugin install logstash-codec-cloudfront"
echo "logstash/bin/plugin install logstash-codec-collectd"
echo "logstash/bin/plugin install logstash-codec-dots"
echo "logstash/bin/plugin install logstash-codec-edn_lines"
echo "logstash/bin/plugin install logstash-codec-edn"
echo "logstash/bin/plugin install logstash-codec-es_bulk"
echo "logstash/bin/plugin install logstash-codec-fluent"
echo "logstash/bin/plugin install logstash-codec-gzip_line"
echo "logstash/bin/plugin install logstash-codec-graphite"
echo "logstash/bin/plugin install logstash-codec-json_lines"
echo "logstash/bin/plugin install logstash-codec-json"
echo "logstash/bin/plugin install logstash-codec-line"
echo "logstash/bin/plugin install logstash-codec-msgpack"
echo "logstash/bin/plugin install logstash-codec-multiline"
echo "logstash/bin/plugin install logstash-codec-netflow"
echo "logstash/bin/plugin install logstash-codec-oldlogstashjson"
echo "logstash/bin/plugin install logstash-codec-plain"
echo "logstash/bin/plugin install logstash-codec-rubydebug"
echo "logstash/bin/plugin install logstash-codec-s3_plain"
echo "logstash/bin/plugin install logstash-codec-spool"

# Let the user know these are the commands to install the inputs
echo "cd into /usr/share and then use the commands below to install different logstash input types"

# Install logstash input plugins
echo "logstash/bin/plugin install logstash-input-couchdb_changes"
echo "logstash/bin/plugin install logstash-input-drupal_dblog"
echo "logstash/bin/plugin install logstash-input-elasticsearch"
echo "logstash/bin/plugin install logstash-input-exec"
echo "logstash/bin/plugin install logstash-input-eventlog"
echo "logstash/bin/plugin install logstash-input-file"
echo "logstash/bin/plugin install logstash-input-ganglia"
echo "logstash/bin/plugin install logstash-input-gelf"
echo "logstash/bin/plugin install logstash-input-generator"
echo "logstash/bin/plugin install logstash-input-graphite"
echo "logstash/bin/plugin install logstash-input-github"
echo "logstash/bin/plugin install logstash-input-heartbeat"
echo "logstash/bin/plugin install logstash-input-heroku"
echo "logstash/bin/plugin install logstash-input-irc"
echo "logstash/bin/plugin install logstash-input-imap"
echo "logstash/bin/plugin install logstash-input-jmx"
echo "logstash/bin/plugin install logstash-input-kafka"
echo "logstash/bin/plugin install logstash-input-log4j"
echo "logstash/bin/plugin install logstash-input-lumberjack"
echo "logstash/bin/plugin install logstash-input-meetup"
echo "logstash/bin/plugin install logstash-input-pipe"
echo "logstash/bin/plugin install logstash-input-puppet_facter"
echo "logstash/bin/plugin install logstash-input-relp"
echo "logstash/bin/plugin install logstash-input-rss"
echo "logstash/bin/plugin install logstash-input-rackspace"
echo "logstash/bin/plugin install logstash-input-rabbitmq"
echo "logstash/bin/plugin install logstash-input-redis"
echo "logstash/bin/plugin install logstash-input-snmptrap"
echo "logstash/bin/plugin install logstash-input-stdin"
echo "logstash/bin/plugin install logstash-input-sqlite"
echo "logstash/bin/plugin install logstash-input-s3"
echo "logstash/bin/plugin install logstash-input-sqs"
echo "logstash/bin/plugin install logstash-input-stomp"
echo "logstash/bin/plugin install logstash-input-syslog"
echo "logstash/bin/plugin install logstash-input-tcp"
echo "logstash/bin/plugin install logstash-input-twitter"
echo "logstash/bin/plugin install logstash-input-unix"
echo "logstash/bin/plugin install logstash-input-udp"
echo "logstash/bin/plugin install logstash-input-varnishlog"
echo "logstash/bin/plugin install logstash-input-wmi"
echo "logstash/bin/plugin install logstash-input-websocket"
echo "logstash/bin/plugin install logstash-input-xmpp"
echo "logstash/bin/plugin install logstash-input-zenoss"
echo "logstash/bin/plugin install logstash-input-zeromq"

# Let the user know these are the commands to install the filters
echo "cd into /usr/share and then use the commands below to install different logstash filter (parser) plugins"

# Install logstash filter plugins
echo "logstash/bin/plugin install logstash-filter-alter"
echo "logstash/bin/plugin install logstash-filter-anonymize"
echo "logstash/bin/plugin install logstash-filter-collate"
echo "logstash/bin/plugin install logstash-filter-csv"
echo "logstash/bin/plugin install logstash-filter-cidr"
echo "logstash/bin/plugin install logstash-filter-clone"
echo "logstash/bin/plugin install logstash-filter-cipher"
echo "logstash/bin/plugin install logstash-filter-checksum"
echo "logstash/bin/plugin install logstash-filter-date"
echo "logstash/bin/plugin install logstash-filter-dns"
echo "logstash/bin/plugin install logstash-filter-drop"
echo "logstash/bin/plugin install logstash-filter-elasticsearch"
echo "logstash/bin/plugin install logstash-filter-extractnumbers"
echo "logstash/bin/plugin install logstash-filter-environment"
echo "logstash/bin/plugin install logstash-filter-elapsed"
echo "logstash/bin/plugin install logstash-filter-fingerprint"
echo "logstash/bin/plugin install logstash-filter-geoip"
echo "logstash/bin/plugin install logstash-filter-grok"
echo "logstash/bin/plugin install logstash-filter-i18n"
echo "logstash/bin/plugin install logstash-filter-json"
echo "logstash/bin/plugin install logstash-filter-json_encode"
echo "logstash/bin/plugin install logstash-filter-kv"
echo "logstash/bin/plugin install logstash-filter-mutate"
echo "logstash/bin/plugin install logstash-filter-metrics"
echo "logstash/bin/plugin install logstash-filter-multiline"
echo "logstash/bin/plugin install logstash-filter-metaevent"
echo "logstash/bin/plugin install logstash-filter-prune"
echo "logstash/bin/plugin install logstash-filter-punct"
echo "logstash/bin/plugin install logstash-filter-ruby"
echo "logstash/bin/plugin install logstash-filter-range"
echo "logstash/bin/plugin install logstash-filter-syslog_pri"
echo "logstash/bin/plugin install logstash-filter-sleep"
echo "logstash/bin/plugin install logstash-filter-split"
echo "logstash/bin/plugin install logstash-filter-throttle"
echo "logstash/bin/plugin install logstash-filter-translate"
echo "logstash/bin/plugin install logstash-filter-uuid"
echo "logstash/bin/plugin install logstash-filter-urldecode"
echo "logstash/bin/plugin install logstash-filter-useragent"
echo "logstash/bin/plugin install logstash-filter-xml"
echo "logstash/bin/plugin install logstash-filter-zeromq"

# Let the user know these are the commands to install the output types
echo "cd into /usr/share and then use the commands below to install different logstash output plugins"

# Install logstash output plugins
echo "logstash/bin/plugin install logstash-output-boundary"
echo "logstash/bin/plugin install logstash-output-circonus"
echo "logstash/bin/plugin install logstash-output-csv"
echo "logstash/bin/plugin install logstash-output-cloudwatch"
echo "logstash/bin/plugin install logstash-output-datadog"
echo "logstash/bin/plugin install logstash-output-datadog_metrics"
echo "logstash/bin/plugin install logstash-output-email"
echo "logstash/bin/plugin install logstash-output-elasticsearch"
echo "logstash/bin/plugin install logstash-output-exec"
echo "logstash/bin/plugin install logstash-output-file"
echo "logstash/bin/plugin install logstash-output-google_bigquery"
echo "logstash/bin/plugin install logstash-output-google_cloud_storage"
echo "logstash/bin/plugin install logstash-output-ganglia"
echo "logstash/bin/plugin install logstash-output-gelf"
echo "logstash/bin/plugin install logstash-output-graphtastic"
echo "logstash/bin/plugin install logstash-output-graphite"
echo "logstash/bin/plugin install logstash-output-hipchat"
echo "logstash/bin/plugin install logstash-output-http"
echo "logstash/bin/plugin install logstash-output-irc"
echo "logstash/bin/plugin install logstash-output-influxdb"
echo "logstash/bin/plugin install logstash-output-juggernaut"
echo "logstash/bin/plugin install logstash-output-jira"
echo "logstash/bin/plugin install logstash-output-kafka"
echo "logstash/bin/plugin install logstash-output-lumberjack"
echo "logstash/bin/plugin install logstash-output-librato"
echo "logstash/bin/plugin install logstash-output-loggly"
echo "logstash/bin/plugin install logstash-output-mongodb"
echo "logstash/bin/plugin install logstash-output-metriccatcher"
echo "logstash/bin/plugin install logstash-output-nagios"
echo "logstash/bin/plugin install logstash-output-null"
echo "logstash/bin/plugin install logstash-output-nagios_nsca"
echo "logstash/bin/plugin install logstash-output-opentsdb"
echo "logstash/bin/plugin install logstash-output-pagerduty"
echo "logstash/bin/plugin install logstash-output-pipe"
echo "logstash/bin/plugin install logstash-output-riemann"
echo "logstash/bin/plugin install logstash-output-redmine"
echo "logstash/bin/plugin install logstash-output-rackspace"
echo "logstash/bin/plugin install logstash-output-rabbitmq"
echo "logstash/bin/plugin install logstash-output-redis"
echo "logstash/bin/plugin install logstash-output-riak"
echo "logstash/bin/plugin install logstash-output-s3"
echo "logstash/bin/plugin install logstash-output-sqs"
echo "logstash/bin/plugin install logstash-output-stomp"
echo "logstash/bin/plugin install logstash-output-statsd"
echo "logstash/bin/plugin install logstash-output-solr_http"
echo "logstash/bin/plugin install logstash-output-sns"
echo "logstash/bin/plugin install logstash-output-syslog"
echo "logstash/bin/plugin install logstash-output-stdout"
echo "logstash/bin/plugin install logstash-output-tcp"
echo "logstash/bin/plugin install logstash-output-udp"
echo "logstash/bin/plugin install logstash-output-websocket"
echo "logstash/bin/plugin install logstash-output-xmpp"
echo "logstash/bin/plugin install logstash-output-zabbix"
echo "logstash/bin/plugin install logstash-output-zeromq"

# Start up logstash
#logstash/bin/logstash agent -f logstash/injson-outelasticsearch.conf &

echo "To start logstash, use the command:"
echo "/usr/share/logstash/bin/logstash -f [config file path/name] & "
echo "Substituting [config file path/name] for the name of your logstash configuration file"


# Now start up Kibana
kibana/bin/kibana -q &

# Move to root binary directory
cd /usr/bin

rmsymlinks=`ls | grep "elasticsearch|logstash|kibana"`

for todelete in $rmsymlinks; 
do
   rm $todelete
done    

# Then give yourself ownership/permissions on these directories
# On OSX if your username is billy and you have admin permissions it might look like
chown -R $theuser /usr/share/{elasticsearch,logstash,kibana}

# Give read/write/execute permissions to anyone with access to this system
chmod -R a+rwx /usr/share/{elasticsearch,logstash,kibana}

# Create commands to launch
ln -s /usr/share/elasticsearchbin/elasticsearch /usr/bin/elasticsearch
ln -s /usr/share/logstash/bin/logstash /usr/bin/logstash
ln -s /usr/share/kibana/bin/kibana /usr/bin/kibana

# Send message to user
echo "Symlinks for the ELK stack binaries have been added to /usr/bin/ so you can start programs from the command line more easily"
echo "As an alternative, you could add the directories /usr/share/elasticsearch, /usr/share/logstash, and /usr/share/kibana to your path environmental variable to have greater control and flexibility"

