$containerName = "minecraft-server"
$backupDir = "$(pwd)/backup"

if (-not (Test-Path -Path $backupDir)) {
    Write-Host "Creating backup directory: $backupDir"
    New-Item -ItemType Directory -Path $backupDir
}

$container = docker ps -a --filter "name=$containerName" --format "{{.ID}}"
if (-not $container) {
    Write-Host "The container $containerName does not exist. Cannot proceed with backup."
    exit
}

$itemsToBackup = @(
    "/minecraft/banned-ips.json",
    "/minecraft/banned-players.json",
    "/minecraft/bukkit.yml",
    "/minecraft/help.yml",
    "/minecraft/commands.yml",
    "/minecraft/ops.json",
    "/minecraft/permissions.yml",
    "/minecraft/server.properties",
    "/minecraft/spigot.yml",
    "/minecraft/usercache.json",
    "/minecraft/whitelist.json",
    "/minecraft/world",
    "/minecraft/world_nether",
    "/minecraft/world_the_end"
)

foreach ($item in $itemsToBackup) {
    $itemName = [System.IO.Path]::GetFileName($item)
    $destination = "$backupDir/$itemName"
    Write-Host "Backing up $item to $destination"
    if ($item -like "*/world*" -or $item -eq "/minecraft/world" -or $item -eq "/minecraft/world_nether" -or $item -eq "/minecraft/world_the_end") {
        Write-Host "Backing up directory $item"
        docker cp "$($containerName):$($item)" "$($backupDir)/"
    } else {
        Write-Host "Backing up file $item"
        docker cp "$($containerName):$($item)" "$($destination)"
    }
}

Write-Host "Backup completed successfully."
