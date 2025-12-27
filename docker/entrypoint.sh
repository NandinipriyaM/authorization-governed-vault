#!/bin/sh
set -e

echo "🚀 Starting local Hardhat blockchain..."
npx hardhat node --hostname 0.0.0.0 &

# Give the node time to start
sleep 5

echo "📦 Compiling contracts..."
npx hardhat compile

echo "📜 Deploying contracts..."
node scripts/deploy.js

echo "✅ Deployment complete. System is ready."

# Keep container alive
tail -f /dev/null
