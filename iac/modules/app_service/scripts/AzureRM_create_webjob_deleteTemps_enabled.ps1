  #####################################WEBJOB CREATION#################################################
    param($subscriptionId, $webapp, $rg)
         
    $zipName = "DeleteTempsFolder.zip"
    $zipPath = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, $zipName))     
    Connect-AzureRmAccount
    Select-AzureRmSubscription -SubscriptionId $subscriptionId

    $publishingCredentials = Invoke-AzureRmResourceAction -ResourceGroupName $rg -ResourceType Microsoft.Web/sites/config -ResourceName $webapp/publishingcredentials -Action list -ApiVersion 2015-08-01 -Force

    $cabecera = ("Basic {0}" -f 
        [Convert]::ToBase64String( 
            [Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $publishingCredentials.Properties.PublishingUserName, $publishingCredentials.Properties.PublishingPassword))))

    $Header = @{
        'Content-Disposition' = 'attachment; attachment; filename=Copy.zip'
        'Authorization'       = $cabecera
                }
    $apiUrl = "https://$webapp.scm.azurewebsites.net/api/triggeredwebjobs/DeleteTempsFolder"

    Invoke-RestMethod -Uri $apiUrl -Headers $Header -Method put -InFile $zipPath -ContentType 'application/zip'  