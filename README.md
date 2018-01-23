```
docker run --name ${appName} -v ${appPath}:/var/www/html -p 80:80 -d ${registry}/${repository}/${name}:${tag}
```