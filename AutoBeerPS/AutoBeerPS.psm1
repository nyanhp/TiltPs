# nothing to see here
enum BeerStyle
{    
    Altbier
    AmberAle
    BarleyWine
    BerlinerWeisse
    BiereDeGarde        
    Bitter
    Bock
    BrownAle
    SteamBeer
    CreamAle
    Export
    Doppelbock
    Dunkel
    DunkelWeizen
    Eisbock
    RedBeers
    Geuze
    Hefeweizen
    Hell
    IndiaPaleAle
    Kolsch
    Lambic
    LightAle
    Maibock
    MaltLiquor
    Mild
    Marzen
    OldAle
    BrownBeers
    PaleAle
    Pilsener
    Porter
    RedAle
    RyeAle
    Saison
    ScotchAle
    SweetStout
    DryStout
    ImperialStout
    Schwarzbier
    Vienna
    Witbier
    Weissbier
    Weizenbock
}

class Beer
{
    [uint16] $Id
    [string] $Name
    [BeerStyle] $Style
    [datetime] $Brewed
    [datetime] $Bottled
    [uint16] $TotalBottles
    [uint16] $RemainingBottles
    [uint16] $BatchSizeLiters
    [uint16] $BitternessUnits
    [uint16] $Color
    [double] $OriginalGravity
    [double] $FinalGravity
    [BeerMeasurementInfo[]] $Measurements

    Beer ()
    {
        $this | Add-Member -Name OriginalGravityPlato -MemberType ScriptProperty -Value {
            return (668.72 * $this.OriginalGravity) - 463.37 - (205.347 * [Math]::Pow($this.OriginalGravity, 2))
        }

        $this | Add-Member -Name AlcoholMeasured -MemberType ScriptProperty -Value {
            # If measurements are available, take latest measurement
            if ($this.Measurements.Count -gt 0)
            {
                $latestMeasurement = $this.Measurements | Sort-Object -Property Timestamp -Descending | Select-Object -First 1
                return ($this.OriginalGravity - $latestMeasurement.SpecificGravity) * 131.25
            }

            return ($this.OriginalGravity - $this.FinalGravity) * 131.25
        }
    }
}

class BeerMeasurementInfo
{
    [string] $TiltColor
    [DateTime] $Timestamp
    [double] $SpecificGravity
    [double] $TemperatureFahrenheit
    [string] $Comment
    [uint16] $Id
    [uint16] $BeerId

    BeerMeasurementInfo ()
    {
        $this | Add-Member -Name TemperatureCelsius -MemberType ScriptProperty -Value {
            # Override get
            return (($this.TemperatureFahrenheit - 32) * 5 / 9)
        }
    }

    [int] CompareTo($other)
    {
        if ($other.Id -eq $this.Id) { return 1 }

        return $this.Id.CompareTo($other.Id)
    }

    [bool] Equals($other)
    {
        if ($null -eq $other) { return $false }

        return $this.Id.Equals($other.Id)
    }
}

