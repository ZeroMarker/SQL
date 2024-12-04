# oracle


[Oracle Tutorial](https://www.oracletutorial.com/)

[Oracle PL/SQL Full Course](https://www.youtube.com/watch?v=yGU4YfSSjdM)

[Oracle SQL for Beginners](https://www.youtube.com/watch?v=yukL9vRalVo)

## ORACLE
[ORACLE](https://container-registry.oracle.com/)

```sh
podman run --name <container name> \
-P | -p <host port>:1521 \
-e ORACLE_PWD=<your database passwords> \
-e ORACLE_CHARACTERSET=<your character set> \
-v [<host mount point>:]/opt/oracle/oradata \
container-registry.oracle.com/database/free:latest

docker pull container-registry.oracle.com/database/free:latest

docker run -d --name oracle -p 1521:1521 -e ORACLE_PASSWORD=password -v oracle-volume:/opt/oracle/oradata container-registry.oracle.com/database/free:latest

docker exec -it oracle sqlplus / as sysdba
```

### Changing the Default Password for SYS User

username: SYSTEM
password: Password
role: SYSDBA
service name: FREE

```sh
docker exec oracle ./setPassword.sh Password

docker pull container-registry.oracle.com/database/free

docker stop oracle

docker run -d -it --name oracle --env="ORACLE_SID=DB" --env="ORACLE_PDB=PDB" --env="ORACLE_PWD=password" -p 1521:1521 container-registry.oracle.com/database/free

docker rm oracle

docker rmi container-registry.oracle.com/database/free
```

## gvenzl
[Oracle Database 23c Free — Developer Release for Java Developers with Docker on Windows](https://medium.com/oracledevs/oracle-database-23c-free-developer-release-for-java-developers-with-docker-on-windows-b164a7a61a91)

```sh
docker pull gvenzl/oracle-free

docker run -d --name oracle -p 1521:1521 -e ORACLE_PASSWORD=password -v oracle-volume:/opt/oracle/oradata gvenzl/oracle-free

docker ps -a

docker exec oracle resetPassword password

docker exec -it oracle /bin/bash

sqlplus / as sysdba
```

## connection
username: SYSTEM
password: password
Service Name: FREEPDB1

