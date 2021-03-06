# node

自带npm cache的docker基础镜像打包工具

## 要解决的问题

CI / CD 过程中，经常会需要执行 `npm install` 或 `npm ci` 等装包的操作，尽管可以将 `package-lock.json` 前置，利用docker cache，但是终究还是会有cache不到的场景。

因此想使用自带npm cache的基础镜像，以加速 `npm install` 过程。

## 基本原理

`npm install` 过程中会产生 cache，一般在 `~/.npm` 目录下。如果在基础镜像中先执行 `npm install` 随后立即删除 `node_modules`，则基础镜像中会增加一份 npm cache，可以加速后续的 `npm install` 操作。

我们可以假设常用的 packages 是大致固定的，如 react typescript 等，可以维护一份统一的清单。

但是基础镜像是可能会有多份，如有人用 node 8，有人用 node 10等。因此我在项目中加入了 `build.sh` 文件，它会读取 tags 文件中的所有标签，并以 node:<标签>作为基础镜像，缓存 packages 中的所有包，在打包后，发布到 zhikesmartstudy/node:<标签> 下。

## 执行方式

本地执行，需要有 docker push 到 zhikesmartstudy/node 的权限。

## 缺陷

更新比较麻烦，因为packages可能会变化，如之前在用 react 16.7，可能之后就换成了 16.8，无法命中。但是docker build服务器上已经有了cache，即使重新发布一次，也不一定能命中。

所以不应依赖此cache，至于更新的问题，可以在之后每隔几个月重新更新一下 packages 文件，然后清空下 docker build 服务器上的缓存。

缓存文件比较大，目前的版本会增长200MB左右的体积，如果只有一份相同的tag还可接受，如果tag很多也是对磁盘空间的浪费。所以不推荐用更改tag的方式来实现docker build服务器的更新。

## Dockerfile 预览

