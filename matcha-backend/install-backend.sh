echo "Building backend..."
npm install
echo "App built!"

node setup.js
echo "Database set"

npm run watch

