#Install the Micrsoft Graph Powershell Module
Install-Module Microsoft.Graph -Scope AllUsers

#Connect To the Microsoft Graph
Connect-MgGraph -Scopes 'Group.Read.All'

#Get Groups that Are OnPremise Synced, Avoiding Office365 Groups

$props = "id","OnPremisesSamAccountName","OnPremisesSyncEnabled"
$Azure = Get-MgGroup -All -Property $props | select OnPremisesSamAccountName, OnPremisesSyncEnabled

# Get Active Directory Groups

$AD = get-adgroup -filter * 
# Parse the Groups and Place EntraID Display Name and Active Directory SamAccountName into an Array

$AZDN=$Azure.displayname
$ADDN=$AD.SamAccountName

# Compare EntraID to Active Directory, if a group is not in Active Directory, it is more than likely Orphaned 
$Groups = $AZDN  | where-object {$ADDN -NotContains $_}

# Obtain the EntraID Group ID, which is needed to delete the group
$objectid = foreach ($id in $Groups) {
    Get-MgGroup -filter "DisplayName eq '$id'" 
 }

# Put the ID into an Array
$objectid2=$objectid.Id

# Connect to EntraID and remove the groups
Connect-AzureAD

foreach ($id2 in $objectid2) {
    Remove-AzureADGroup -ObjectId "$id2"
 }

