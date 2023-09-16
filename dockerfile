FROM node:16-alpine

RUN apk update && apk add --no-cache build-base gcc autoconf automake zlib-dev libpng-dev nasm bash vips-dev
ARG NODE_ENV=development
ENV NODE_ENV=${NODE_ENV}
ENV PATH /node-app/node_modules/.bin:$PATH

WORKDIR /node-app
COPY . .

RUN \
  if [ -f yarn.lock ]; then yarn --frozen-lockfile; \
  elif [ -f package-lock.json ]; then npm ci; \
  elif [ -f pnpm-lock.yaml ]; then yarn global add pnpm && pnpm i; \
  # Allow install without lockfile, so example works even without Node.js installed locally
  else echo "Warning: Lockfile not found. It is recommended to commit lockfiles to version control." && yarn install; \
  fi

RUN ["yarn", "build"]
EXPOSE ${PORT}

CMD \
  if [ -f yarn.lock ]; then yarn develop; \
  elif [ -f package-lock.json ]; then npm run develop; \
  elif [ -f pnpm-lock.yaml ]; then pnpm develop; \
  else yarn develop; \
  fi