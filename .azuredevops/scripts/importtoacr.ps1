param(
    [String] $HelmScanningFolder
  )
$dependencies = Get-Content ..\dependencies.json -Raw | ConvertFrom-Json

foreach ($i in $dependencies){
    helm repo add $i.name $i.repo
}
helm repo update 


Write-Output "______________________________" + $HelmScanninFolder
foreach ($i in $dependencies){
    $reponame = $i.name
    foreach ($c in $i.charts){
        $chartName = $c.name
        $chartTag = $c.tag
        $command = "" + $reponame + "/"+ $chartName #+ " --version " + $c.tag 
        Write-Output  $command
        helm pull $command
        # tar zxvf $chartName + "-" + $chartTag + ".tgz"
    }
}
md $HelmScanninFolder

Get-ChildItem . -Filter *.tgz | Foreach-Object {
    Write-Output $_.FullName
    tar zxvf $_.FullName -C $HelmScanningFolder
}

docker pull bridgecrew/checkov
$path = pwd
docker run --tty --volume ($HelmScanninFolder):/tf --workdir /tf bridgecrew/checkov --directory /tf --output junitxml
$files = Get-ChildItem $HelmScanninFolder 

foreach ($file in $files){
      Write-Output $file.fullName
}