<#
CRUD: Beer
#>
function New-Beer
{
    [OutputType([uint16])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string] $Name,
        
        [Parameter(Mandatory = $true)]
        [BeerStyle] $Style,

        [Parameter(Mandatory = $true)]
        [uint16] $BitternessUnits,

        [Parameter(Mandatory = $true)]
        [uint16] $Color,

        [Parameter(Mandatory = $true)]
        [double] $OriginalGravity,

        [datetime] $Brewed = (Get-Date),

        [datetime] $Bottled = (Get-Date),

        [uint16] $TotalBottles,

        [uint16] $RemainingBottles,

        [uint16] $BatchSizeLiters,

        [double] $FinalGravity
    )

    # Insert into database
    $sqlConnection = New-Object System.Data.SqlClient.SqlConnection
    $sqlConnection.ConnectionString = $env:SqlConnectionString

    try
    {
        $sqlConnection.Open()

        $parameters = [System.Collections.ArrayList]::new()
        $null = $parameters.Add((New-Object System.Data.SqlClient.SqlParameter("@Name", $Name)))
        $null = $parameters.Add((New-Object System.Data.SqlClient.SqlParameter("@Style", $Style)))
        $null = $parameters.Add((New-Object System.Data.SqlClient.SqlParameter("@BitternessUnits", [int16]$BitternessUnits)))
        $null = $parameters.Add((New-Object System.Data.SqlClient.SqlParameter("@Color", [int16]$Color)))
        $null = $parameters.Add((New-Object System.Data.SqlClient.SqlParameter("@OriginalGravity", $OriginalGravity)))        
        $null = $parameters.Add((New-Object System.Data.SqlClient.SqlParameter("@Brewed", $Brewed)))
        $null = $parameters.Add((New-Object System.Data.SqlClient.SqlParameter("@Bottled", $Bottled)))         
        $null = $parameters.Add((New-Object System.Data.SqlClient.SqlParameter("@TotalBottles", [int16]$TotalBottles)))    
        $null = $parameters.Add((New-Object System.Data.SqlClient.SqlParameter("@RemainingBottles", [int16]$RemainingBottles)))
        $null = $parameters.Add((New-Object System.Data.SqlClient.SqlParameter("@BatchSizeLitres", [int16]$BatchSizeLiters)))
        $null = $parameters.Add((New-Object System.Data.SqlClient.SqlParameter("@FinalGravity", $FinalGravity)))
        #$outParam = New-Object System.Data.SqlClient.SqlParameter("@Id", [System.Data.SqlDbType]::SmallInt)
        #$outParam.Direction = [System.Data.ParameterDirection]::Output
        #$null = $parameters.Add($outParam)

        $sqlCommand = New-Object System.Data.SqlClient.SqlCommand
        $sqlCommand.Connection = $sqlConnection
        $sqlCommand.Parameters.AddRange($parameters.ToArray())

        # Insert and return inserted ID
        $sqlCommand.CommandText = 'INSERT INTO dbo.Beer (Name, Style, BitternessUnits, Color,OriginalGravity,Brewed, Bottled,TotalBottles,RemainingBottles, BatchSizeLitres,FinalGravity) VALUES (@Name, @Style, @BitternessUnits, @Color,@OriginalGravity,@Brewed, @Bottled,@TotalBottles,@RemainingBottles, @BatchSizeLitres,@FinalGravity); SELECT SCOPE_IDENTITY();'
        $sqlCommand.ExecuteScalar()
    }
    catch
    {
        Write-Error -Message "Unable to add new beer." -Exception $_.Exception
    }
    finally
    {
        $sqlConnection.Close()
    }
}

function Get-Beer
{
    [CmdletBinding(DefaultParameterSetName = 'Id')]
    param
    (
        [Parameter(ParameterSetName = 'Id')]
        [uint16] $BeerId,

        [Parameter(ParameterSetName = 'Name')]
        [string] $Name
    )

    # Retrieve all beers
    $sqlConnection = New-Object System.Data.SqlClient.SqlConnection
    $sqlConnection.ConnectionString = $env:SqlConnectionString

    try
    {
        $sqlConnection.Open()
        
        $parameters = [System.Collections.ArrayList]::new()
        $null = $parameters.Add((New-Object System.Data.SqlClient.SqlParameter("@Id", [int16]$BeerId)))
        $null = $parameters.Add((New-Object System.Data.SqlClient.SqlParameter("@Name", $Name)))

        $sqlCommand = New-Object System.Data.SqlClient.SqlCommand
        $sqlCommand.Connection = $sqlConnection
        $sqlCommand.Parameters.AddRange($parameters.ToArray())

        # Insert and return inserted ID
        $sqlCommand.CommandText = 'SELECT * FROM dbo.Beer'
        if ($BeerId )
        {
            $sqlCommand.CommandText += "`r`nWHERE beer.Id = @Id;"
        }

        if ($Name)
        {
            $sqlCommand.CommandText += "`r`nWHERE beer.Name = @Name;"
        }

        $dataSet = New-Object System.Data.DataSet
        $dataTable = New-Object System.Data.DataTable
        $dataTable.Load($sqlCommand.ExecuteReader())
        $dataSet.Tables.Add($dataTable)

        foreach ($row in $dataSet.Tables.Rows)
        {
            $beer = [Beer]@{
                Id               = $row.Id
                Name             = $row.Name
                Style            = $row.Style
                BitternessUnits  = $row.BitternessUnits
                Color            = $row.Color
                OriginalGravity  = $row.OriginalGravity
                Brewed           = $row.Brewed
                Bottled          = $row.Bottled
                TotalBottles     = $row.TotalBottles
                RemainingBottles = $row.RemainingBottles
                BatchSizeLiters  = $row.BatchSizeLiters
                FinalGravity     = $row.FinalGravity
            }

            $beer.Measurements = Get-BeerMeasurementInfo -BeerId $row.Id
            $beer
        }
    }
    catch
    {

    } 
    finally
    {

    }
}

