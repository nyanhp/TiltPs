using module AutoBeerPS
param($Request, $TriggerMetadata)
$endpoint = '/beer'

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

    Add-PodeRoute -Method Post -Path $endpoint -ScriptBlock {
        $apiKey = if ($WebEvent.Query['ApiKey'])
        {
            $WebEvent.Query['ApiKey']
        }
        elseif ($WebEvent.Data['ApiKey'])
        {
            $WebEvent.Data['ApiKey']
        }

        if (-not $apiKey)
        {
            Write-PodeTextResponse -Value "No ApiKey provided" -StatusCode 401
            return
        }

        if ($apiKey -ne $env:ApiKey)
        {
            Write-PodeTextResponse -Value "Invalid ApiKey provided" -StatusCode 401
            return
        }
    }

    Add-PodeRoute -Method Put -Path $endpoint -ScriptBlock {
        $apiKey = if ($WebEvent.Query['ApiKey'])
        {
            $WebEvent.Query['ApiKey']
        }
        elseif ($WebEvent.Data['ApiKey'])
        {
            $WebEvent.Data['ApiKey']
        }

        if (-not $apiKey)
        {
            Write-PodeTextResponse -Value "No ApiKey provided" -StatusCode 401
            return
        }

        if ($apiKey -ne $env:ApiKey)
        {
            Write-PodeTextResponse -Value "Invalid ApiKey provided" -StatusCode 401
            return
        }
    }

    Add-PodeRoute -Method Delete -Path $endpoint -ScriptBlock {
        $apiKey = if ($WebEvent.Query['ApiKey'])
        {
            $WebEvent.Query['ApiKey']
        }
        elseif ($WebEvent.Data['ApiKey'])
        {
            $WebEvent.Data['ApiKey']
        }

        if (-not $apiKey)
        {
            Write-PodeTextResponse -Value "No ApiKey provided" -StatusCode 401
            return
        }

        if ($apiKey -ne $env:ApiKey)
        {
            Write-PodeTextResponse -Value "Invalid ApiKey provided" -StatusCode 401
            return
        }
    }
}