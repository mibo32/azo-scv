$dependencies = Get-Content ..\dependencies.json -Raw | ConvertFrom-Json

foreach ($i in $dependencies){
    helm repo add $i.name $i.repo
}
helm repo update 

$helmScanning = $env:HelmScanning
foreach ($i in $dependencies){
    $reponame = $i.name
    foreach ($c in $i.charts){
        $chartName = $c.name
        $chartTag = $c.tag
        $command = "" + $reponame + "/"+ $chartName + " --version " + $c.tag 
        Write-Output  $command
        helm pull $command
        # tar zxvf $chartName + "-" + $chartTag + ".tgz"
    }
}
md $helmScanning

Get-ChildItem . -Filter *.tgz | Foreach-Object {
    Write-Output $_.FullName
    tar zxvf $_.FullName -C $helmScanning
}

docker pull bridgecrew/checkov
$path = pwd
docker run --tty --volume ($helmScanning):/tf --workdir /tf bridgecrew/checkov --directory /tf --output junitxml --skip-download

$files = Get-ChildItem $helmScanning 

foreach ($file in $files){
    start-process -FilePath $file.fullName -Verb Print
}
