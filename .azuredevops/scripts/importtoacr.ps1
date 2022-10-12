param(
    [String] $HelmScanninFolder
  )
$dependencies = Get-Content ..\dependencies.json -Raw | ConvertFrom-Json

foreach ($i in $dependencies){
    helm repo add $i.name $i.repo
}
helm repo update 


Write-Output  $HelmScanninFolder
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
    tar zxvf $_.FullName -C $HelmScanninFolder
}

docker pull bridgecrew/checkov

Write-Output "($HelmScanninFolder)":/tf

docker run --tty --volume ${HelmScanninFolder}:/tf --workdir /tf bridgecrew/checkov --directory /tf --output junitxml > $HelmScanninFolder/Checkov-Report.xml
$files = Get-ChildItem $HelmScanninFolder 

foreach ($file in $files){
      Write-Output $file.fullName
}
