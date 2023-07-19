param($Request, $TriggerMetadata)
$endpoint = '/api/beer'
$env:PSModulePath = "$((Resolve-Path -Path ./Modules).Path):$env:PSModulePath"

Import-Module -Force Pode
Import-Module -Force AutoBeerPs
Start-PodeServer -Request $TriggerMetadata -ServerlessType AzureFunctions {
    <##>
    Import-PodeModule -Name AutoBeerPs

    Add-PodeRoute -Method Get -Path $endpoint -ScriptBlock {
        $beerParameter = @{}
        if ($WebEvent.Query['id'])
        {
            $beerParameter.BeerId = $WebEvent.Query['id']
        }
        elseif ($WebEvent.Query['name'])
        {
            $beerParameter.Name = $WebEvent.Query['name']
        }

        $beers = Get-Beer @beerParameter

        if (-not $beers)
        {
            Write-PodeTextResponse -Value 'No beers found' -StatusCode 404
        }

        Write-PodeJsonResponse -Value $beers
    }

    Add-PodeRoute -Method Post -Path $endpoint -ScriptBlock {
        $splat = $WebEvent.Data
        $beerId = New-Beer @splat
        Write-PodeJsonResponse -Value (Get-Beer -BeerId $beerId)
    }

    Add-PodeRoute -Method Put -Path $endpoint -ScriptBlock {
        $splat = $WebEvent.Data
        $beerId = Set-Beer @splat
        Write-PodeJsonResponse -Value (Get-Beer -BeerId $beerId)
    }

    Add-PodeRoute -Method Delete -Path $endpoint -ScriptBlock {
        Remove-Beer -BeerId $WebEvent.Query['id']
    }
}