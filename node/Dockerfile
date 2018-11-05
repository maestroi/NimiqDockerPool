FROM node:8-alpine
# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
COPY package*.json ./
# If you are building your code for production
# RUN npm install --only=production
RUN apk add --no-cache --virtual .build-deps make gcc g++ python \
 && npm install --production --silent \
 && apk del .build-deps
# Bundle app source
COPY . /node
# config system and start
CMD cd node && /bin/sh start_node.sh