function Set-Beer
{
    [OutputType([uint16])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [uint16]
        $BeerId,

        [string] $Name,

        [BeerStyle] $Style,

        [uint16] $BitternessUnits,

        [uint16] $Color,

        [double] $OriginalGravity,

        [datetime] $Brewed,

        [datetime] $Bottled,

        [uint16] $TotalBottles,

        [uint16] $RemainingBottles,

        [uint16] $BatchSizeLiters,

        [double] $FinalGravity
    )

    # Insert into database
    $sqlConnection = New-Object System.Data.SqlClient.SqlConnection
    $sqlConnection.ConnectionString = $env:SqlConnectionString

    try
    {
        $sqlConnection.Open()

        $sqlCommand = New-Object System.Data.SqlClient.SqlCommand
        $sqlCommand.Connection = $sqlConnection

        # Update measurement
        $sb = [System.Text.StringBuilder]::new()
        $null = $sb.AppendLine("UPDATE dbo.Beer SET")
        $isFirst = $true

        foreach ($boundParam in $PSBoundParameters.GetEnumerator())
        {
            if ($boundParam.Key -in 'BeerId', 'ErrorAction', 'ErrorVariable', 'OutVariable', 'OutBuffer', 'WarningAction', 'WarningVariable', 'Verbose', 'Debug', 'InformationVariable', 'InformationAction') { continue }

            $formatedValue = if ($boundParam.Value -is [string] -or $boundParam.Value -is [datetime])
            {
                "'$($boundParam.Value)'"
            }
            elseif ($boundParam.Value -is [enum])
            {
                $boundParam.Value.ToString()
            }
            elseif ($boundParam.Value -is [uint16])
            {
                [int16]$boundParam.Value
            }
            else
            {
                $boundParam.Value
            }
    
            if ($isFirst)
            {
                $null = $sb.AppendLine("$($boundParam.Key) = $formatedValue")
                $isFirst = $false
                continue
            }

            $null = $sb.AppendLine(",$($boundParam.Key) = $($boundParam.Value)")
        }

        $null = $sb.AppendLine("WHERE Id = $BeerId;")

        $sqlCommand.CommandText = $sb.ToString()
        $null = $sqlCommand.ExecuteScalar()
    }
    catch
    {
        Write-Error -Message "Unable to update beer." -Exception $_.Exception
    }
    finally
    {
        $sqlConnection.Close()
    }
}

