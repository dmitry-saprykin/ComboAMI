### Script provided by DataStax.

if [ ! -f cert-*.pem ];
then
    echo "Cert files not found on machine!"
    exit
fi

# Update packages
sudo yum -y update

# Prime for Java installation
#cd /opt/
#sudo wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/7u75-b13/jdk-7u75-linux-x64.tar.gz"
#sudo tar xzf jdk-7u75-linux-x64.tar.gz
#cd /opt/jdk1.7.0_75/
#sudo alternatives --install /usr/bin/java java /opt/jdk1.7.0_75/bin/java 2
sudo yum -y install java-1.7.0-openjdk java-1.7.0-openjdk-devel
alternatives --config java

export JAVA_HOME=/usr/lib/jvm/jre-1.7.0-openjdk.x86_64/
export PATH=$PATH:/usr/lib/jvm/jre-1.7.0-openjdk.x86_64/bin/

#Install jna
sudo yum -y install jna

# Install cloud-init
sudo yum -y install cloud-init

# Install Git
sudo yum -y install git

# Git these files on to the server's home directory
git config --global color.ui auto
git config --global color.diff auto
git config --global color.status auto
git clone https://github.com/dmitry-saprykin/ComboAMI.git datastax_ami
cd datastax_ami
git checkout $(head -n 1 presetup/VERSION)

sudo yum -y install wget
wget http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
sudo rpm -Uhv rpmforge-release*.rf.x86_64.rpm
sudo rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm

cat > ./epel-apache-maven.repo << EOF
[epel-apache-maven]
name=maven from apache foundation.
baseurl=http://repos.fedorapeople.org/repos/dchen/apache-maven/epel-6Server/x86_64/
enabled=1
skip_if_unavailable=1
gpgcheck=0

[epel-apache-maven-source]
name=maven from apache foundation. - Source
baseurl=http://repos.fedorapeople.org/repos/dchen/apache-maven/epel-6Server/SRPMS
enabled=0
skip_if_unavailable=1
gpgcheck=0
EOF
sudo mv ./epel-apache-maven.repo /etc/yum.repos.d/epel-apache-maven.repo

sudo yum -y groupinstall "Development Tools"
sudo yum -y install openssl-devel

# Begin the actual priming
git pull
sudo python presetup/pre_2.py

# Fix booting issues on hs1.8xlarge
find /lib/modules |grep 'raid[456]' | sudo xargs -i rm -rf {} && sudo depmod -a
sudo update-initramfs -k all -c
gunzip -c /boot/initrd.img-*-generic | cpio --list | grep raid

sudo chown -R cassandra:cassandra . 
rm -rf ~/.bash_history 
history -c
