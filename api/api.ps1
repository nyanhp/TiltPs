$endpoint = '/api/beer'
$endpointMeasure = '/api/measurement'
Start-PodeServer {
    <##>
    Import-PodeModule -Name AutoBeerPs
    Add-PodeEndpoint -Port 8080 -Protocol http

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

    Add-PodeRoute -Method Get -Path $endpointMeasure -ScriptBlock {
        $beerParameter = @{}
        if ($WebEvent.Data['name'] -as [uint16])
        {
            $beerParameter.BeerId = $WebEvent.Data['name']
        }
        else
        {
            Write-PodeTextResponse -Value "Invalid BeerId provided (hint: Must be numeric)" -StatusCode 400
            return
        }

        $measurements = Get-BeerMeasurementInfo @beerParameter

        Write-PodeJsonResponse -Value $measurements
    }

    Add-PodeRoute -Method Post -Path $endpointMeasure -ScriptBlock {

        $beer = if ($WebEvent.Data['name'] -as [uint16])
        {
            Get-Beer -BeerId $WebEvent.Data['name']
        }
        else
        {
            Get-Beer -Name $WebEvent.Data['name']
        }

        if (-not $beer)
        {
            $id = New-Beer -Name $WebEvent.Data['name'] -Style Altbier -BitternessUnits 30 -Color 200 -OriginalGravity 1.052 -Brewed (Get-Date) -BatchSizeLiters 20
            $beer = Get-Beer -BeerId $id
        }

        $measurementSplat = @{
            BeerId                = $beer.Id
            TiltColor             = $WebEvent.Data['color']
            TemperatureFahrenheit = $WebEvent.Data['temp_fahrenheit']
            SpecificGravity       = $WebEvent.Data['gravity']
            Timestamp             = (Get-Date)
            Comment               = "Apparent Attenuation: $($WebEvent.Data['apparent_attenuation'])"
        }
        New-BeerMeasurementInfo @measurementSplat
    }

    Add-PodeRoute -Method Put -Path $endpointMeasure -ScriptBlock {

        if (-not (Get-Beer -BeerId $WebEvent.Data['beerid']))
        {
            Write-PodeTextResponse -Value "Beer with id $($WebEvent.Data['beerid']) not found" -StatusCode 404
            return
        }

        if (-not (Get-BeerMeasurementInfo -MeasurementId $WebEvent.Data['measurementid']))
        {
            Write-PodeTextResponse -Value "Measurement with id $($WebEvent.Data['measurementid']) not found" -StatusCode 404
            return
        }

        $measurementSplat = @{
            MeasurementId         = $WebEvent.Data['measurementid']
            BeerId                = $WebEvent.Data['beerid']
            TiltColor             = $WebEvent.Data['color']
            TemperatureFahrenheit = $WebEvent.Data['temp_fahrenheit']
            SpecificGravity       = $WebEvent.Data['gravity']
            Timestamp             = if ($WebEvent.Data['timestamp']) { $WebEvent.Data['timestamp'] } else { (Get-Date) }
            Comment               = "Apparent Attenuation: $($WebEvent.Data['apparent_attenuation'])"
        }

        $null = Set-BeerMeasurementInfo @measurementSplat
    }

    Add-PodeRoute -Method Delete -Path $endpointMeasure -ScriptBlock {

        if (-not (Get-BeerMeasurementInfo -MeasurementId $WebEvent.Data['measurementid']))
        {
            Write-PodeTextResponse -Value "Measurement with id $($WebEvent.Data['measurementid']) not found" -StatusCode 404
            return
        }

        Remove-BeerMeasurementInfo -MeasurementId $WebEvent.Data['measurementid']
    }
}