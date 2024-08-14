FROM node:10-alpine

RUN echo "nameserver 8.8.8.8" > /etc/resolv.conf


RUN mkdir -p /home/node/app/node_modules && chown -R node:node /home/node/app


WORKDIR /home/node/app

COPY package*.json ./

USER node

RUN npm install && npm audit fix

COPY --chown=node:node . . 

EXPOSE 3000

CMD [ "node", "index.js" ]