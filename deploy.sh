#!/bin/bash

echo "=============================="
echo "🚀 Starting Backend Deployment"
echo "=============================="

APP_NAME="fullstack-demo"
APP_DIR="/home/tanmay/projects/fullstack-demo"
APP_ENTRY="index.js"

# 1. Move to project directory
echo "➡️ Moving to project directory"
cd $APP_DIR || {
  echo "❌ Project directory not found"
  exit 1
}

# 2. Git pull latest code
echo "➡️ Pulling latest code from GitHub"
git fetch origin
git checkout main
git pull origin main || {
  echo "❌ Git pull failed. Deployment stopped."
  exit 1
}

# 3. Check .env file
echo "➡️ Checking .env file"
if [ ! -f .env ]; then
  echo "❌ .env file not found"
  exit 1
fi

# 4. Install backend dependencies
echo "➡️ Installing backend dependencies"
npm install --production || {
  echo "❌ npm install failed"
  exit 1
}

# 5. PM2 deploy logic (NO DUPLICATES)
if pm2 list | grep -q "$APP_NAME"; then
  echo "➡️ Reloading existing PM2 process: $APP_NAME"
  pm2 reload "$APP_NAME"
else
  echo "➡️ Starting PM2 process for first time: $APP_NAME"
  pm2 start "$APP_ENTRY" --name "$APP_NAME"
fi

# 6. Save PM2 process list
echo "➡️ Saving PM2 process list"
pm2 save

# 7. Restart Apache (proxy safety)
echo "➡️ Restarting Apache"
sudo systemctl restart apache2 || {
  echo "❌ Apache restart failed"
  exit 1
}

# 8. Health check
echo "➡️ Running backend health check"
sleep 2
if curl -s http://localhost:3000/api/health >/dev/null; then
  echo "✅ Backend health check passed"
else
  echo "⚠️ Backend health check failed (check PM2 logs)"
fi

echo "=============================="
echo "✅ Backend Deployment Completed Successfully"
echo "=============================="