function Remove-Beer
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [uint16] $BeerId
    )

    # Remove element from database
    $sqlConnection = New-Object System.Data.SqlClient.SqlConnection
    $sqlConnection.ConnectionString = $env:SqlConnectionString

    try
    {
        $sqlConnection.Open()

        $sqlCommand = New-Object System.Data.SqlClient.SqlCommand
        $sqlCommand.Connection = $sqlConnection

        # Remove Beer
        $measurements = Get-BeerMeasurementInfo -BeerId $BeerId
        foreach ($measurement in $measurements)
        {
            Remove-BeerMeasurementInfo -MeasurementId $measurement.Id
        }
        $sqlCommand.CommandText = "DELETE FROM dbo.Beer WHERE Id = $BeerId;"
        $null = $sqlCommand.ExecuteScalar()
    }
    catch
    {
        Write-Error -Message "Unable to remove beer." -Exception $_.Exception
    }
    finally
    {
        $sqlConnection.Close()
    }
}

<#
CRUD: BeerMeasurementInfo
#>
function New-BeerMeasurementInfo
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [uint16] $BeerId, 
        [Parameter(Mandatory = $true)]
        [string] $TiltColor,

        [Parameter(Mandatory = $true)]
        [double] $SpecificGravity,

        [Parameter(Mandatory = $true)]
        [double] $TemperatureFahrenheit,

        [DateTime] $Timestamp = (Get-Date),

        [string] $Comment        
    )

    if (-not (Get-Beer -BeerId $BeerId))
    {
        Write-Error -Message "Beer with ID $BeerId does not exist."
        return
    }

    # Insert into database
    $sqlConnection = New-Object System.Data.SqlClient.SqlConnection
    $sqlConnection.ConnectionString = $env:SqlConnectionString

    try
    {
        $sqlConnection.Open()

        $parameters = [System.Collections.ArrayList]::new()
        $null = $parameters.Add((New-Object System.Data.SqlClient.SqlParameter("@BeerId", [int16]$BeerId)))
        $null = $parameters.Add((New-Object System.Data.SqlClient.SqlParameter("@TiltColor", $TiltColor)))
        $null = $parameters.Add((New-Object System.Data.SqlClient.SqlParameter("@SpecificGravity", $SpecificGravity)))
        $null = $parameters.Add((New-Object System.Data.SqlClient.SqlParameter("@TemperatureFahrenheit", $TemperatureFahrenheit)))
        $null = $parameters.Add((New-Object System.Data.SqlClient.SqlParameter("@Timestamp", $Timestamp)))
        $null = $parameters.Add((New-Object System.Data.SqlClient.SqlParameter("@Comment", $Comment)))

        $sqlCommand = New-Object System.Data.SqlClient.SqlCommand
        $sqlCommand.Connection = $sqlConnection
        $sqlCommand.Parameters.AddRange($parameters.ToArray())

        # Insert and return inserted ID
        $sqlCommand.CommandText = 'INSERT INTO dbo.Measurement (BeerId, TiltColor, SpecificGravity, TemperatureFahrenheit, Timestamp, Comment) VALUES (@BeerId, @TiltColor, @SpecificGravity, @TemperatureFahrenheit, @Timestamp, @Comment); SELECT SCOPE_IDENTITY();'
        $sqlCommand.ExecuteScalar()
    }
    catch
    {
        Write-Error -Message "Unable to add new beer measurement." -Exception $_.Exception
    }
    finally
    {
        $sqlConnection.Close()
    }
}

function Get-BeerMeasurementInfo
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [uint16] $BeerId
    )

    # Retrieve all measurements for a beer
    $sqlConnection = New-Object System.Data.SqlClient.SqlConnection
    $sqlConnection.ConnectionString = $env:SqlConnectionString

    try
    {
        $sqlConnection.Open()
        
        $parameters = [System.Collections.ArrayList]::new()
        $null = $parameters.Add((New-Object System.Data.SqlClient.SqlParameter("@BeerId", [int16]$BeerId)))

        $sqlCommand = New-Object System.Data.SqlClient.SqlCommand
        $sqlCommand.Connection = $sqlConnection
        $sqlCommand.Parameters.AddRange($parameters.ToArray())

        # Insert and return inserted ID
        $sqlCommand.CommandText = 'SELECT * FROM dbo.Measurement WHERE BeerId = @BeerId;'
        $dataSet = New-Object System.Data.DataSet
        $dataTable = New-Object System.Data.DataTable
        $dataTable.Load($sqlCommand.ExecuteReader())
        $dataSet.Tables.Add($dataTable)

        foreach ($row in $dataSet.Tables.Rows)
        {
            [BeerMeasurementInfo]@{
                Id                    = $row.Id
                BeerId                = $row.BeerId
                TiltColor             = $row.TiltColor
                SpecificGravity       = $row.SpecificGravity
                TemperatureFahrenheit = $row.TemperatureFahrenheit
                Timestamp             = $row.Timestamp
                Comment               = $row.Comment
            }
        }
    }
    catch
    {
        Write-Error -Message "Unable to add new beer measurement." -Exception $_.Exception
    }
    finally
    {
        $sqlConnection.Close()
    }
}

