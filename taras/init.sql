set names utf8;

drop database taras;
create database taras;

use taras;

-- For crawler

create table tweet_crawled (
source varchar(255) not null,
item int not null,
title varchar(280),
content varchar(280),
href varchar(280),
image_bin mediumblob,
primary key(source, item)
);

create table crawl_history (
source varchar(255) not null primary key,
last_crawl char(10) not null,
failed_count int
);

create table victim_crawled (
email varchar(255) not null,
victim varchar(64) not null,
primary key(email, victim)
);

create table victim_crawl_history (
email varchar(255) not null primary key,
last_crawl char(10) not null,
victim_found int
);



-- End crawler

create table user_statistic (
user_email varchar(255) not null,
date int not null,
follow_count int not null,
followed_count int not null,
tweet_count int not null,
mutual_follow_count int not null,
primary key(user_email, date)
);


create table sina_user (
id int not null auto_increment primary key,
email varchar(255) not null unique,
passwd varchar(255) not null,
tags varchar(255) not null,
sources varchar(1024) not null,
work_time_start tinyint not null,
work_time_end tinyint not null,
victim_keywords varchar(255) not null,
categories varchar(255),
sina_id bigint,
enabled tinyint default 1,
next_action_time int default -1
);

create table sina_app (
id int not null primary key auto_increment,
token varchar(1024) not null,
secret varchar(1024) not null
);

create table sina_token (
user_email varchar(255) not null,
app_id int not null,
value varbinary(1024),
primary key(user_email, app_id)
);

create table tweet (
id int not null primary key auto_increment,
content varchar(512) not null,
tag varchar(256) not null,
source varchar(1024)
);

create table random_comment (
id int not null primary key auto_increment,
content varchar(512) not null
);

create table random_follow_request (
id int not null primary key auto_increment,
content varchar(512) not null
);




create table comment_request (
tweet_id int not null,
content varchar(512) not null,
user_email varchar(256) not null,
id int not null primary key auto_increment
);

create table source_item (
id int not null primary key auto_increment,
source_id varchar(255) not null,
title_xpath varchar(1024),
content_xpath varchar(1024) not null,
image_xpath varchar(1024),
href_xpath varchar(1024)
);

create table source (
id varchar(255) not null primary key,
base_url varchar(1024) not null,
encoding varchar(32) not null,
need_query tinyint not null,
tags varchar(255) DEFAULT NULL
);

create table follow_date (
user_email varchar(255) not null,
followee_id varchar(64) not null,
create_date varbinary(255) not null,
primary key(user_email, followee_id)
);

create table force_action (
type varchar(16) not null,
value varchar(255) not null,
affected_categories varchar(512)
);

insert into sina_user(email, passwd, tags, sources,
       work_time_start, work_time_end, victim_keywords,
       categories, sina_id, enabled) values (
'hrdeatheaters@gmail.com',
'admin123',
'女人#婚纱照#蜜月#红地毯#服饰搭配#八卦#情感#爱情#丰胸#出轨#美胸#保湿',
'eladies.sina',
11,
14,
'婚纱照#婚纱#蜜月旅行#',
'女人#生活#时尚#塔罗斯',
0,
1
);

insert into sina_user(email, passwd, tags, sources,
       work_time_start, work_time_end, victim_keywords,
       categories, sina_id, enabled) values (
'luanjunyi@gmail.com',
'admin123',
'#摄影教程#单反镜头#摄影镜头#经典镜头#佳能相机#尼康相机#尼康镜头#佳能镜头#宾得镜头#索尼单反#蔡司镜头#IT#互联网#Google#baidu#ipad#iphone#苹果#乔布斯',
'news.nphoto#popular.nphoto#leica#www.36kr.com.1311666482',
11,
14,
'单反入门#尼康单反#佳能单反#摄影入门#胶片机入门#单反新手#google#百度#IT#互联网#iphone#ipad#乔布斯',
'互联网#旅游#生活#塔罗斯',
0,
1
);

