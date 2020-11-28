# Docker Python Flask Server with Traefik,Redis and Whoami 
mika.nokka1@gmail.com    25.11.2020 



**Provides  4 Docker images with following functionality** <br/><br/>

1) **dockerserver** (Python flask server, showing how to provide mini web service <br>
All options are logging to docker system logile and own logfile <br>

dockerserver.docker.localhost/ : "Hello world" <br>
dockerserver.docker.localhost/test : webcounter example (using redis db)<br>
dockerserver.docker.localhost/logs : executes ls system command  <br>


2)**whoami** (web version, shows machine information)<br>
whoami.docker.localhost<br>
Traefik basic authorization (user:admin, password:catsayscat)<br><br>

3) **redis** (kinda database, used for web counter example from dockerserver)<br><br>

4) **Traefik** reverse proxy, load balancer, authenticator for docker images<br>
Provides "url names for docker images"<br><br>

Traefik management console: http://traefik.docker.localhost/dashboard/<br>
(user:admin, password:catsayscat)<br><br>


**Tested and developed: Linux Mint 19.3**<br>
**Docker, docker compose assumed to be installed**<br><br>

Usage: <br><br>
_make_ : builds and starts all images (ony files changed since last building)<br>
_make log_ : shows every docker image's logs (from docker system log)<br>
_make logs_ : starts following Flask server own logging file<br>
_make -B_ : force build everything<br>


 
  
 
  
