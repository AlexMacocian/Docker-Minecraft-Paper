$containerName = "minecraft-server"
$imageName = "minecraft-paper:latest"

$container = docker ps -a --filter "name=$containerName" --format "{{.ID}}"
if ($container) {
    Write-Host "Stopping existing container: $containerName"
    docker stop $containerName
    Write-Host "Removing existing container: $containerName"
    docker rm $containerName
} else {
    Write-Host "No existing container found with name: $containerName"
}

$image = docker images --filter "reference=$imageName" --format "{{.ID}}"
if ($image) {
    Write-Host "Removing existing image: $imageName"
    docker rmi $imageName
} else {
    Write-Host "No existing image found with name: $imageName"
}

Write-Host "Building new image: $imageName"
docker build --no-cache -t $imageName .

Write-Host "Build completed successfully!"