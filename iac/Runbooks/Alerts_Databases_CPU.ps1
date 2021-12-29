$commandLine = $false
$actionGroupName = Get-AutomationVariable -Name 'actionGroupName'
$actionGroupResourceGroupName = Get-AutomationVariable -Name 'actionGroupResourceGroupName'
$thresholdAlert = Get-AutomationVariable -Name 'thresholdAlert'
$connectionName = Get-AutomationVariable -Name 'connectionName'
$numDB = 0
$numDBCreateAlert = 0
$filterDays = Get-AutomationVariable -Name 'filterDays'
#$checkAfterDate = Get-AutomationVariable -Name 'checkAfterDate'
#$initDate = Get-AutomationVariable -Name 'checkAfterDate'

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

function New-Sql-Cpu-Alert($alertName, $resourceGroupName, $targetResourceScope, $region){
    $condition = new-AzMetricAlertRuleV2Criteria `
        -MetricName "cpu_percent" `
        -MetricNameSpace "microsoft.sql/servers/databases" `
        -TimeAggregation Average `
        -Operator GreaterThan `
        -Threshold $thresholdAlert
    
    $actionGroup = Get-AzActionGroup `
        -Name $actionGroupName `
        -ResourceGroupName $actionGroupResourceGroupName
    $actionGroupId = New-AzActionGroup `
        -ActionGroupId $actionGroup.Id
    Add-AzMetricAlertRuleV2  `
        -Name $alertName `
        -ResourceGroupName $resourceGroupName `
        -TargetResourceScope $targetResourceScope `
        -TargetResourceType "microsoft.sql/servers/databases" `
        -TargetResourceRegion $region `
        -Description "avg Percentage CPU > $($thresholdAlert)" `
        -Severity 2 `
        -Condition $condition `
        -ActionGroup $actionGroupId `
        -WindowSize 0:5 `
        -Frequency 0:1
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
            -and $_.DatabaseName -like "Infolex*"`
            -and $_.CreationDate -ge (get-date).AddDays(-$filterDays) #`
            #-and $_.CreationDate -ge  [datetime]::ParseExact($checkAfterDate,'MM/dd/yyyy HH:mm:ss',$null)
            #-and $_.DatabaseName -eq "Infolex_azdevtest13_131313"             
        }        
        Select-Object -Property DatabaseName, ResourceGroupName, ResourceId, Location, CreationDate #|               
}
$databases_infolex=$databases_infolex | Sort-Object -Property CreationDate
# Para cada bbdd obtenemos las alertas existentes con criterio: cpu_percent
foreach ($database in $databases_infolex) {
     
     $AlertLst = Get-AzMetricAlertRuleV2 `
        -ResourceGroupName $database.ResourceGroupName |
        Where-Object { 
            $_.Scopes -contains $database.ResourceId `
            -and $_.Criteria.MetricName -eq "cpu_percent" 
        } 
     if ($AlertLst.Length -gt 0) {
         $numDB++
        # Esta bbdd ya tiene creada una alerta por cpu
        Write-Output "La base de datos $($database.DatabaseName) en RG: $($database.ResourceGroupName) ya tiene alerta.";        
     }
     else{
         
        Write-Output "Creando alerta para $($database.DatabaseName) en RG: $($database.ResourceGroupName)";
        New-Sql-Cpu-Alert `
            -alertName "AlertCpuBdd_$($database.DatabaseName)" `
            -resourceGroupName $database.ResourceGroupName `
            -targetResourceScope $database.ResourceId `
            -region $database.Location
        #Select-Object @{Name="CPU_Value";Expression={$_."Unit"}}, @{Name="Item";Expression={$_."Name"."Value"}}, @{Name="Tag";Expression={$_."Name"."LocalizedValue"}}, @{Name="Unit";Expression={$_."Unit"}}, @{Name="Type";Expression={$_."PrimaryAggregationType"}} 
        
        Write-Output "Alerta creada para $($database.DatabaseName)";
        $numDBCreateAlert++
     }
     Write-Output "La fecha de Creación de la BD es: $($database.CreationDate)"
     #Set-AutomationVariable -Name 'checkAfterDate' -Value $database.CreationDate
}
Write-Output "Se han creado $($numDBCreateAlert) alertas en las bases de datos creadas en los ultimos $filterDays días.";
Write-Output "Habia $($numDB) alertas creadas"; #desde el dia $($initDate)