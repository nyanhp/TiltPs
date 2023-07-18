param($Request, $TriggerMetadata)
$endpoint = '/api/beer'

Start-PodeServer -Request $TriggerMetadata -ServerlessType AzureFunctions {
    <##>
    Import-PodeModule -Name AutoBeerPs

    Add-PodeRoute -Method Get -Path $endpoint -ScriptBlock {
        $beerParameter = @{}
        if ($WebEvent.Data['name'] -as [uint16])
        {
            $beerParameter.BeerId = $WebEvent.Data['name']
        }
        elseif ($WebEvent.Data['name'])
        {
            $beerParameter.Name = $WebEvent.Data['name']
        }

        $measurements = Get-Beer @beerParameter

        Write-PodeJsonResponse -Value $measurements
    }

    Add-PodeRoute -Method Get -Path "$($endpoint)/:id" -ScriptBlock {
        $measurements = Get-Beer -BeerId $WebEvent.Parameters['id']

        Write-PodeJsonResponse -Value $measurements
    }

    Add-PodeRoute -Method Post -Path $endpoint -ScriptBlock {
    }

    Add-PodeRoute -Method Put -Path $endpoint -ScriptBlock {
    }

    Add-PodeRoute -Method Delete -Path $endpoint -ScriptBlock {
    }
}