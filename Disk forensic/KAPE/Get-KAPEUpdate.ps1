<#
    .SYNOPSIS
    Ths script will download KAPE and extract it to the current working directory. It is expected this script is run from an existing KAPE directory.
    .DESCRIPTION
    This script will attempt to determine what version is on the local system based on the kape.exe binary
    .EXAMPLE
    C:\PS> Get-KAPEUpdate.ps1 
    
    .NOTES
    Author: Eric Zimmerman
    Date:   January 22, 2019    
#>

function Write-Color {
    <#
	.SYNOPSIS
        Write-Color is a wrapper around Write-Host.
        It provides:
        - Easy manipulation of colors,
        - Logging output to file (log)
        - Nice formatting options out of the box.
	.DESCRIPTION
        Author: przemyslaw.klys at evotec.pl
        Project website: https://evotec.xyz/hub/scripts/write-color-ps1/
        Project support: https://github.com/EvotecIT/PSWriteColor
        Original idea: Josh (https://stackoverflow.com/users/81769/josh)
	.EXAMPLE
    Write-Color -Text "Red ", "Green ", "Yellow " -Color Red,Green,Yellow
    .EXAMPLE
	Write-Color -Text "This is text in Green ",
					"followed by red ",
					"and then we have Magenta... ",
					"isn't it fun? ",
					"Here goes DarkCyan" -Color Green,Red,Magenta,White,DarkCyan
    .EXAMPLE
	Write-Color -Text "This is text in Green ",
					"followed by red ",
					"and then we have Magenta... ",
					"isn't it fun? ",
                    "Here goes DarkCyan" -Color Green,Red,Magenta,White,DarkCyan -StartTab 3 -LinesBefore 1 -LinesAfter 1
    .EXAMPLE
	Write-Color "1. ", "Option 1" -Color Yellow, Green
	Write-Color "2. ", "Option 2" -Color Yellow, Green
	Write-Color "3. ", "Option 3" -Color Yellow, Green
	Write-Color "4. ", "Option 4" -Color Yellow, Green
	Write-Color "9. ", "Press 9 to exit" -Color Yellow, Gray -LinesBefore 1
    .EXAMPLE
	Write-Color -LinesBefore 2 -Text "This little ","message is ", "written to log ", "file as well." `
				-Color Yellow, White, Green, Red, Red -LogFile "C:\testing.txt" -TimeFormat "yyyy-MM-dd HH:mm:ss"
	Write-Color -Text "This can get ","handy if ", "want to display things, and log actions to file ", "at the same time." `
				-Color Yellow, White, Green, Red, Red -LogFile "C:\testing.txt"
    .EXAMPLE
    # Added in 0.5
    Write-Color -T "My text", " is ", "all colorful" -C Yellow, Red, Green -B Green, Green, Yellow
    wc -t "my text" -c yellow -b green
    wc -text "my text" -c red
    .NOTES
        CHANGELOG
        Version 0.5 (25th April 2018)
        -----------
        - Added backgroundcolor
        - Added aliases T/B/C to shorter code
        - Added alias to function (can be used with "WC")
        - Fixes to module publishing
        Version 0.4.0-0.4.9 (25th April 2018)
        -------------------
        - Published as module
        - Fixed small issues
        Version 0.31 (20th April 2018)
        ------------
        - Added Try/Catch for Write-Output (might need some additional work)
        - Small change to parameters
        Version 0.3 (9th April 2018)
        -----------
        - Added -ShowTime
        - Added -NoNewLine
        - Added function description
        - Changed some formatting
        Version 0.2
        -----------
        - Added logging to file
        Version 0.1
        -----------
        - First draft
        Additional Notes:
        - TimeFormat https://msdn.microsoft.com/en-us/library/8kb3ddd4.aspx
    #>
    [alias('Write-Colour')]
    [CmdletBinding()]
    param (
        [alias ('T')] [String[]]$Text,
        [alias ('C', 'ForegroundColor', 'FGC')] [ConsoleColor[]]$Color = [ConsoleColor]::White,
        [alias ('B', 'BGC')] [ConsoleColor[]]$BackGroundColor = $null,
        [alias ('Indent')][int] $StartTab = 0,
        [int] $LinesBefore = 0,
        [int] $LinesAfter = 0,
        [int] $StartSpaces = 0,
        [alias ('L')] [string] $LogFile = '',
        [Alias('DateFormat', 'TimeFormat')][string] $DateTimeFormat = 'yyyy-MM-dd HH:mm:ss',
        [alias ('LogTimeStamp')][bool] $LogTime = $true,
        [ValidateSet('unknown', 'string', 'unicode', 'bigendianunicode', 'utf8', 'utf7', 'utf32', 'ascii', 'default', 'oem')][string]$Encoding = 'Unicode',
        [switch] $ShowTime,
        [switch] $NoNewLine
    )
    $DefaultColor = $Color[0]
    if ($null -ne $BackGroundColor -and $BackGroundColor.Count -ne $Color.Count) { Write-Error "Colors, BackGroundColors parameters count doesn't match. Terminated." ; return }
    #if ($Text.Count -eq 0) { return }
    if ($LinesBefore -ne 0) {  for ($i = 0; $i -lt $LinesBefore; $i++) { Write-Host -Object "`n" -NoNewline } } # Add empty line before
    if ($StartTab -ne 0) {  for ($i = 0; $i -lt $StartTab; $i++) { Write-Host -Object "`t" -NoNewLine } }  # Add TABS before text
    if ($StartSpaces -ne 0) {  for ($i = 0; $i -lt $StartSpaces; $i++) { Write-Host -Object ' ' -NoNewLine } }  # Add SPACES before text
    if ($ShowTime) { Write-Host -Object "[$([datetime]::Now.ToString($DateTimeFormat))]" -NoNewline} # Add Time before output
    if ($Text.Count -ne 0) {
        if ($Color.Count -ge $Text.Count) {
            # the real deal coloring
            if ($null -eq $BackGroundColor) {
                for ($i = 0; $i -lt $Text.Length; $i++) { Write-Host -Object $Text[$i] -ForegroundColor $Color[$i] -NoNewLine }
            } else {
                for ($i = 0; $i -lt $Text.Length; $i++) { Write-Host -Object $Text[$i] -ForegroundColor $Color[$i] -BackgroundColor $BackGroundColor[$i] -NoNewLine }
            }
        } else {
            if ($null -eq $BackGroundColor) {
                for ($i = 0; $i -lt $Color.Length ; $i++) { Write-Host -Object $Text[$i] -ForegroundColor $Color[$i] -NoNewLine }
                for ($i = $Color.Length; $i -lt $Text.Length; $i++) { Write-Host -Object $Text[$i] -ForegroundColor $DefaultColor -NoNewLine }
            } else {
                for ($i = 0; $i -lt $Color.Length ; $i++) { Write-Host -Object $Text[$i] -ForegroundColor $Color[$i] -BackgroundColor $BackGroundColor[$i] -NoNewLine }
                for ($i = $Color.Length; $i -lt $Text.Length; $i++) { Write-Host -Object $Text[$i] -ForegroundColor $DefaultColor -BackgroundColor $BackGroundColor[0] -NoNewLine }
            }
        }
    }
    if ($NoNewLine -eq $true) { Write-Host -NoNewline } else { Write-Host } # Support for no new line
    if ($LinesAfter -ne 0) {  for ($i = 0; $i -lt $LinesAfter; $i++) { Write-Host -Object "`n" -NoNewline } }  # Add empty line after
    if ($Text.Count -ne 0 -and $LogFile -ne "") {
        # Save to file
        $TextToFile = ""
        for ($i = 0; $i -lt $Text.Length; $i++) {
            $TextToFile += $Text[$i]
        }
        try {
            if ($LogTime) {
                Write-Output -InputObject "[$([datetime]::Now.ToString($DateTimeFormat))]$TextToFile" | Out-File -FilePath $LogFile -Encoding $Encoding -Append
            } else {
                Write-Output -InputObject "$TextToFile" | Out-File -FilePath $LogFile -Encoding $Encoding -Append
            }
        } catch {
            $_.Exception
        }
    }
}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$TestColor = (Get-Host).ui.rawui.ForegroundColor
if ($TestColor -eq -1) 
{
    $defaultColor = [ConsoleColor]::Gray
} else {
    $defaultColor = $TestColor
}

write-host ""
Write-Host "Ths script will download KAPE and extract it to the current working directory." -BackgroundColor Blue
Write-Host "It is expected this script is run from an existing KAPE directory." -BackgroundColor Blue
write-host ""

$currentDirectory = Resolve-Path -Path ('.')

$kapePath = Join-Path -Path $currentDirectory -ChildPath 'kape.exe'

if (Test-Path -Path $kapePath)
{
  while ((get-process -Name "*kape").count -ne 0)
  {
    write-color -Text "* ", "KAPE appears to be running!. Close all running instances of kape.exe or gkape.exe!" -Color Green,Red

    write-host ""
    Write-Host 'Press any key to check again...';
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
  }

    write-color -Text "* ", "Found kape.exe binary." -Color Green,$defaultColor

    $localVersion = [Diagnostics.FileVersionInfo]::GetVersionInfo($kapePath).FileVersion


write-color -Text "* ", "Local version is '$localVersion'`n" -Color Green,$defaultColor
    
write-color -Text "* ", "Checking server for current version..." -Color Green,$defaultColor
    
    $serverResponse = Invoke-WebRequest -Uri 'https://s3.amazonaws.com/cyb-us-prd-kape/ver.txt' -UseBasicParsing 
    $content = $serverResponse.Content
    
write-color -Text "* ", "Server version is '$content'" -Color Green,$defaultColor
    
    $localVerNoDot = $localVersion.Replace('.','')
    $serverVerNoDot = $content.Replace('.','')
    
    [int]$localInt = [convert]::ToInt32($localVerNoDot)
    [int]$serverInt = [convert]::ToInt32($serverVerNoDot)
    
    if ($serverInt -gt $localInt)
    {

      write-color -Text "* ", "A new version is available! Downloading..." -Color Green,$defaultColor
      
      $destFile = Join-Path -Path $currentDirectory -ChildPath 'kape.zip'
      
      $dUrl = 'https://bit.ly/2Ei31Ga'
      
      $progressPreference = 'silentlyContinue'
            
      Invoke-WebRequest -Uri $dUrl -OutFile $destFile -ErrorAction:Stop -UseBasicParsing
      
      $progressPreference = 'Continue'
      
	write-color -Text "* ", "Unzipping new version..." -Color Green,$defaultColor

      Expand-Archive -Path $destFile -DestinationPath $currentDirectory -Force
      
      $kapeDir = Join-Path -Path $currentDirectory -ChildPath "KAPE"

      Copy-Item -Path (Join-Path -Path $kapeDir -ChildPath "Documentation") -Destination $currentDirectory -Force -Recurse
      Copy-Item -Path (Join-Path -Path $kapeDir -ChildPath "Targets") -Destination $currentDirectory -Force -Recurse
      Copy-Item -Path (Join-Path -Path $kapeDir -ChildPath "Modules") -Destination $currentDirectory -Force -Recurse
      Copy-Item -Path (Join-Path -Path $kapeDir -ChildPath "ChangeLog.txt") -Destination $currentDirectory -Force 
      Copy-Item -Path (Join-Path -Path $kapeDir -ChildPath "Get-KAPEUpdate.ps1") -Destination $currentDirectory -Force 
      Copy-Item -Path (Join-Path -Path $kapeDir -ChildPath "gkape.exe") -Destination $currentDirectory -Force 
      Copy-Item -Path (Join-Path -Path $kapeDir -ChildPath "kape.exe") -Destination $currentDirectory -Force 
      
      $localVersion = [Diagnostics.FileVersionInfo]::GetVersionInfo($kapePath).FileVersion
	write-color -Text "* ", "Local version is now '$localVersion'!" -Color Green,$defaultColor

      Write-Host ""      
	write-color -Text "* ", "Change log (newest 20 lines)" -Color Green,$defaultColor
      
      Get-Content -Path (Join-Path  -Path $currentDirectory -ChildPath 'ChangeLog.txt') -TotalCount 20
            
      remove-item -Path $destFile
      remove-item -Path (Join-Path -Path $currentDirectory -ChildPath 'KAPE') -Recurse

	write-host ""
	write-host ""

	write-color -Text "* ", "Be sure to update local Target and Module configurations!" -Color Green,Red
	write-color -Text "* ", "This can be done via gkape (click Sync button) or run 'kape.exe --sync' from the command line" -Color Green,$defaultColor

	write-host ""
    }
    else
    {
	Write-Host ""
	write-color -Text "* ", "Local and server version are the same. No update available" -Color Green,$defaultColor
	Write-Host ""
    }
}
else
{
	Write-Host ""
	write-color -Text "* ", "kape.exe not found in $currentDirectory! Nothing to do" -Color Green,$defaultColor
	Write-Host ""
}


# SIG # Begin signature block
# MIIVuwYJKoZIhvcNAQcCoIIVrDCCFagCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCC3akfs8gnvDSvp
# 34ElBSy6oBa+4StSpJd0W1IWYb8v96CCEfYwggVvMIIEV6ADAgECAhBI/JO0YFWU
# jTanyYqJ1pQWMA0GCSqGSIb3DQEBDAUAMHsxCzAJBgNVBAYTAkdCMRswGQYDVQQI
# DBJHcmVhdGVyIE1hbmNoZXN0ZXIxEDAOBgNVBAcMB1NhbGZvcmQxGjAYBgNVBAoM
# EUNvbW9kbyBDQSBMaW1pdGVkMSEwHwYDVQQDDBhBQUEgQ2VydGlmaWNhdGUgU2Vy
# dmljZXMwHhcNMjEwNTI1MDAwMDAwWhcNMjgxMjMxMjM1OTU5WjBWMQswCQYDVQQG
# EwJHQjEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMS0wKwYDVQQDEyRTZWN0aWdv
# IFB1YmxpYyBDb2RlIFNpZ25pbmcgUm9vdCBSNDYwggIiMA0GCSqGSIb3DQEBAQUA
# A4ICDwAwggIKAoICAQCN55QSIgQkdC7/FiMCkoq2rjaFrEfUI5ErPtx94jGgUW+s
# hJHjUoq14pbe0IdjJImK/+8Skzt9u7aKvb0Ffyeba2XTpQxpsbxJOZrxbW6q5KCD
# J9qaDStQ6Utbs7hkNqR+Sj2pcaths3OzPAsM79szV+W+NDfjlxtd/R8SPYIDdub7
# P2bSlDFp+m2zNKzBenjcklDyZMeqLQSrw2rq4C+np9xu1+j/2iGrQL+57g2extme
# me/G3h+pDHazJyCh1rr9gOcB0u/rgimVcI3/uxXP/tEPNqIuTzKQdEZrRzUTdwUz
# T2MuuC3hv2WnBGsY2HH6zAjybYmZELGt2z4s5KoYsMYHAXVn3m3pY2MeNn9pib6q
# RT5uWl+PoVvLnTCGMOgDs0DGDQ84zWeoU4j6uDBl+m/H5x2xg3RpPqzEaDux5mcz
# mrYI4IAFSEDu9oJkRqj1c7AGlfJsZZ+/VVscnFcax3hGfHCqlBuCF6yH6bbJDoEc
# QNYWFyn8XJwYK+pF9e+91WdPKF4F7pBMeufG9ND8+s0+MkYTIDaKBOq3qgdGnA2T
# OglmmVhcKaO5DKYwODzQRjY1fJy67sPV+Qp2+n4FG0DKkjXp1XrRtX8ArqmQqsV/
# AZwQsRb8zG4Y3G9i/qZQp7h7uJ0VP/4gDHXIIloTlRmQAOka1cKG8eOO7F/05QID
# AQABo4IBEjCCAQ4wHwYDVR0jBBgwFoAUoBEKIz6W8Qfs4q8p74Klf9AwpLQwHQYD
# VR0OBBYEFDLrkpr/NZZILyhAQnAgNpFcF4XmMA4GA1UdDwEB/wQEAwIBhjAPBgNV
# HRMBAf8EBTADAQH/MBMGA1UdJQQMMAoGCCsGAQUFBwMDMBsGA1UdIAQUMBIwBgYE
# VR0gADAIBgZngQwBBAEwQwYDVR0fBDwwOjA4oDagNIYyaHR0cDovL2NybC5jb21v
# ZG9jYS5jb20vQUFBQ2VydGlmaWNhdGVTZXJ2aWNlcy5jcmwwNAYIKwYBBQUHAQEE
# KDAmMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5jb21vZG9jYS5jb20wDQYJKoZI
# hvcNAQEMBQADggEBABK/oe+LdJqYRLhpRrWrJAoMpIpnuDqBv0WKfVIHqI0fTiGF
# OaNrXi0ghr8QuK55O1PNtPvYRL4G2VxjZ9RAFodEhnIq1jIV9RKDwvnhXRFAZ/ZC
# J3LFI+ICOBpMIOLbAffNRk8monxmwFE2tokCVMf8WPtsAO7+mKYulaEMUykfb9gZ
# pk+e96wJ6l2CxouvgKe9gUhShDHaMuwV5KZMPWw5c9QLhTkg4IUaaOGnSDip0TYl
# d8GNGRbFiExmfS9jzpjoad+sPKhdnckcW67Y8y90z7h+9teDnRGWYpquRRPaf9xH
# +9/DUp/mBlXpnYzyOmJRvOwkDynUWICE5EV7WtgwggYaMIIEAqADAgECAhBiHW0M
# UgGeO5B5FSCJIRwKMA0GCSqGSIb3DQEBDAUAMFYxCzAJBgNVBAYTAkdCMRgwFgYD
# VQQKEw9TZWN0aWdvIExpbWl0ZWQxLTArBgNVBAMTJFNlY3RpZ28gUHVibGljIENv
# ZGUgU2lnbmluZyBSb290IFI0NjAeFw0yMTAzMjIwMDAwMDBaFw0zNjAzMjEyMzU5
# NTlaMFQxCzAJBgNVBAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxKzAp
# BgNVBAMTIlNlY3RpZ28gUHVibGljIENvZGUgU2lnbmluZyBDQSBSMzYwggGiMA0G
# CSqGSIb3DQEBAQUAA4IBjwAwggGKAoIBgQCbK51T+jU/jmAGQ2rAz/V/9shTUxjI
# ztNsfvxYB5UXeWUzCxEeAEZGbEN4QMgCsJLZUKhWThj/yPqy0iSZhXkZ6Pg2A2NV
# DgFigOMYzB2OKhdqfWGVoYW3haT29PSTahYkwmMv0b/83nbeECbiMXhSOtbam+/3
# 6F09fy1tsB8je/RV0mIk8XL/tfCK6cPuYHE215wzrK0h1SWHTxPbPuYkRdkP05Zw
# mRmTnAO5/arnY83jeNzhP06ShdnRqtZlV59+8yv+KIhE5ILMqgOZYAENHNX9SJDm
# +qxp4VqpB3MV/h53yl41aHU5pledi9lCBbH9JeIkNFICiVHNkRmq4TpxtwfvjsUe
# dyz8rNyfQJy/aOs5b4s+ac7IH60B+Ja7TVM+EKv1WuTGwcLmoU3FpOFMbmPj8pz4
# 4MPZ1f9+YEQIQty/NQd/2yGgW+ufflcZ/ZE9o1M7a5Jnqf2i2/uMSWymR8r2oQBM
# dlyh2n5HirY4jKnFH/9gRvd+QOfdRrJZb1sCAwEAAaOCAWQwggFgMB8GA1UdIwQY
# MBaAFDLrkpr/NZZILyhAQnAgNpFcF4XmMB0GA1UdDgQWBBQPKssghyi47G9IritU
# pimqF6TNDDAOBgNVHQ8BAf8EBAMCAYYwEgYDVR0TAQH/BAgwBgEB/wIBADATBgNV
# HSUEDDAKBggrBgEFBQcDAzAbBgNVHSAEFDASMAYGBFUdIAAwCAYGZ4EMAQQBMEsG
# A1UdHwREMEIwQKA+oDyGOmh0dHA6Ly9jcmwuc2VjdGlnby5jb20vU2VjdGlnb1B1
# YmxpY0NvZGVTaWduaW5nUm9vdFI0Ni5jcmwwewYIKwYBBQUHAQEEbzBtMEYGCCsG
# AQUFBzAChjpodHRwOi8vY3J0LnNlY3RpZ28uY29tL1NlY3RpZ29QdWJsaWNDb2Rl
# U2lnbmluZ1Jvb3RSNDYucDdjMCMGCCsGAQUFBzABhhdodHRwOi8vb2NzcC5zZWN0
# aWdvLmNvbTANBgkqhkiG9w0BAQwFAAOCAgEABv+C4XdjNm57oRUgmxP/BP6YdURh
# w1aVcdGRP4Wh60BAscjW4HL9hcpkOTz5jUug2oeunbYAowbFC2AKK+cMcXIBD0Zd
# OaWTsyNyBBsMLHqafvIhrCymlaS98+QpoBCyKppP0OcxYEdU0hpsaqBBIZOtBajj
# cw5+w/KeFvPYfLF/ldYpmlG+vd0xqlqd099iChnyIMvY5HexjO2AmtsbpVn0OhNc
# WbWDRF/3sBp6fWXhz7DcML4iTAWS+MVXeNLj1lJziVKEoroGs9Mlizg0bUMbOalO
# hOfCipnx8CaLZeVme5yELg09Jlo8BMe80jO37PU8ejfkP9/uPak7VLwELKxAMcJs
# zkyeiaerlphwoKx1uHRzNyE6bxuSKcutisqmKL5OTunAvtONEoteSiabkPVSZ2z7
# 6mKnzAfZxCl/3dq3dUNw4rg3sTCggkHSRqTqlLMS7gjrhTqBmzu1L90Y1KWN/Y5J
# KdGvspbOrTfOXyXvmPL6E52z1NZJ6ctuMFBQZH3pwWvqURR8AgQdULUvrxjUYbHH
# j95Ejza63zdrEcxWLDX6xWls/GDnVNueKjWUH3fTv1Y8Wdho698YADR7TNx8X8z2
# Bev6SivBBOHY+uqiirZtg0y9ShQoPzmCcn63Syatatvx157YK9hlcPmVoa1oDE5/
# L9Uo2bC5a4CH2RwwggZhMIIEyaADAgECAhEAjBvils2zwjIqORJ4bVTEYTANBgkq
# hkiG9w0BAQwFADBUMQswCQYDVQQGEwJHQjEYMBYGA1UEChMPU2VjdGlnbyBMaW1p
# dGVkMSswKQYDVQQDEyJTZWN0aWdvIFB1YmxpYyBDb2RlIFNpZ25pbmcgQ0EgUjM2
# MB4XDTIzMDMwMzAwMDAwMFoXDTI2MDMwMjIzNTk1OVowVzELMAkGA1UEBhMCVVMx
# EDAOBgNVBAgMB0luZGlhbmExGjAYBgNVBAoMEUVyaWMgUi4gWmltbWVybWFuMRow
# GAYDVQQDDBFFcmljIFIuIFppbW1lcm1hbjCCAiIwDQYJKoZIhvcNAQEBBQADggIP
# ADCCAgoCggIBANn/rNwsql8kzji1V5VB6wbTzlAWcO9OlGpYacDa5c51U8a3pGJz
# ss8jkbFghih927eHNYzUGHu3Qy7qCOROnZwKm5Da+N+yKyq1NX7LWwSfwpK6pa4S
# 7Y/LjgEDD6y/Vl9og+1F9mkTjDjP6rj8tMgKT6Pg+pfQPVL5oI4eV+5LbouPjSho
# gXgsf+UpN3CrX6MKDk40HEAsgura7fG5WzZXK0UruurloxTJZ2edlOFdU8KNswsk
# AncqZXRMhLkp89WE68e+Q+PybbVP+im+cHZWqDYAb4mu0cYLiCQxQUPGJ6AB+O9M
# kNAi9pO+qtZ5N+5ReNXENE9jokO/PDM7/tDVbODfZlHTgPecn2Hhhu+LiikrCPPd
# +5KFDU9kgaZ8N/L6qt2omNgqF3BXCo08beDiMfcs8veilCjWlzN8BTHrjhKctslu
# 0thGSqdQSOD6W8WawLxYlPMP4Fp7QEmHvJTYWQCdv0c6/HwMiDUGOZ2RT2i1g9Ck
# K7RSEh7shuLo1iW8OTyQX+Ecud7NpIQ3i2mMLcZZsqGF9erFxZrcD0TFqgX4peyH
# Y8Ig+5BYXY/w3VI9sYPWpH3kRwhqYMi0If9U+lfLUu3yoeKtIy6yH7NNnBAkOpE0
# k5K1ydHwFHH8O2QK9QslhUWIrkDK0etGPQfRqu349OtE/ddh4ySZOyklAgMBAAGj
# ggGpMIIBpTAfBgNVHSMEGDAWgBQPKssghyi47G9IritUpimqF6TNDDAdBgNVHQ4E
# FgQUOKRo/KEN0+hPPe2Rb2aIduqumqcwDgYDVR0PAQH/BAQDAgeAMAwGA1UdEwEB
# /wQCMAAwEwYDVR0lBAwwCgYIKwYBBQUHAwMwSgYDVR0gBEMwQTA1BgwrBgEEAbIx
# AQIBAwIwJTAjBggrBgEFBQcCARYXaHR0cHM6Ly9zZWN0aWdvLmNvbS9DUFMwCAYG
# Z4EMAQQBMEkGA1UdHwRCMEAwPqA8oDqGOGh0dHA6Ly9jcmwuc2VjdGlnby5jb20v
# U2VjdGlnb1B1YmxpY0NvZGVTaWduaW5nQ0FSMzYuY3JsMHkGCCsGAQUFBwEBBG0w
# azBEBggrBgEFBQcwAoY4aHR0cDovL2NydC5zZWN0aWdvLmNvbS9TZWN0aWdvUHVi
# bGljQ29kZVNpZ25pbmdDQVIzNi5jcnQwIwYIKwYBBQUHMAGGF2h0dHA6Ly9vY3Nw
# LnNlY3RpZ28uY29tMB4GA1UdEQQXMBWBE2VyaWNAemltdGVjaDRuNi5jb20wDQYJ
# KoZIhvcNAQEMBQADggGBAIeSKPPdudG4ADR2jSIzrrBQJIjnUr+FN0Zij4+rKmEW
# MwoxLkqMwsn1T+a06E2c2+IFuasbNhsUhe+SssC04DntS2Mk48SY/E52LD0gGJNW
# UzfgFej9e8AYaZa3y8oFL4NmBuhXJcc2yhJVRObJ84USi4vmj1JmbebTDWS6sEq8
# yRdGoerMW++GP3SZvGKo25bYr1QKtdOLaMVUp6c3ILUyfiPUGsiPR9JWhmMqe/FX
# 3/6YFp+A01nxLqV6ya7+by+TBBLeKd6OUqflzmBV/i2eKvk+DIj1uRvesszQ/DbK
# zaLvls9+KUDLEUk80GjQ/PK0Y5oW+9gTGQ9ct/OIGATzsXGRL38SZJE0L3vuEUny
# lMyK1MQxmPj95DCncIGKbihZMBsjxi89K1rWU5Ka4rN6mCXDh2+RboTac90IwpGL
# dKuBRalIpkCXYY4FQ44SuEmdZx8zlm2Kfcg1k96mGFPOtvFpZtJzqpqWVUlcG1Sa
# SzntLunzWbjPdE9x/AXPwjGCAxswggMXAgEBMGkwVDELMAkGA1UEBhMCR0IxGDAW
# BgNVBAoTD1NlY3RpZ28gTGltaXRlZDErMCkGA1UEAxMiU2VjdGlnbyBQdWJsaWMg
# Q29kZSBTaWduaW5nIENBIFIzNgIRAIwb4pbNs8IyKjkSeG1UxGEwDQYJYIZIAWUD
# BAIBBQCggYQwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMx
# DAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkq
# hkiG9w0BCQQxIgQgWYgY024zZQix5VQOWSnILattrB4lmu2keaiCxRNexrowDQYJ
# KoZIhvcNAQEBBQAEggIApuF4bj6AQAJ2hpk6oVsQqhflaZtfatWsCKeKhXyd1z4/
# YXIY0QE9EMVMi0HXPoTm/STUMZmNZK9ziqznsTa9HowgqeS9m+5o4Ly8imyhCKyn
# wgvDVmZ4bN/QXS28TrlWdUON+Fvl7uM/mRYqkqhhtz7i3Ira8gyKF3M2Gkr/ZKey
# gb9BOGEeqFBQexdfhWqGjpdKK/VANA+sisAbQqN1IXP3uw5UZENm5YZmFJM7g88j
# 574HZFem0fEyZeDdrGY/wHPXbYGdjdGgwRkt8P0RrkpcjLD5XMnSkmQ0qQcnFYHl
# Zbadw0UmEVbYL0Go28Ay6ZJ06YUO1+eY5wf3jcwotyHqfZVCEqjWbSRyvdz9qivM
# P7/HgB1lJ8EeKKC1BnZenSXsQbGuMWqknDiDYu91L/2Jd/nfZWjS/pmMV3j522Lp
# SImdiFj4biH7p+LeTnfnsth+VMZrE+F8ZGwyt3Yre9CMiOtpl9UtAz2P5JEjFSR2
# 1ymCuO2dGAeKBvcCN6CPMFdGh6RaKLTcdX0c37eUgGyhCE5DeW6GfBIo3+mgQ4QH
# MRfGZVQpz0A6tOihOYkBd592hmfbxlp8uwBHNdM8Tqq4pnkzrtES1bdMNh777/7K
# /0dmByQMRpWyg63JdocZEZaHyYrAKkXjJ+yAA1ND1k6+Pn7HpMOjOPmS+yqpwUE=
# SIG # End signature block
