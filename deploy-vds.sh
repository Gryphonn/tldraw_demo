#!/bin/bash

# TLDraw VDS Deployment Script
# Run this as root on your VDS

set -e

echo "🚀 Starting TLDraw VDS deployment..."

# Update system
echo "📦 Updating system packages..."
apt update && apt upgrade -y

# Install Node.js
echo "📦 Installing Node.js..."
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
apt-get install -y nodejs

# Install PM2 and pnpm
echo "📦 Installing PM2 and pnpm..."
npm install -g pm2 pnpm

# Install Nginx
echo "📦 Installing Nginx..."
apt install nginx -y
systemctl enable nginx
systemctl start nginx

# Create application directory
echo "📁 Setting up application directory..."
mkdir -p /var/www
cd /var/www

# Clone repository (replace with your repo URL)
echo "📥 Cloning repository..."
git clone https://github.com/your-username/tldraw_back.git
cd tldraw_back

# Install dependencies
echo "📦 Installing dependencies..."
pnpm install

# Build frontend
echo "🔨 Building frontend..."
cd apps/frontend
pnpm build

# Set up environment variables
echo "⚙️ Setting up environment variables..."
echo "VITE_API_URL=https://your-domain.com/api" > .env
# Or for IP: echo "VITE_API_URL=http://$(curl -s ifconfig.me)/api" > .env

# Build backend
echo "🔨 Building backend..."
cd ../backend
pnpm build

# Install serve for frontend
cd ../frontend
npm install serve --save-dev

# Start applications with PM2
echo "🚀 Starting applications..."
cd /var/www/tldraw_back
pm2 start ecosystem.config.js
pm2 save
pm2 startup

# Configure Nginx
echo "🌐 Configuring Nginx..."
cat > /etc/nginx/sites-available/tldraw << 'EOF'
server {
    listen 80;
    server_name your-domain.com;  # Replace with your domain or IP
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
    
    location /api/ {
        proxy_pass http://localhost:5858/api/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 86400;
        proxy_send_timeout 86400;
    }
    
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied expired no-cache no-store private must-revalidate auth;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss application/javascript;
}
EOF

# Enable site
ln -sf /etc/nginx/sites-available/tldraw /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t
systemctl reload nginx

# Configure firewall
echo "🔥 Configuring firewall..."
ufw allow ssh
ufw allow 'Nginx Full'
ufw --force enable

# Create backup script
echo "💾 Setting up backup script..."
cat > /root/backup-tldraw.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/var/backups/tldraw"
DATE=$(date +%Y%m%d_%H%M%S)
mkdir -p $BACKUP_DIR
tar -czf $BACKUP_DIR/app_$DATE.tar.gz /var/www/tldraw_back
tar -czf $BACKUP_DIR/data_$DATE.tar.gz /var/www/tldraw_back/apps/backend/.rooms /var/www/tldraw_back/apps/backend/.assets
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete
echo "Backup completed: $DATE"
EOF

chmod +x /root/backup-tldraw.sh

# Add to crontab
(crontab -l 2>/dev/null; echo "0 2 * * * /root/backup-tldraw.sh") | crontab -

echo "✅ Deployment completed!"
echo "🌐 Your TLDraw app should be available at: http://your-domain.com"
echo "📊 Check status with: pm2 status"
echo "📝 View logs with: pm2 logs"
echo "🔧 Remember to update the domain name in Nginx config and .env file!" 