insert into sina_user(email, passwd, tags, sources,
       work_time_start, work_time_end, victim_keywords,
       categories, sina_id, enabled) values (
'lionloudu@yahoo.com',
'sunbofu',
'#摄影教程#单反镜头#摄影镜头#经典镜头#佳能相机#尼康相机#尼康镜头#佳能镜头#宾得镜头#索尼单反#蔡司镜头',
'news.nphoto#popular.nphoto#leica',
13,
17,
'单反入门#尼康单反#佳能单反#摄影入门#胶片机入门#单反新手',
'数码#旅游#生活#塔罗斯',
0,
1
);

insert into sina_user(email, passwd, tags, sources,
       work_time_start, work_time_end, victim_keywords,
       categories, sina_id, enabled) values (
'pandis@live.cn',
'sunzhongmou',
'#减肥#女人#时尚#流行音乐#时装#香水#流行#化妆品#爱情#美容#养生#奢侈品#小资#星座',
'eladies.sina#leica#news.nphoto#popular.nphoto',
12,
17,
'#减肥#女人#时尚#流行音乐#时装#香水#流行#化妆品#爱情#美容#养生#奢侈品#小资#星座',
'娱乐#塔罗斯',
0,
1
);

insert into sina_user(email, passwd, tags, sources,
       work_time_start, work_time_end, victim_keywords,
       categories, sina_id, enabled) values (
'nirsonrenin@yahoo.com',
'yuanbenchu',
'#减肥#女人#时尚#流行音乐#时装#香水#流行#化妆品#爱情#美容#养生#奢侈品#小资#星座',
'eladies.sina#leica',
12,
17,
'#减肥#女人#时尚#流行音乐#时装#香水#流行#化妆品#爱情#美容#养生#奢侈品#小资#星座',
'减肥#美食#养生#打扮#星座',
0,
1
);

insert into sina_app(token, secret) values (
'722861218', '1cfbec16db00cac0a3ad393a3e21f144'
);


-- Baidu News Search
insert into source(id, base_url, encoding, need_query) values (
"news.baidu",
'http://news.baidu.com/ns?word=',
"gb2312",
1
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
"news.baidu",
'.//*[@id="r"]/table[2]//tr/td/a/span/b',
'.//*[@id="r"]/table[2]//tr/td/font[2]',
'.//*[@id="r"]/table[2]//tr/td[1]/a/img',
'.//*[@id="r"]/table[2]//tr/td/a'
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
"news.baidu",
'.//*[@id="r"]/table[3]//tr/td/a/span/b',
'.//*[@id="r"]/table[3]//tr/td/font[2]',
'.//*[@id="r"]/table[3]//tr/td[1]/a/img',
'.//*[@id="r"]/table[3]//tr/td/a'
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
"news.baidu",
'.//*[@id="r"]/table[4]//tr/td/a/span/b',
'.//*[@id="r"]/table[4]//tr/td/font[2]',
'.//*[@id="r"]/table[4]//tr/td[1]/a/img',
'.//*[@id="r"]/table[4]//tr/td/a'
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
"news.baidu",
'.//*[@id="r"]/table[5]//tr/td/a/span/b',
'.//*[@id="r"]/table[5]//tr/td/font[2]',
'.//*[@id="r"]/table[5]//tr/td[1]/a/img',
'.//*[@id="r"]/table[5]//tr/td/a'
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
"news.baidu",
'.//*[@id="r"]/table[6]//tr/td/a/span/b',
'.//*[@id="r"]/table[6]//tr/td/font[2]',
'.//*[@id="r"]/table[6]//tr/td[1]/a/img',
'.//*[@id="r"]/table[6]//tr/td/a'
);

-- Baidu Blog Search
insert into source(id, base_url, encoding, need_query) values (
"blogsearch.baidu",
'http://blogsearch.baidu.com/s?bs=%BB%E9%C9%B4&tn=baidublog&f=8&pba=1%7C2%7C4%7C8&blc=1&sst=0&wd=',
"gb2312",
1
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
"blogsearch.baidu",
'.//*[@id="1"]/dl/dt/a',
'.//*[@id="1"]/dl/dd[1]',
'',
'.//*[@id="1"]/dl/dt/a'
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
"blogsearch.baidu",
'.//*[@id="2"]/dl/dt/a',
'.//*[@id="2"]/dl/dd[1]',
'',
'.//*[@id="2"]/dl/dt/a'
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
"blogsearch.baidu",
'.//*[@id="3"]/dl/dt/a',
'.//*[@id="3"]/dl/dd[1]',
'',
'.//*[@id="3"]/dl/dt/a'
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
"blogsearch.baidu",
'.//*[@id="4"]/dl/dt/a',
'.//*[@id="4"]/dl/dd[1]',
'',
'.//*[@id="4"]/dl/dt/a'
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
"blogsearch.baidu",
'.//*[@id="5"]/dl/dt/a',
'.//*[@id="5"]/dl/dd[1]',
'',
'.//*[@id="5"]/dl/dt/a'
);

