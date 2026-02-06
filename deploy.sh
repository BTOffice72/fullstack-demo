#!/bin/bash

echo "=============================="
echo "🚀 Starting Fullstack Deployment"
echo "=============================="

# 1. Move to project directory
echo "➡️ Moving to project directory"
cd /home/tanmay/projects/fullstack-demo || {
  echo "❌ Project directory not found"
  exit 1
}

# 2. Git pull latest code
echo "➡️ Pulling latest code from GitHub"
git fetch origin
git checkout main
git pull origin main

if [ $? -ne 0 ]; then
  echo "❌ Git pull failed. Deployment stopped."
  exit 1
fi

# 3. Load environment variables
echo "➡️ Checking .env file"
if [ ! -f .env ]; then
  echo "❌ .env file not found"
  exit 1
fi

# 4. Install backend dependencies
echo "➡️ Installing backend dependencies"
npm install --production
if [ $? -ne 0 ]; then
  echo "❌ npm install failed"
  exit 1
fi

# 5. Stop existing PM2 process (if running)
echo "➡️ Stopping existing PM2 process (if any)"
pm2 stop fullstack-backend >/dev/null 2>&1
pm2 delete fullstack-backend >/dev/null 2>&1

# 6. Start backend with PM2
echo "➡️ Starting backend with PM2"
pm2 start index.js --name fullstack-backend
if [ $? -ne 0 ]; then
  echo "❌ PM2 start failed"
  exit 1
fi

# 7. Save PM2 process list
echo "➡️ Saving PM2 process list"
pm2 save

# 8. Restart Apache (proxy safety)
echo "➡️ Restarting Apache"
sudo systemctl restart apache2
if [ $? -ne 0 ]; then
  echo "❌ Apache restart failed"
  exit 1
fi

# 9. Health check
echo "➡️ Running backend health check"
sleep 2
curl -s http://localhost:3000/api/health >/dev/null

if [ $? -eq 0 ]; then
  echo "✅ Backend health check passed"
else
  echo "⚠️ Backend health check failed (check PM2 logs)"
fi

echo "=============================="
echo "✅ Deployment Completed Successfully"
echo "=============================="
