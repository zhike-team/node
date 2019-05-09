tags=$(<./tags)

for tag in $tags; do
    cat <<EOF > ./Dockerfile
    FROM node:$tag
    RUN echo http://mirrors.aliyun.com/alpine/v3.9/main/ > /etc/apk/repositories \
      && apk update \
      && apk add tzdata git \
      && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
      && echo Asia/Shanghai > /etc/timezone
    USER node
    ENV SASS_BINARY_SITE https://npm.taobao.org/mirrors/node-sass/
    RUN npm config set registry https://registry-npm.smartstudy.com/
    RUN cd /tmp && npm i $(paste -s -d" "  ./packages) && rm -rf /tmp/*
    USER root
EOF
    docker build . -t zhikesmartstudy/node:$tag
    # docker push zhikesmartstudy/node:$tag
done