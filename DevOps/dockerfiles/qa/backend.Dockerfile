#backend
FROM node:18
WORKDIR /usr/src/app
COPY ["package.json", "package-lock.json*", "./"]
RUN npm i
COPY . .
EXPOSE 4000
CMD ["npm", "run", "dev"]