({
  host: '0.0.0.0',
  protocol: 'http',
  ports: [80],
  nagle: false,
  timeouts: {
    bind: 2000,
    start: 30000,
    stop: 5000,
    request: 5000,
    watch: 1000,
  },
  queue: {
    concurrency: 1000,
    size: 2000,
    timeout: 3000,
  },
  scheduler: {},
  workers: {
    pool: 0,
    wait: 2000,
    timeout: 5000,
  },
  cors: {
    origin: '*',
  },
});