```Dockerfile
    FROM node:10.15.3-alpine
    RUN echo http://mirrors.aliyun.com/alpine/v3.9/main/ > /etc/apk/repositories       && apk update       && apk add tzdata git       && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime       && echo Asia/Shanghai > /etc/timezone
    USER node
    ENV SASS_BINARY_SITE https://npm.taobao.org/mirrors/node-sass/
    RUN npm config set registry https://registry-npm.smartstudy.com/
    RUN cd /tmp && npm i @babel/core@7.3.3 @babel/plugin-proposal-class-properties@7.3.3 @babel/plugin-proposal-decorators@7.3.0 @babel/plugin-proposal-do-expressions@7.2.0 @babel/plugin-proposal-export-default-from@7.2.0 @babel/plugin-proposal-export-namespace-from@7.2.0 @babel/plugin-proposal-function-bind@7.2.0 @babel/plugin-proposal-function-sent@7.2.0 @babel/plugin-proposal-json-strings@7.2.0 @babel/plugin-proposal-logical-assignment-operators@7.2.0 @babel/plugin-proposal-nullish-coalescing-operator@7.2.0 @babel/plugin-proposal-numeric-separator@7.2.0 @babel/plugin-proposal-optional-chaining@7.2.0 @babel/plugin-proposal-pipeline-operator@7.3.2 @babel/plugin-proposal-throw-expressions@7.2.0 @babel/plugin-syntax-dynamic-import@7.2.0 @babel/plugin-syntax-import-meta@7.2.0 @babel/plugin-transform-parameters@7.3.3 @babel/plugin-transform-runtime@7.2.0 @babel/polyfill@7.2.5 @babel/preset-env@7.3.1 @babel/preset-react@7.0.0 @babel/runtime@7.3.1 @babel/traverse@7.2.3 @babel/types@7.3.3 @material-ui/core@3.3.1 @storybook/addon-info@3.4.11 @storybook/react@3.4.11 @types/bluebird@3.5.24 @types/body-parser@1.17.0 @types/compression@0.0.36 @types/connect-timeout@0.0.33 @types/cookie-parser@1.4.1 @types/cookie@0.3.1 @types/cors@2.8.4 @types/cpx@1.5.0 @types/debug@0.0.31 @types/enzyme-adapter-react-16@1.0.3 @types/enzyme@3.1.15 @types/exceljs@0.5.2 @types/express-winston@3.0.1 @types/express@4.16.0 @types/history@4.7.1 @types/inquirer@0.0.43 @types/jest@23.3.2 @types/joi@14.3.2 @types/js-beautify@1.8.0 @types/jsonwebtoken@8.3.2 @types/lodash@4.14.117 @types/method-override@0.0.31 @types/mocha@5.2.5 @types/moment-duration-format@2.2.2 @types/moment-timezone@0.5.9 @types/node-cron@1.2.0 @types/node@10.10.1 @types/pg@7.4.10 @types/power-assert@1.5.0 @types/progress@2.0.3 @types/proxyquire@1.3.28 @types/qs@6.5.1 @types/query-string@6.1.1 @types/raven@2.5.1 @types/react-dom@16.0.7 @types/react-redux@6.0.9 @types/react-router-dom@4.3.1 @types/react-slick@0.23.2 @types/react@16.4.14 @types/redis@2.8.6 @types/redux-actions@2.3.1 @types/request-promise-native@1.0.15 @types/request@2.47.1 @types/sanitize-html@1.18.2 @types/semver@5.5.0 @types/sequelize@4.27.25 @types/sinon@7.0.0 @types/socket.io-client@1.4.32 @types/socketio-wildcard@2.0.1 @types/source-map-support@0.4.1 @types/storybook__addon-info@3.4.2 @types/storybook__react@3.0.9 @types/supertest@2.0.6 @types/table@4.0.5 @types/uuid@3.4.4 @types/validator@9.4.1 @zhike-private/types@0.0.8 @zhike/apollon-mobile-components@1.3.5 @zhike/restrict-ip-express-middleware@1.1.1 aliyun-sdk@1.12.0 amfe-flexible@2.2.1 antd@3.8.0 apidoc@0.17.7 art-template@4.13.2 autoprefixer@7.1.6 autosize@3.0.21 axios@0.18.0 babel-core@7.0.0-bridge.0 babel-jest@23.6.0 babel-loader@8.0.5 babel-plugin-import@1.11.0 babel-plugin-transform-es3-member-expression-literals@6.22.0 babel-plugin-transform-es3-property-literals@6.22.0 babel-plugin-transform-react-remove-prop-types@0.4.18 babel-preset-react-app@3.1.2 babel-preset-stage-0@6.24.1 better-scroll@1.12.4 bluebird@3.5.4 body-parser@1.18.3 case-sensitive-paths-webpack-plugin@2.1.1 chalk@2.4.2 chance@1.0.16 classnames@2.2.6 co-multipart@2.0.0 co@4.6.0 commander@2.17.1 compression@1.7.4 connect-timeout@1.9.0 cookie-parser@1.4.4 cookie@0.3.1 copy-webpack-plugin@4.5.4 cors@2.8.5 cpx@1.5.0 cross-env@2.0.1 css-loader@0.28.11 date-fns@1.30.1 dayjs@1.7.7 debug@4.1.0 detect-browser@3.0.0 dotenv-expand@4.2.0 dotenv@4.0.0 duplicate-package-checker-webpack-plugin@3.0.0 dva-loading@2.0.6 dva@2.4.0 echarts-for-react@2.0.13 echarts@4.1.0 enzyme-adapter-react-16@1.7.1 enzyme@3.8.0 exceljs@0.5.1 express-winston@3.1.0 express@4.16.4 extract-text-webpack-plugin@4.0.0-beta.0 file-loader@1.1.11 file-saver@1.3.8 fingerprintjs2@1.8.1 font-awesome@4.7.0 fork-ts-checker-webpack-plugin@0.2.10 fs-extra@3.0.1 full-icu@1.2.1 happypack@5.0.0 history@4.7.2 html-loader@0.5.5 html-webpack-plugin@3.2.0 html2canvas@1.0.0-alpha.12 husky@1.1.2 is-mobile@2.0.0 jest-localstorage-mock@2.3.0 jest-webpack-resolver@0.3.0 jest@23.6.0 joi@14.3.1 jquery@>=1.8.0 js-base64@2.4.6 js-beautify@1.9.1 jsdoc@3.5.5 jsinspect@0.12.7 json-loader@0.5.7 jsonwebtoken@8.5.1 jspdf@1.4.1 left-pad@1.3.0 less-loader@4.1.0 less@3.9.0 lodash@4.17.11 markdown-table@1.1.2 material-ui-pickers@1.0.1 md5@2.2.1 memoize-one@3.1.1 merge-stream@1.0.1 method-override@2.3.10 mime@2.3.1 mocha@5.2.0 moment-duration-format@2.2.2 moment-timezone@0.5.23 moment@2.24.0 node-cron@1.2.1 node-object-hash@1.4.1 node-sass-chokidar@1.3.4 node-sass@4.9.2 node-xlsx@0.7.4 npm-run-all@4.1.5 nyc@11.9.0 nzh@1.0.4 object-assign@4.1.1 path-to-regexp@2.2.0 path@0.12.7 pg-hstore@2.3.2 pg@7.9.0 postcss-flexbugs-fixes@3.2.0 postcss-loader@2.0.8 postcss-px2rem@0.3.0 power-assert@1.6.1 promise@8.0.1 prop-types@15.6.1 proxyquire@2.1.0 qs@6.6.0 query-string@6.2.0 raf@3.4.0 raven-js@3.27.0 raven@2.6.4 rc-calendar@9.10.5 react-addons-css-transition-group@15.6.2 react-dev-utils@5.0.2 react-dipper@0.1.3 react-docgen-typescript-webpack-plugin@1.1.0 react-dom@16.5.2 react-draggable@3.1.1 react-easy-swipe@0.0.17 react-hot-loader@1.3.1 react-id-swiper@1.6.6 react-iframe@1.2.0 react-loadable@5.4.0 react-mixin@3.1.1 react-mobile-datepicker@4.0.0 react-mock-router@1.0.15 react-redux@5.0.7 react-refetch@1.0.4 react-router-config@1.0.0-beta.4 react-router-dom@4.3.1 react-router@4.3.1 react-sider@0.3.4 react-slick@0.23.2 react@16.7.0 reactour@1.8.2 redis@2.8.0 redux-actions@2.6.3 redux-logger@3.0.6 redux-thunk@1.0.3 redux@4.0.1 request-promise-native@1.0.7 reselect@4.0.0 resolve@1.6.0 sa-sdk-node@1.1.4 sanitize-html@1.20.0 sass-loader@6.0.7 semver@5.7.0 sequelize@4.43.1 sinon@7.2.2 slick-carousel@1.8.1 socket.io-client@2.2.0 socket.io-emitter@3.1.1 socket.io@2.1.1 socketio-wildcard@2.0.0 source-map-explorer@1.6.0 source-map-loader@0.2.4 source-map-support@0.5.12 speed-measure-webpack-plugin@1.2.3 ss-activity-tracker@1.0.4 store@1.3.20 style-loader@0.20.3 supertest@3.4.2 sw-precache-webpack-plugin@0.11.4 table@4.0.3 tosource@1.0.0 ts-jest@22.0.1 ts-loader@2.3.7 ts-node-dev@1.0.0-pre.32 ts-node@7.0.1 tsconfig-paths-webpack-plugin@2.0.0 typescript@3.0.3 uglifyjs-webpack-plugin@1.3.0 unused-files-webpack-plugin@3.4.0 url-loader@1.0.1 uuid@3.3.2 validator@9.4.1 walkdir@0.0.12 webpack-cli@2.1.5 webpack-dev-server@3.1.14 webpack-manifest-plugin@1.3.2 webpack-sentry-plugin@1.16.0 webpack@4.16.0 wechat-toolkit@0.2.19 wechat@2.1.0 weixin-js-sdk@1.4.0-test whatwg-fetch@2.0.4 winston-daily-rotate-file@3.8.0 winston@3.2.1 zhike-consul@1.0.12 zhike-util@1.0.6 && rm -rf /tmp/*
    USER root
```