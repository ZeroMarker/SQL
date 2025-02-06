create database moviedb;
use moviedb;
create table movies(
   ID int(40) NOT NULL unique,
   Code varchar(15),
   actress varchar(63),
   Title varchar(255),
   Tags varchar(255),
   Length int(7),
   magnet varchar(255),
   primary key(ID)
)ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1;
