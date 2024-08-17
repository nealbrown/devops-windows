$DockerDesktopPath = "C:\Program Files\Docker\Docker\Docker Desktop.exe"
$entrypoint = "docker-entrypoint.sh"

Write-Host -ForegroundColor Green 'Starting Docker Desktop'
Start-Process $DockerDesktopPath

Write-Host -ForegroundColor Green 'Checking SSH Keys'
Get-ChildItem -Path $env:USERPROFILE\.ssh

if(!(Test-Path $env:USERPROFILE\.ssh\id_rsa.pub -PathType Leaf))
{
    Write-Host -ForegroundColor Yellow "Public Key not found in $env:USERPROFILE\.ssh. Run ssh-keygen.exe and retry."
    Exit 1

}
if(!(Test-Path $env:USERPROFILE\.ssh\id_rsa -PathType Leaf))
{
    Write-Host -ForegroundColor Yellow "Private Key not found in $env:USERPROFILE\.ssh. Run ssh-keygen.exe and retry."
    Exit 1
}
Write-Host -ForegroundColor Green 'Stripping CRs from entrypoint shell script.'
((Get-Content $entrypoint) -join "`n") + "`n" | Set-Content -NoNewline $entrypoint

docker build --progress=plain -t heb/debian-ansible ${PWD}
docker run -it -v .:/ansible -v $env:USERPROFILE\.ssh:/tmp/.ssh:ro heb/debian-ansible /bin/bash