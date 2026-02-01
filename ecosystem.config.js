module.exports = {
  apps: [
    {
      name: 'tldraw-backend',
      cwd: './apps/backend',
      script: 'dist/server.js',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      env: {
        NODE_ENV: 'production',
        PORT: 5858
      },
      error_file: '/var/log/tldraw-backend-error.log',
      out_file: '/var/log/tldraw-backend-out.log',
      log_file: '/var/log/tldraw-backend-combined.log',
      time: true
    },
    {
      name: 'tldraw-frontend',
      cwd: './apps/frontend',
      script: 'node_modules/.bin/serve',
      args: '-s dist -l 3000',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      env: {
        NODE_ENV: 'production'
      },
      error_file: '/var/log/tldraw-frontend-error.log',
      out_file: '/var/log/tldraw-frontend-out.log',
      log_file: '/var/log/tldraw-frontend-combined.log',
      time: true
    }
  ]
}; 