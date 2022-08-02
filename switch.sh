#!/usr/bin/env bash
backend_test_web_url="http://localhost:8080/api/status/check"
backend_web_message="App is running"
backend_node_process_message="Application started"
app_bootstrap_time_in_seconds=30

if grep -q 'proxy_pass http://green-backend;' ./ingress/conf.d/ingress.conf
then
    CURRENT_BACKEND="green-backend"
    NEW_BACKEND="blue-backend"
else
    CURRENT_BACKEND="blue-backend"
    NEW_BACKEND="green-backend"
fi

echo "Removing old \"$NEW_BACKEND\" container"
sudo docker compose rm -f -s -v $NEW_BACKEND

echo "Starting new \"$NEW_BACKEND\" container"
sudo docker compose up -d --build $NEW_BACKEND
rv=$?
if [ $rv -eq 0 ]; then
    echo "New \"$NEW_BACKEND\" container started"
else
    echo "Docker compose failed with exit code: $rv"
    echo "Aborting..."
    exit 1
fi

echo "Sleeping $app_bootstrap_time_in_seconds seconds before app will up"
sleep $app_bootstrap_time_in_seconds

echo "Checking \"$NEW_BACKEND\" container"
sudo docker logs $NEW_BACKEND | grep "$backend_node_process_message"
rv=$?
if [ $rv -eq 0 ]; then
    echo "New \"$NEW_BACKEND\" container passed http check"
else
    echo "\"$NEW_BACKEND\" container's check failed"
    echo "Aborting..."
    exit 1
fi

echo "Changing ingress config"
cp ./ingress/conf.d/ingress.conf ./ingress/conf.d/ingress.conf.back
sed -i "s|proxy_pass http://.*;|proxy_pass http://$NEW_BACKEND;|g" ./ingress/conf.d/ingress.conf

echo "Check ingress configs"
sudo docker exec -t ingress nginx -g 'daemon off; master_process on;' -t
rv=$?
if [ $rv -eq 0 ]; then
    echo "New ingress nginx config is valid"
else
    echo "New ingress nginx config is not valid"
    echo "Aborting..."
    cp ./ingress/conf.d/ingress.conf.back ./ingress/conf.d/ingress.conf
    exit 1
fi

echo "Reload ingress configs"
sudo docker exec -t ingress nginx -g 'daemon off; master_process on;' -s reload
rv=$?
if [ $rv -eq 0 ]; then
    echo "Ingress reloaded"
else
    echo "Ingress reloading is failed"
    echo "Aborting..."
    cp ./ingress/conf.d/ingress.conf.back ./ingress/conf.d/ingress.conf
    exit 1
fi

echo "Sleeping 2 seconds"
sleep 2

echo "Checking new ingress backend"
curl -s -A "Mozilla/5.0 (iPhone; CPU iPhone OS 6_1_3 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) CriOS/28.0.1500.12 Mobile/10B329 Safari/8536.25" $backend_test_web_url | grep "$backend_web_message"
rv=$?
if [ $rv -eq 0 ]; then
    echo "New ingress backend passed http check"
else
    echo "New ingress backend's check failed"
    echo "Aborting..."
    cp ./ingress/conf.d/ingress.conf.back ./ingress/conf.d/ingress.conf
    exit 1
fi

echo "Done!!!"
