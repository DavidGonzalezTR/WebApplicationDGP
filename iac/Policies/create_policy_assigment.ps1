# Get a reference to the resource group that is the scope of the assignment
$resource_groups = Get-AzResourceGroup -Tag @{'tr:application-asset-insight-id' = '202226' }
# Get a reference to the built-in policy definition to assign
$definition = Get-AzPolicySetDefinition -Id "/subscriptions/ae9490c2-d44e-43b7-b41b-5d50a3e31ae9/providers/Microsoft.Authorization/policySetDefinitions/95a5a240e290472293949958"

foreach ($rg in $resource_groups) {
    # Create the policy assignment with the built-in definition against your resource group
    $name = "iflx-preprod-rg-passigment-" + $rg.ResourceGroupName
    New-AzPolicyAssignment -Name $name -DisplayName $name -Scope $rg.ResourceId -PolicySetDefinition $definition
}