-- nphoto news
insert into source(id, base_url, encoding, need_query) values (
'news.nphoto',
'http://www.nphoto.net/news/',
'utf-8',
0
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
'news.nphoto',
'.//*[@id="standardContent"]/table//tr/td/div[1]/table//tr[1]/td[2]/a/span',
'.//*[@id="standardContent"]/table//tr/td/div[1]/table//tr[1]/td[2]/div',
'.//*[@id="standardContent"]/table//tr/td/div[1]/table//tr[1]/td[1]/a/img',
'.//*[@id="standardContent"]/table//tr/td/div[1]/table//tr[1]/td[2]/a'
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
'news.nphoto',
'.//*[@id="standardContent"]/table//tr/td/div[2]/table//tr[1]/td[2]/a/span',
'.//*[@id="standardContent"]/table//tr/td/div[2]/table//tr[1]/td[2]/div',
'.//*[@id="standardContent"]/table//tr/td/div[2]/table//tr[1]/td[1]/a/img',
'.//*[@id="standardContent"]/table//tr/td/div[2]/table//tr[1]/td[2]/a'
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
'news.nphoto',
'.//*[@id="standardContent"]/table//tr/td/div[3]/table//tr[1]/td[2]/a/span',
'.//*[@id="standardContent"]/table//tr/td/div[3]/table//tr[1]/td[2]/div',
'.//*[@id="standardContent"]/table//tr/td/div[3]/table//tr[1]/td[1]/a/img',
'.//*[@id="standardContent"]/table//tr/td/div[3]/table//tr[1]/td[2]/a'
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
'news.nphoto',
'.//*[@id="standardContent"]/table//tr/td/div[4]/table//tr[1]/td[2]/a/span',
'.//*[@id="standardContent"]/table//tr/td/div[4]/table//tr[1]/td[2]/div',
'.//*[@id="standardContent"]/table//tr/td/div[4]/table//tr[1]/td[1]/a/img',
'.//*[@id="standardContent"]/table//tr/td/div[4]/table//tr[1]/td[2]/a'
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
'news.nphoto',
'.//*[@id="standardContent"]/table//tr/td/div[5]/table//tr[1]/td[2]/a/span',
'.//*[@id="standardContent"]/table//tr/td/div[5]/table//tr[1]/td[2]/div',
'.//*[@id="standardContent"]/table//tr/td/div[5]/table//tr[1]/td[1]/a/img',
'.//*[@id="standardContent"]/table//tr/td/div[5]/table//tr[1]/td[2]/a'
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
'news.nphoto',
'.//*[@id="standardContent"]/table//tr/td/div[6]/table//tr[1]/td[2]/a/span',
'.//*[@id="standardContent"]/table//tr/td/div[6]/table//tr[1]/td[2]/div',
'.//*[@id="standardContent"]/table//tr/td/div[6]/table//tr[1]/td[1]/a/img',
'.//*[@id="standardContent"]/table//tr/td/div[6]/table//tr[1]/td[2]/a'
);

