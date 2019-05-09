tags=$(<./tags)

for tag in $tags; do
    echo FROM node:$tag > ./Dockerfile
    echo "RUN echo http://mirrors.aliyun.com/alpine/v3.9/main/ > /etc/apk/repositories \
  && apk update \
  && apk add tzdata git \
  && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
  && echo Asia/Shanghai > /etc/timezone" >> ./Dockerfile
    echo RUN npm config set registry https://registry-npm.smartstudy.com/ >> ./Dockerfile
    echo USER node >> ./Dockerfile
    echo RUN npm config set registry https://registry-npm.smartstudy.com/ >> ./Dockerfile
    echo "RUN cd /tmp && npm i " $(paste -s -d" "  ./packages) "&& rm -rf /tmp/*" >> ./Dockerfile
    echo USER root >> ./Dockerfile
    docker build . -t zhikesmartstudy/node:$tag
    docker push zhikesmartstudy/node:$tag
done