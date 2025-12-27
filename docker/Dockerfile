FROM node:18-alpine

WORKDIR /app

# Copy dependency files first (better Docker caching)
COPY package.json package-lock.json ./
RUN npm install

# Copy the rest of the project
COPY . .

# Compile contracts
RUN npx hardhat compile

# Start blockchain + deploy contracts
CMD ["sh", "./docker/entrypoint.sh"]
