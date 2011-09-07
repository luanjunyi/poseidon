apt-get install python-setuptools
apt-get install git-core
apt-get install python-dev
apt-get install libxml2-dev libxslt-dev
easy_install lxml
easy_install BeautifulSoup
wget http://sourceforge.net/projects/mysql-python/files/mysql-python/1.2.3/MySQL-python-1.2.3.tar.gz/download
tar zxf MySQL-python-1.2.3.tar.gz 

cd MySQL-python-1.2.3/
# Here we need to modify setup_posi.py
# Change 
#  mysql_config.path = "mysql_config"
# to point to the path of 'mysql_config'.
#  apt-get install libmysql++-dev
# maybe needed to get that file
python setup.py build
python setup.py install
cd ..

