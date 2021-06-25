module.exports = {
  apps : [{
    name: 'avoke-fork',
    cwd: '/home/admin/apps/avoke-fork',
    script: 'app.js',
    instance_var: 'INSTANCE_ID',
    out_file: '/home/admin/.pm2/logs/avoke-fork.log',
    err_file: '/home/admin/.pm2/logs/avoke-fork.log',
    exec_mode: 'fork',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    max_restarts: 100,
    restart_delay: 500,
    env: {
      NODE_ENV: 'production'
    }
  }]
};

