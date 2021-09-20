#!/bin/sh 
mkdir ~/work
git clone -b dev git@github.com:earndiva/itkmitl-bookinfo-ratings.git ~/work/ratings
git clone -b dev git@github.com:earndiva/itkmitl-bookinfo-details.git ~/work/details
git clone -b dev git@github.com:earndiva/itkmitl-bookinfo-reviews.git ~/work/reviews
git clone -b dev git@github.com:earndiva/itkmitl-bookinfo-productpage.git ~/work/productpage

cd ~/work/ratings
docker build -t ratings .
docker run -d --name mongodb -p 27017:27017 \
  -v $(pwd)/databases:/docker-entrypoint-initdb.d bitnami/mongodb:5.0.2-debian-10-r2
docker run -d --name ratings -p 8080:8080 --link mongodb:mongodb \
  -e SERVICE_VERSION=v2 -e 'MONGO_DB_URL=mongodb://mongodb:27017/ratings' ratings

cd ~/work/details
docker build -t details . 
docker run -d --name details -p 8081:8081 details

cd ~/work/reviews
docker build -t reviews .
docker run -d --name reviews -p 8082:9080 --link ratings:ratings -e ENABLE_RATINGS=true -e "RATINGS_SERVICE=http://ratings:8080" reviews

cd ~/work/productpage
docker build -t productpage .
docker run -d --name productpage -p 8083:8083 --link details:details --link reviews:reviews --link ratings:ratings -e "DETAILS_HOSTNAME=http://details:8081" -e "RATINGS_HOSTNAME=http://ratings:8080" -e "REVIEWS_HOSTNAME=http://reviews:9080" productpage
