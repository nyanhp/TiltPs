﻿param($Request, $TriggerMetadata)
$endpoint = '/api/beer'
Write-Host "before $env:PSModulePath"
$p = "$((Resolve-Path -Path module).Path):$env:PSModulePath"
$env:PSModulePath = "$((Resolve-Path -Path module).Path):$env:PSModulePath"
Write-Host "after $env:PSModulePath"
try { [System.Environment]::SetEnvironmentVariable("PSModulePath", $p, "Machine") } catch {}
try { [System.Environment]::SetEnvironmentVariable("PSModulePath", $p, "User") } catch {}
try { [System.Environment]::SetEnvironmentVariable("PSModulePath", $p, "Process") } catch {}
Get-Module -ListAvailable
Import-Module Pode -Force -ErrorAction SilentlyContinue
Import-Module AutoBeerPs -Force -ErrorAction SilentlyContinue

Start-PodeServer -Request $TriggerMetadata -ServerlessType AzureFunctions {
    <#
    
    #>
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