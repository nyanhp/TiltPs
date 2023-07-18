param($Request, $TriggerMetadata)
$endpoint = '/api/beer'

Start-PodeServer -Request $TriggerMetadata -ServerlessType AzureFunctions {
    <##>
    Import-PodeModule -Name AutoBeerPs

    Add-PodeRoute -Method Get -Path $endpoint -ScriptBlock {
        $beerParameter = @{}
        if ($WebEvent.Query['name'] -as [uint16])
        {
            $beerParameter.BeerId = $WebEvent.Query['name']
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

    Add-PodeRoute -Method Get -Path "$($endpoint)/:id" -ScriptBlock {
        $beer = Get-Beer -BeerId $WebEvent.Parameters['id']

        if (-not $beer)
        {
            Write-PodeTextResponse -Value 'No beer found' -StatusCode 404
        }
        Write-PodeJsonResponse -Value $beer
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

    Add-PodeRoute -Method Delete -Path "$($endpoint)/:id" -ScriptBlock {
        Remove-Beer -BeerId $WebEvent.Parameters['id']
    }
}