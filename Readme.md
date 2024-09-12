# Docker image for minecraft servers

**Requires docker and powershell**

## First run

- Run `Build.ps1` to build the image
- Run `mkdir plugins`
- Copy your plugins into `plugins` folder
- Run `Start.ps1`
- Run `Backup.ps1`
- Run `Stop.ps1`
- Edit your server files in the `backup` directory. *Edit stuff such as password, commands, etc.* **The container needs to exist for this to work**
- Run `Restore.ps1` to restore your modified files into the container. **The container needs to run for this to work**
- Run `Start.ps1`

## Script glossary

### `Build.ps1` to build the docker image
If the server is currently running, it will be stopped and rebuilt. **Any changes in the docker container will be lost. Backup your files before building**
### `Start.ps1` to start the server
### `Stop.ps1` to stop the server
### `Backup.ps1` to create a backup of the minecraft files
- If the container does not exist, backup will fail
- If the container exists, your files will be placed in `/backup/` folder
### `Restore.ps1` to restore your minecraft files onto the server
- If the container does not exist, restore will fail
- If the container exists, your files will be restored from `/backup/` folder to the server container