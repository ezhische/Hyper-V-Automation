param(
    [ValidateScript({
        $existingVm = Get-VM -Name $_ -ErrorAction SilentlyContinue
        if ($existingVm) {
            return $True
        }
        throw "There no VM named '$_' in this server."
        
    })]
    [Parameter(Mandatory=$true)]
    [string]$VMName
)
$VM=Get-VM $VMName
$VHDPath = Get-VHD -VMId $VM.VMId

if ($VM.State -eq "Running") {
    Write-Host "Stoping VM..."
    Stop-VM -Name $VMName -Confirm -Force
}
if ($VM.IsClustered) {
    Remove-ClusterGroup -VMId $VM.VMId -RemoveResources
    Remove-VM -Name $VMName
}
else{
    Remove-VM -Name $VMName
}
#Check if VM Deleted
$existingVm = Get-VM -Name $VMName -ErrorAction SilentlyContinue
$confPath =  Join-Path $VM.Path "$VMName"
if (-not $existingVm){
    $VHDPath|ForEach-Object {
        Remove-Item $_.Path
    }
    Remove-Item -Path $VM.Path -Force
}