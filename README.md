```
docker run --name ${appName} -v ${appPath}:/var/www/html -p 80:80 -d ${image}:${tag}
```