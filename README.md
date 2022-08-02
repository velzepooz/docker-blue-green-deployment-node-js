# Docker blue-green deployment for Node.js app
Example of blue-green deployment with docker-compose


To start docker containers run:
```
./setup.sh 
```

To make blue-green deployment:
```
./switch.sh
```

To check if app is running during deployment:
```
curl -s http://localhost:8080/api/status/check | grep "App is running"
blue-backend
```

At ```switch.sh``` file we have some checks to ensure that container and up started after deployment.
So you need to add log to console that app is started and create api route to make http health check for app availability. You can follow examples at ```backend``` folder or find more smart way to do health checks.
