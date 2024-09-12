$containerName = "minecraft-server"
$backupDir = "$(pwd)/backup"

if (-not (Test-Path -Path $backupDir)) {
    Write-Host "Backup directory does not exist: $backupDir"
    exit
}

$container = docker ps -a --filter "name=$containerName" --format "{{.ID}}"
if (-not $container) {
    Write-Host "The container $containerName does not exist. Cannot proceed with restore."
    exit
}

$container = docker ps --filter "name=$containerName" --filter "status=running" --format "{{.ID}}"
if ($container) {
    Write-Host "Stopping the running container: $containerName"
    docker stop $containerName
} else {
    Write-Host "The container $containerName is not running."
}

$itemsToRestore = @(
    "banned-ips.json",
    "banned-players.json",
    "bukkit.yml",
    "help.yml",
    "commands.yml",
    "ops.json",
    "permissions.yml",
    "server.properties",
    "spigot.yml",
    "usercache.json",
    "whitelist.json",
    "version_history.json",
    "config",
    "world",
    "world_nether",
    "world_the_end"
)

foreach ($item in $itemsToRestore) {
    $source = "$backupDir/$item"
    $destination = "/minecraft/$item"
    Write-Host "Restoring $item from $source to $destination"
    if (Test-Path $source) {
        if ((Get-Item $source).PSIsContainer) {
            Write-Host "Restoring directory $item"
            docker cp "$source" "$($containerName):/minecraft"
        } else {
            Write-Host "Restoring file $item"
            docker cp "$source" "$($containerName):$destination"
        }
    } else {
        Write-Host "File or directory $item does not exist in the backup."
    }
}

Write-Host "Starting the container: $containerName"
docker start $containerName

Write-Host "Restore and restart completed successfully."
