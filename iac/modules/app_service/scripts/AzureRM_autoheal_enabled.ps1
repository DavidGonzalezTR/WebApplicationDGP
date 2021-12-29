param($subscriptionId, $webapp, $rg)

#$subscriptionId = "Your_Subscription_Id"    # Your App's SubscriptionId
#$webapp = "App Name"                        # Your App's Name
#$rg = "Resource Group"                      # Your App's Resource Group
Connect-AzureRmAccount
Select-AzureRmSubscription -SubscriptionId $subscriptionId

$autohealRules = @{
triggers=@{StatusCodes=@(@{Status=500;count=5;timeInterval="00:01:00";path="/healthcheck"});};
actions=@{actionType="Recycle";minProcessExecutionTime="00:01:00"};
}

$PropertiesObject = @{
     autoHealEnabled = $true;
    autoHealRules = $autohealRules
}

Set-AzureRmResource -PropertyObject $PropertiesObject -ResourceGroupName $rg -ResourceType Microsoft.Web/sites/config -ResourceName "$webapp/web" -ApiVersion 2018-02-01 -Force