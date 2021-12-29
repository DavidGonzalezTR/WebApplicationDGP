param($webapp, $rg)

az webapp config set -g $rg -n $webapp --auto-heal-enabled false