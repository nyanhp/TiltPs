﻿param($Request, $TriggerMetadata)
$endpoint = '/api/measurement'
$p = "$((Resolve-Path -Path modules).Path):$env:PSModulePath"
$env:PSModulePath = "$((Resolve-Path -Path modules).Path):$env:PSModulePath"

try { [System.Environment]::SetEnvironmentVariable("PSModulePath", $p, "Machine") } catch {}
try { [System.Environment]::SetEnvironmentVariable("PSModulePath", $p, "User") } catch {}
try { [System.Environment]::SetEnvironmentVariable("PSModulePath", $p, "Process") } catch {}
Import-Module Pode -Force
Import-Module AutoBeerPs

Start-PodeServer -Request $TriggerMetadata -ServerlessType AzureFunctions {
    Import-PodeModule -Name AutoBeerPs

    <#
{
"name": "Pumpkin Ale",
"color": "purple",
"temp_fahrenheit": 69,
"temp_celsius": 21,
"gravity": 1.035,
"alcohol_by_volume": 5.63,
"apparent_attenuation": 32.32
}
    #>

    Add-PodeRoute -Method Get -Path $endpoint -ScriptBlock {
        $beerParameter = @{}
        if ($WebEvent.Query['id'])
        {
            $beerParameter.BeerId = $WebEvent.Query['id']
        }
        else
        {
            Write-PodeTextResponse -Value "Invalid BeerId provided (hint: Must be numeric)" -StatusCode 400
            return
        }

        $measurements = Get-BeerMeasurementInfo @beerParameter

        Write-PodeJsonResponse -Value $measurements
    }

    Add-PodeRoute -Method Post -Path $endpoint -ScriptBlock {

        $beer = if ($WebEvent.Data['beerId'])
        {
            Get-Beer -BeerId $WebEvent.Data['beerId']
        }
        else
        {
            Get-Beer -Name $WebEvent.Data['name']
        }

        if (-not $beer)
        {
            $beerName = if ($WebEvent.Data['name']) { $WebEvent.Data['name'] } else { 'Beery McBeerface' }
            $id = New-Beer -Name $beerName -Style Altbier -BitternessUnits 30 -Color 200 -OriginalGravity 1.052 -Brewed (Get-Date) -BatchSizeLiters 20
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

    Add-PodeRoute -Method Put -Path $endpoint -ScriptBlock {

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

    Add-PodeRoute -Method Delete -Path $endpoint -ScriptBlock {

        if (-not (Get-BeerMeasurementInfo -MeasurementId $WebEvent.Data['id']))
        {
            Write-PodeTextResponse -Value "Measurement with id $($WebEvent.Data['id']) not found" -StatusCode 404
            return
        }

        Remove-BeerMeasurementInfo -MeasurementId $WebEvent.Data['id']
    }

    Add-PodeRoute -Method Delete -Path "$($endpoint)/:id" -ScriptBlock {

        if (-not (Get-BeerMeasurementInfo -MeasurementId $WebEvent.Parameters['id']))
        {
            Write-PodeTextResponse -Value "Measurement with id $($WebEvent.Parameters['id']) not found" -StatusCode 404
            return
        }

        Remove-BeerMeasurementInfo -MeasurementId $WebEvent.Parameters['id']
    }
}
