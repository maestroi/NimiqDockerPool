FROM node:8-alpine
# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
COPY package*.json ./
# RUN NPM install --only=production, for production compiling the source. 
RUN apk add --no-cache --virtual .build-deps make gcc g++ python \
 && npm install --production --silent \
 && apk del .build-deps
# Bundle app source to be used.
COPY . /node
# Config system and start
CMD cd node && chmod +x payout.sh &&/bin/sh payout.sh