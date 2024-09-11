$containerName = "minecraft-server"
$container = docker ps -a --filter "name=$containerName" --format "{{.ID}}"
if ($container) {
    $isRunning = docker ps --filter "name=$containerName" --filter "status=running" --format "{{.ID}}"
    if ($isRunning) {
        Write-Host "The container '$containerName' is running. Stopping it..."
        docker stop $containerName
    } else {
        Write-Host "The container '$containerName' exists but is not running."
    }
} else {
    Write-Host "No container found with name: $containerName"
}

Write-Host "Stopped"
