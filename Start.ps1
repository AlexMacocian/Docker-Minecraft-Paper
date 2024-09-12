$containerName = "minecraft-server"
$imageName = "minecraft-paper:latest"

$container = docker ps -a --filter "name=$containerName" --format "{{.ID}}"
if ($container) {
    $isRunning = docker ps --filter "name=$containerName" --filter "status=running" --format "{{.ID}}"
    if ($isRunning) {
        Write-Host "The container '$containerName' is already running."
    } else {
        Write-Host "The container '$containerName' exists but is not running. Starting it..."
        docker start $containerName
    }
} else {
    Write-Host "The container '$containerName' does not exist. Creating it..."
    docker create --name $containerName `
        -p 25565:25565 `
        -p 8123:8123 `
        -v "$(pwd)/plugins:/minecraft/plugins" `
        -v "$(pwd)/logs:/minecraft/logs" `
        --restart unless-stopped `
        --health-cmd "nc -z localhost 25565 || exit 99" `
        --health-interval 30s `
        --health-timeout 10s `
        --health-retries 1 `
        $imageName

    Write-Host "Starting the container '$containerName'..."
    docker start $containerName
}

Write-Host "Server running at 25565..."