-- leica.org.cn
insert into source(id, base_url, encoding, need_query) values (
'leica',
'http://www.leica.org.cn',
'utf-8',
0
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
'leica',
'.//*[@id="innerContent"]/div[6]/div[1]/h1/a',
'.//*[@id="innerContent"]/div[6]/div[2]',
'.//*[@id="innerContent"]/div[6]/div[2]/img',
'.//*[@id="innerContent"]/div[6]/div[1]/h1/a'
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
'leica',
'.//*[@id="innerContent"]/div[9]/div[1]/h1/a',
'.//*[@id="innerContent"]/div[9]/div[2]',
'.//*[@id="innerContent"]/div[9]/div[2]/img',
'.//*[@id="innerContent"]/div[9]/div[1]/h1/a'
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
'leica',
'.//*[@id="innerContent"]/div[12]/div[1]/h1/a',
'.//*[@id="innerContent"]/div[12]/div[2]',
'.//*[@id="innerContent"]/div[12]/div[2]/img',
'.//*[@id="innerContent"]/div[12]/div[1]/h1/a'
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
'leica',
'.//*[@id="innerContent"]/div[15]/div[1]/h1/a',
'.//*[@id="innerContent"]/div[15]/div[2]',
'.//*[@id="innerContent"]/div[15]/div[2]/img',
'.//*[@id="innerContent"]/div[15]/div[1]/h1/a'
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
'leica',
'.//*[@id="innerContent"]/div[18]/div[1]/h1/a',
'.//*[@id="innerContent"]/div[18]/div[2]',
'.//*[@id="innerContent"]/div[18]/div[2]/img',
'.//*[@id="innerContent"]/div[18]/div[1]/h1/a'
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
'leica',
'.//*[@id="innerContent"]/div[21]/div[1]/h1/a',
'.//*[@id="innerContent"]/div[21]/div[2]',
'.//*[@id="innerContent"]/div[21]/div[2]/img',
'.//*[@id="innerContent"]/div[21]/div[1]/h1/a'
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
'leica',
'.//*[@id="innerContent"]/div[24]/div[1]/h1/a',
'.//*[@id="innerContent"]/div[24]/div[2]',
'.//*[@id="innerContent"]/div[24]/div[2]/img',
'.//*[@id="innerContent"]/div[24]/div[1]/h1/a'
);
insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
'leica',
'.//*[@id="innerContent"]/div[27]/div[1]/h1/a',
'.//*[@id="innerContent"]/div[27]/div[2]',
'.//*[@id="innerContent"]/div[27]/div[2]/img',
'.//*[@id="innerContent"]/div[27]/div[1]/h1/a'
);
insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
'leica',
'.//*[@id="innerContent"]/div[27]/div[1]/h1/a',
'.//*[@id="innerContent"]/div[27]/div[2]',
'.//*[@id="innerContent"]/div[27]/div[2]/img',
'.//*[@id="innerContent"]/div[27]/div[1]/h1/a'
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
'leica',
'.//*[@id="innerContent"]/div[30]/div[1]/h1/a',
'.//*[@id="innerContent"]/div[30]/div[2]',
'.//*[@id="innerContent"]/div[30]/div[2]/img',
'.//*[@id="innerContent"]/div[30]/div[1]/h1/a'
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
'leica',
'.//*[@id="innerContent"]/div[33]/div[1]/h1/a',
'.//*[@id="innerContent"]/div[33]/div[2]',
'.//*[@id="innerContent"]/div[33]/div[2]/img',
'.//*[@id="innerContent"]/div[33]/div[1]/h1/a'
);
insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
'leica',
'.//*[@id="innerContent"]/div[36]/div[1]/h1/a',
'.//*[@id="innerContent"]/div[36]/div[2]',
'.//*[@id="innerContent"]/div[36]/div[2]/img',
'.//*[@id="innerContent"]/div[36]/div[1]/h1/a'
);

