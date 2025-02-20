FROM node:18
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm install --omit=dev
COPY . .
CMD ["node", "server.js"]
EXPOSE 5000
