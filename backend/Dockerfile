FROM mhart/alpine-node:14
WORKDIR /usr/server
COPY . .
RUN npm ci --only=production
EXPOSE 80
CMD ["node", "server.js"]