-- nphoto popular
insert into source(id, base_url, encoding, need_query) values (
"popular.nphoto",
'http://photos.nphoto.net/popular/',
'utf-8',
0
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
"popular.nphoto",
'',
'.//*[@id="standardContent"]/div[2]/table[1]//tr[1]/td[1]/table//tr[2]/td',
'.//*[@id="standardContent"]/div[2]/table[1]//tr[1]/td[1]/table//tr[1]/td/a/img',
'.//*[@id="standardContent"]/div[2]/table[1]//tr[1]/td[1]/table//tr[1]/td/a'
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
"popular.nphoto",
'',
'.//*[@id="standardContent"]/div[2]/table[1]//tr[1]/td[2]/table//tr[2]/td',
'.//*[@id="standardContent"]/div[2]/table[1]//tr[1]/td[2]/table//tr[1]/td/a/img',
'.//*[@id="standardContent"]/div[2]/table[1]//tr[1]/td[2]/table//tr[1]/td/a'
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
"popular.nphoto",
'',
'.//*[@id="standardContent"]/div[2]/table[1]//tr[1]/td[3]/table//tr[2]/td',
'.//*[@id="standardContent"]/div[2]/table[1]//tr[1]/td[3]/table//tr[1]/td/a/img',
'.//*[@id="standardContent"]/div[2]/table[1]//tr[1]/td[3]/table//tr[1]/td/a'
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
"popular.nphoto",
'',
'.//*[@id="standardContent"]/div[2]/table[1]//tr[2]/td[1]/table//tr[2]/td',
'.//*[@id="standardContent"]/div[2]/table[1]//tr[2]/td[1]/table//tr[1]/td/a/img',
'.//*[@id="standardContent"]/div[2]/table[1]//tr[2]/td[1]/table//tr[1]/td/a'
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
"popular.nphoto",
'',
'.//*[@id="standardContent"]/div[2]/table[1]//tr[2]/td[2]/table//tr[2]/td',
'.//*[@id="standardContent"]/div[2]/table[1]//tr[2]/td[2]/table//tr[1]/td/a/img',
'.//*[@id="standardContent"]/div[2]/table[1]//tr[2]/td[2]/table//tr[1]/td/a'
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
"popular.nphoto",
'',
'.//*[@id="standardContent"]/div[2]/table[1]//tr[2]/td[3]/table//tr[2]/td',
'.//*[@id="standardContent"]/div[2]/table[1]//tr[2]/td[3]/table//tr[1]/td/a/img',
'.//*[@id="standardContent"]/div[2]/table[1]//tr[2]/td[3]/table//tr[1]/td/a'
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
"popular.nphoto",
'',
'.//*[@id="standardContent"]/div[2]/table[1]//tr[3]/td[1]/table//tr[2]/td',
'.//*[@id="standardContent"]/div[2]/table[1]//tr[3]/td[1]/table//tr[1]/td/a/img',
'.//*[@id="standardContent"]/div[2]/table[1]//tr[3]/td[1]/table//tr[1]/td/a'
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
"popular.nphoto",
'',
'.//*[@id="standardContent"]/div[2]/table[1]//tr[3]/td[2]/table//tr[2]/td',
'.//*[@id="standardContent"]/div[2]/table[1]//tr[3]/td[2]/table//tr[1]/td/a/img',
'.//*[@id="standardContent"]/div[2]/table[1]//tr[3]/td[2]/table//tr[1]/td/a'
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
"popular.nphoto",
'',
'.//*[@id="standardContent"]/div[2]/table[1]//tr[3]/td[3]/table//tr[2]/td',
'.//*[@id="standardContent"]/div[2]/table[1]//tr[3]/td[3]/table//tr[1]/td/a/img',
'.//*[@id="standardContent"]/div[2]/table[1]//tr[3]/td[3]/table//tr[1]/td/a'
);

-- camera.sina
insert into source(id, base_url, encoding, need_query) values (
"camera.sina",
'http://tech.sina.com.cn/digital/',
'gb2312',
0
);


insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
"camera.sina",
'html/body/div[2]/div[4]/div[1]/div[2]/ul/li[1]/a[1]',
'',
'',
'html/body/div[2]/div[4]/div[1]/div[2]/ul/li[1]/a[1]'
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
"camera.sina",
'html/body/div[2]/div[4]/div[1]/div[2]/ul/li[1]/a[2]',
'',
'',
'html/body/div[2]/div[4]/div[1]/div[2]/ul/li[1]/a[2]'
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
"camera.sina",
'html/body/div[2]/div[4]/div[1]/div[2]/ul/li[2]/a[1]',
'',
'',
'html/body/div[2]/div[4]/div[1]/div[2]/ul/li[2]/a[1]'
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
"camera.sina",
'html/body/div[2]/div[4]/div[1]/div[2]/ul/li[2]/a[2]',
'',
'',
'html/body/div[2]/div[4]/div[1]/div[2]/ul/li[2]/a[2]'
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
"camera.sina",
'html/body/div[2]/div[4]/div[1]/div[2]/ul/li[3]/a[1]',
'',
'',
'html/body/div[2]/div[4]/div[1]/div[2]/ul/li[3]/a[1]'
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
"camera.sina",
'html/body/div[2]/div[4]/div[1]/div[2]/ul/li[3]/a[2]',
'',
'',
'html/body/div[2]/div[4]/div[1]/div[2]/ul/li[3]/a[2]'
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
"camera.sina",
'html/body/div[2]/div[4]/div[1]/div[2]/ul/li[4]/a[1]',
'',
'',
'html/body/div[2]/div[4]/div[1]/div[2]/ul/li[4]/a[1]'
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
"camera.sina",
'html/body/div[2]/div[4]/div[1]/div[2]/ul/li[4]/a[2]',
'',
'',
'html/body/div[2]/div[4]/div[1]/div[2]/ul/li[4]/a[2]'
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
"camera.sina",
'html/body/div[2]/div[4]/div[2]/div[2]/div[4]/div[2]/ul/li[1]/a',
'',
'',
'html/body/div[2]/div[4]/div[2]/div[2]/div[4]/div[2]/ul/li[1]/a'
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
"camera.sina",
'html/body/div[2]/div[4]/div[2]/div[2]/div[4]/div[2]/ul/li[2]/a',
'',
'',
'html/body/div[2]/div[4]/div[2]/div[2]/div[4]/div[2]/ul/li[2]/a'
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
"camera.sina",
'html/body/div[2]/div[4]/div[2]/div[2]/div[4]/div[2]/ul/li[3]/a',
'',
'',
'html/body/div[2]/div[4]/div[2]/div[2]/div[4]/div[2]/ul/li[3]/a'
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
"camera.sina",
'html/body/div[2]/div[4]/div[2]/div[2]/div[4]/div[2]/ul/li[4]/a',
'',
'',
'html/body/div[2]/div[4]/div[2]/div[2]/div[4]/div[2]/ul/li[4]/a'
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
"camera.sina",
'html/body/div[2]/div[4]/div[2]/div[2]/div[4]/div[2]/ul/li[5]/a',
'',
'',
'html/body/div[2]/div[4]/div[2]/div[2]/div[4]/div[2]/ul/li[5]/a'
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
"camera.sina",
'html/body/div[2]/div[4]/div[2]/div[2]/div[3]/div[2]/ul[1]/li[1]/a[1]',
'',
'',
'html/body/div[2]/div[4]/div[2]/div[2]/div[3]/div[2]/ul[1]/li[1]/a[1]'
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
"camera.sina",
'html/body/div[2]/div[4]/div[2]/div[2]/div[3]/div[2]/ul[1]/li[2]/a[1]',
'',
'',
'html/body/div[2]/div[4]/div[2]/div[2]/div[3]/div[2]/ul[1]/li[2]/a[1]'
);