function Set-BeerMeasurementInfo
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [uint16] $MeasurementId, 

        [uint16] $BeerId, 

        [string] $TiltColor,

        [double] $SpecificGravity,

        [double] $TemperatureFahrenheit,

        [DateTime] $Timestamp,

        [string] $Comment        
    )

    # Insert into database
    $sqlConnection = New-Object System.Data.SqlClient.SqlConnection
    $sqlConnection.ConnectionString = $env:SqlConnectionString

    if (-not $BeerId -and -not $TiltColor -and -not $SpecificGravity -and -not $TemperatureFahrenheit -and -not $Timestamp -and -not $Comment)
    {
        Write-Error -Message "No parameters specified to update beer measurement."
        return
    }

    try
    {
        $sqlConnection.Open()

        $sqlCommand = New-Object System.Data.SqlClient.SqlCommand
        $sqlCommand.Connection = $sqlConnection

        # Update measurement
        $sb = [System.Text.StringBuilder]::new()
        $null = $sb.AppendLine("UPDATE dbo.Measurement SET")
        $isFirst = $true

        foreach ($boundParam in $PSBoundParameters.GetEnumerator())
        {
            if ($boundParam.Key -in 'MeasurementId', 'ErrorAction', 'ErrorVariable', 'OutVariable', 'OutBuffer', 'WarningAction', 'WarningVariable', 'Verbose', 'Debug', 'InformationVariable', 'InformationAction') { continue }

            $formatedValue = if ($boundParam.Value -is [string] -or $boundParam.Value -is [datetime])
            {
                "'$($boundParam.Value)'"
            }
            else
            {
                $boundParam.Value
            }
    
            if ($isFirst)
            {
                $null = $sb.AppendLine("$($boundParam.Key) = $formatedValue")
                $isFirst = $false
                continue
            }

            $null = $sb.AppendLine(",$($boundParam.Key) = $($boundParam.Value)")
        }

        $null = $sb.AppendLine("WHERE Id = $MeasurementId;")

        $sqlCommand.CommandText = $sb.ToString()
        $sb.ToString()
        $null = $sqlCommand.ExecuteScalar()
    }
    catch
    {
        Write-Error -Message "Unable to update beer measurement." -Exception $_.Exception
    }
    finally
    {
        $sqlConnection.Close()
    }
}

function Remove-BeerMeasurementInfo
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [uint16] $MeasurementId
    )

    # Remove element from database
    $sqlConnection = New-Object System.Data.SqlClient.SqlConnection
    $sqlConnection.ConnectionString = $env:SqlConnectionString

    try
    {
        $sqlConnection.Open()

        $sqlCommand = New-Object System.Data.SqlClient.SqlCommand
        $sqlCommand.Connection = $sqlConnection

        # Update measurement
        $sqlCommand.CommandText = "DELETE FROM dbo.Measurement WHERE Id = $MeasurementId;"
        $null = $sqlCommand.ExecuteScalar()
    }
    catch
    {
        Write-Error -Message "Unable to remove beer measurement." -Exception $_.Exception
    }
    finally
    {
        $sqlConnection.Close()
    }
}
