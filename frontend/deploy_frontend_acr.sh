az acr login --name moneta.azurecr.io
docker build --tag abertaga27/moneta-ai-frontend:v1.1.3 .
docker tag abertaga27/moneta-ai-frontend:v1.1.3 moneta.azurecr.io/moneta-ai-frontend:v1.1.3
docker push moneta.azurecr.io/moneta-ai-frontend:v1.1.3