-- eladies.sina
insert into source(id, base_url, encoding, need_query) values (
"eladies.sina",
'http://eladies.sina.com.cn/',
'gb2312',
0
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
"eladies.sina",
'.//*[@id="page"]/div[7]/div[2]/div/div[2]/div[1]/h2/a[1]',
'',
'',
'.//*[@id="page"]/div[7]/div[2]/div/div[2]/div[1]/h2/a[1]'
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
"eladies.sina",
'.//*[@id="page"]/div[7]/div[2]/div/div[2]/div[2]/h2/a[1]',
'',
'',
'.//*[@id="page"]/div[7]/div[2]/div/div[2]/div[2]/h2/a[1]'
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
"eladies.sina",
'.//*[@id="page"]/div[7]/div[2]/div/div[2]/div[3]/h2/a[1]',
'',
'',
'.//*[@id="page"]/div[7]/div[2]/div/div[2]/div[3]/h2/a[1]'
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
"eladies.sina",
'.//*[@id="page"]/div[7]/div[2]/div/div[2]/div[4]/h2/a[1]',
'',
'',
'.//*[@id="page"]/div[7]/div[2]/div/div[2]/div[4]/h2/a[1]'
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
"eladies.sina",
'.//*[@id="page"]/div[7]/div[2]/div/div[2]/div[5]/h2/a[1]',
'',
'',
'.//*[@id="page"]/div[7]/div[2]/div/div[2]/div[5]/h2/a[1]'
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
"eladies.sina",
'.//*[@id="page"]/div[22]/div[1]/div[2]/div[1]/div[1]/ul/li[1]/a',
'',
'',
'.//*[@id="page"]/div[22]/div[1]/div[2]/div[1]/div[1]/ul/li[1]/a'
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
"eladies.sina",
'.//*[@id="page"]/div[22]/div[1]/div[2]/div[1]/div[1]/ul/li[2]/a',
'',
'',
'.//*[@id="page"]/div[22]/div[1]/div[2]/div[1]/div[1]/ul/li[2]/a'
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
"eladies.sina",
'.//*[@id="page"]/div[22]/div[1]/div[2]/div[1]/div[1]/ul/li[3]/a',
'',
'',
'.//*[@id="page"]/div[22]/div[1]/div[2]/div[1]/div[1]/ul/li[3]/a'
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
"eladies.sina",
'.//*[@id="page"]/div[22]/div[1]/div[2]/div[1]/div[1]/ul/li[4]/a',
'',
'',
'.//*[@id="page"]/div[22]/div[1]/div[2]/div[1]/div[1]/ul/li[4]/a'
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
"eladies.sina",
'.//*[@id="page"]/div[22]/div[1]/div[2]/div[1]/div[1]/ul/li[5]/a',
'',
'',
'.//*[@id="page"]/div[22]/div[1]/div[2]/div[1]/div[1]/ul/li[5]/a'
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
"eladies.sina",
'.//*[@id="page"]/div[22]/div[1]/div[2]/div[1]/div[1]/ul/li[6]/a',
'',
'',
'.//*[@id="page"]/div[22]/div[1]/div[2]/div[1]/div[1]/ul/li[6]/a'
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
"eladies.sina",
'.//*[@id="page"]/div[23]/div[1]/div[2]/div/ul[1]/li[1]/a',
'',
'',
'.//*[@id="page"]/div[23]/div[1]/div[2]/div/ul[1]/li[1]/a'
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
"eladies.sina",
'.//*[@id="page"]/div[23]/div[1]/div[2]/div/ul[1]/li[2]/a',
'',
'',
'.//*[@id="page"]/div[23]/div[1]/div[2]/div/ul[1]/li[2]/a'
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
"eladies.sina",
'.//*[@id="page"]/div[23]/div[1]/div[2]/div/ul[1]/li[3]/a',
'',
'',
'.//*[@id="page"]/div[23]/div[1]/div[2]/div/ul[1]/li[3]/a'
);

insert into source_item(source_id, title_xpath, content_xpath, image_xpath, href_xpath) values (
"eladies.sina",
'.//*[@id="page"]/div[23]/div[1]/div[2]/div/ul[1]/li[4]/a',
'',
'',
'.//*[@id="page"]/div[23]/div[1]/div[2]/div/ul[1]/li[4]/a'
);

insert into random_comment(content) values ('赞一下');
insert into random_comment(content) values ('有意思，呵呵');
insert into random_comment(content) values ('此微博已被原作者删除');
insert into random_comment(content) values ('支持');
insert into random_comment(content) values ('围观~~');
insert into random_comment(content) values ('围观一下，嘿嘿');
insert into random_comment(content) values ('围观一下，哈哈');
insert into random_comment(content) values ('前排插入!');
insert into random_comment(content) values ('抢板凳，呵呵');
insert into random_comment(content) values ('围观一个');
insert into random_comment(content) values ('不错哦');
insert into random_comment(content) values ('不错');
insert into random_comment(content) values ('关注');
insert into random_comment(content) values ('关注中');
insert into random_comment(content) values ('nice!');
insert into random_comment(content) values ('zan!');
insert into random_comment(content) values ('哈哈哈哈哈哈哈哈哈');
insert into random_comment(content) values ('哈哈哈哈哈哈哈哈');
insert into random_comment(content) values ('哈哈哈哈哈哈');
insert into random_comment(content) values ('哈哈哈哈哈');
insert into random_comment(content) values ('哈哈哈哈');
insert into random_comment(content) values ('哈哈');

insert into force_action values ('tweet', 'Good day, and good night!', '');
insert into force_action values ('retweet', '10590184512', '数码');
insert into force_action values ('follow', '猫猫_miao', '');