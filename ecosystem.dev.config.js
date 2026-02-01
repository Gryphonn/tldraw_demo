module.exports = {
  apps: [
    {
      name: 'tldraw-backend-dev',
      cwd: './apps/backend',
      script: 'pnpm',
      args: 'dev',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '512M',
      node_args: '--max-old-space-size=512',
      env: {
        NODE_ENV: 'development'
      },
      error_file: '/var/log/tldraw-backend-dev-error.log',
      out_file: '/var/log/tldraw-backend-dev-out.log',
      time: true
    },
    {
      name: 'tldraw-frontend-dev',
      cwd: './apps/frontend',
      script: 'pnpm',
      args: 'dev --host 0.0.0.0',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '512M',
      node_args: '--max-old-space-size=512',
      env: {
        NODE_ENV: 'development'
      },
      error_file: '/var/log/tldraw-frontend-dev-error.log',
      out_file: '/var/log/tldraw-frontend-dev-out.log',
      time: true
    }
  ]
}; 