FROM node:22-alpine

WORKDIR /app

ENV NODE_ENV=production

COPY package.json package-lock.json ./
RUN npm ci --omit=dev || npm install --omit=dev

COPY . .

ENV HOST=0.0.0.0
ENV SSL_OFF=1

CMD ["node", "server.js"]
