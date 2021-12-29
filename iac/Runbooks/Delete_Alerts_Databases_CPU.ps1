$commandLine = $false
$connectionName = Get-AutomationVariable -Name 'connectionName'
$numDBRemoveAlert = 0
function Connect-Azure() {
    if (!$commandLine) {
        $servicePrincipalConnection = Get-AutomationConnection -Name $connectionName
        Connect-AzAccount `
            -ServicePrincipal `
            -Tenant $servicePrincipalConnection.TenantId `
            -ApplicationId $servicePrincipalConnection.ApplicationId `
            -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint
    }
}
Connect-Azure

function Remove-Sql-Cpu-Alert($alertName, $resourceGroupName){

    Remove-AzMetricAlertRuleV2  `
        -Name $alertName `
        -ResourceGroupName $resourceGroupName `

}
function PrintAlerts($alerts){
    foreach ($alert in $alerts) {
         Write-Output $alert;
         Write-Output "-----------";
         Write-Output $alert.Criteria;
         Write-Output "-----------";
         Write-Output "Alerta: $($alert)";
    }
}

$databases_infolex= @()
$AlertLst = @()
# Obtenemos todas las bbdd que están en una elastic pool y que comienzan por Infolex
$sql_servers = Get-AzSqlServer
foreach ($sql_server in $sql_servers) {
    $databases_infolex += Get-AzSqlDatabase `
        -ServerName $sql_server.ServerName `
        -ResourceGroupName $sql_server.ResourceGroupName | 
        Where-Object { 
            $_.ElasticPoolName -ne $null `
            -and $_.DatabaseName -like "Infolex*"
        } 
        Select-Object -Property DatabaseName, ResourceGroupName, ResourceId, Location 
}
# Para cada bbdd obtenemos las alertas existentes con criterio: cpu_percent
foreach ($database in $databases_infolex) {
     
     $AlertLst = Get-AzMetricAlertRuleV2 `
        -ResourceGroupName $database.ResourceGroupName |
        Where-Object { 
            $_.Scopes -contains $database.ResourceId `
            -and $_.Criteria.MetricName -eq "cpu_percent" 
        } 
     if ($AlertLst.Length -gt 0) {
        Write-Output "Eliminando alerta para $($database.DatabaseName)";
        Remove-Sql-Cpu-Alert `
            -alertName "AlertCpuBdd_$($database.DatabaseName)" `
            -resourceGroupName $database.ResourceGroupName
     
        Write-Output "Alerta eliminada para $($database.DatabaseName)";
         $numDBRemoveAlert++
     }
     
}
Write-Output "Se han eliminado $($numDBRemoveAlert) alertas.";