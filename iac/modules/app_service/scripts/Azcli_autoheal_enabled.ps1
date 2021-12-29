param($webapp, $rg)

az webapp config set -g $rg -n $webapp --generic-configurations "@AutoHealSettings.json"
