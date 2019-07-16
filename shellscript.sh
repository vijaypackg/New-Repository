# Install Jenkins
## Before install is necessary to add Jenkins to trusted keys and source list
wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update
sudo apt-get install jenkins

# Install and Configure Mysql to Jenkins
## Install the necessary packages (I used password: root)
sudo apt-get install mysql-client libmysqlclient-dev mysql-server

## Add user to jenkins
## You can check if user was created using: SELECT User FROM mysql.user;
mysql --user=root --password=root -e \
  "CREATE USER 'jenkins'@'localhost' IDENTIFIED BY 'jenkins';
   GRANT ALL PRIVILEGES ON * . * TO 'jenkins'@'localhost';
   FLUSH PRIVILEGES;\q"
   
   --------------------------
   
   if [ "$SUBSTR" == "CentOS Linux release 7" ]
then
    isCentOs7=true
fi

if [ "$isCentOs7" == true ]
then
    echo "I am CentOS 7"
fi

CWD=`pwd`
-----------------------

# Let's make sure that yum-presto is installed:
sudo yum install -y yum-presto

# Let's make sure that mlocate (locate command) is installed as it makes much easier when searching in Linux:
sudo yum install -y mlocate

# Although not needed for Jenkins, I like to use vim, so let's make sure it is installed:
sudo yum install -y vim

# The Jenkins setup makes use of wget, so let's make sure it is installed:
sudo yum install -y wget

# Let's make sure that openssl is installed:
sudo yum install -y openssl

# Let's make sure that curl is installed:
sudo yum install -y curl

# Jenkins on CentOS requires Java, but it won't work with the default (GCJ) version of Java. So, let's remove it:
sudo yum remove -y java

# install the OpenJDK version of Java 7:
sudo yum install -y java-1.7.0-openjdk

# Let's start Jenkins
if [ "$isCentOs7" == true ]
then
    sudo systemctl start jenkins
else 
    sudo service jenkins start
fi

# Jenkins runs on port 8080 by default. Let's make sure port 8080 is open:
if [ "$isCentOs7" == true ]
then
    sudo firewall-cmd --zone=public --add-port=8080/tcp --permanent
    sudo firewall-cmd --reload
else
    sudo iptables -A INPUT -p tcp -m tcp --dport 8080 -j ACCEPT
    sudo service iptables save
    sudo service iptables restart
fi
------------

# Let's make sure that git is installed since Jenkins will need this
sudo yum install -y git

# Install phpDox, which is needed by Jenkins.
# https://github.com/theseer/phpdox
sudo wget -N http://phpdox.de/releases/phpdox.phar
sudo chmod +x phpdox.phar
sudo mv phpdox.phar /usr/bin/phpdox


# Install 'composer':
sudo curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/bin --filename=composer

# Now that composer is installed, let's install PHPUnit and its associated packages:
sudo composer global require "phpunit/phpunit=4.3.*"
sudo composer global require "phpunit/php-invoker"
sudo composer global require "phpunit/dbunit": ">=1.2"
sudo composer global require "phpunit/phpunit-selenium": ">=1.2"

# PHP CodeSniffer:
sudo composer global require "squizlabs/php_codesniffer"

sudo composer update

# We need to increase the memory limit used by PHP:
sudo sed -i 's/memory_limit = 128M/memory_limit = 2048M/g' /etc/php.ini

# Let's update Jenkins to use the PHP tools that we had installed with Composer:
sudo curl -L http://updates.jenkins-ci.org/update-center.json | sed '1d;$d' | curl -X POST -H 'Accept: application/json' -d @- http://localhost:8080/updateCenter/byId/default/postBack

sudo wget -N http://localhost:8080/jnlpJars/jenkins-cli.jar

sudo java -jar jenkins-cli.jar -s http://localhost:8080 install-plugin checkstyle cloverphp crap4j dry htmlpublisher jdepend plot pmd violations xunit

# Install the PHP-Jenkins job template:
sudo wget -N http://localhost:8080/jnlpJars/jenkins-cli.jar
sudo curl -L https://raw.githubusercontent.com/sebastianbergmann/php-jenkins-template/master/config.xml | sudo java -jar jenkins-cli.jar -s http://localhost:8080 create-job php-template
