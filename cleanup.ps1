﻿$LogFile = "$env:windir\cleanup.log"

if ((Test-Path -Path "$env:windir\cleanup.log" -PathType Leaf)) {
    Remove-Item -Path "$env:windir\cleanup.log"
}

function WriteLog
{
	Param ([string]$LogString)
	$Stamp = (Get-Date).toString("dd/MM/yyyy HH:mm:ss")
	$LogMessage = "$Stamp $LogString"
	Add-content $LogFile -value $LogMessage
}

$SteamInstallPath = ''
$SteamLibraryFolders = @()
$SteamAppsFolders = @(
	"downloading",
	"shadercache",
	"temp",
	"workshop"
)
$SteamSysFolders = @(
	"appcache",
	"config",
	"userdata"
)

if(Test-Path 'HKLM:\SOFTWARE\Valve\Steam') {
    $SteamInstallPath = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Valve\Steam').InstallPath
}
if($SteamInstallPath -eq '') { throw "Can't find steam installed on this machine"}

$ClearPaths = (
	"$env:localappdata\Temp",
	"$env:localappdata\CrashDumps",
	"$env:localappdata\Google\Chrome\User Data",
	"$env:localappdata\Steam",
	"$env:localappdata\GameCenter\Cache",
	"$env:appdata\discord",
	"$env:appdata\FACEIT",
	"$env:appdata\Origin",
	"$env:appdata\Battle.net",
	"$env:userprofile\Downloads",
	"$env:userprofile\Pictures",
	"$env:userprofile\Videos",
	"$env:userprofile\Music"
)

$Processes = (
	"chrome",
	"FACEIT",
	"GameCenter",
	"discord",
	"Origin",
	"Battle.net",
	"Steam",
	"steamwebhelper"
)

WriteLog "Скрипт запущен"
WriteLog "Завершение работы процессов..."

foreach ($Process in $Processes)
{
	Get-Process -name $Process -ErrorAction SilentlyContinue | ? { $_.SI -eq (Get-Process -PID $PID).SessionId } | Stop-Process -Force | Add-Content $Logfile
	WriteLog "Процесс '$Process' успешно завершен"
}
Stop-Service "Steam Client Service" -Force | Add-Content $Logfile
WriteLog "Служба Steam Client Service остановлена"
Start-Sleep -Seconds 3

if(Test-Path "$SteamInstallPath\steamapps\libraryfolders.vdf") {
	$filedata = Get-Content "$SteamInstallPath\steamapps\libraryfolders.vdf"

	foreach($line in $filedata) {
		if($line -match '"path".*"(.*)"') {
			foreach ($SteamAppsFolder in $SteamAppsFolders)
			{
				$SteamLibraryFolders += "$($Matches[1])\steamapps\$SteamAppsFolder" -replace '\\\\', '\'
			}
		}
	}
}

foreach ($SteamLibraryFolder in $SteamLibraryFolders)
{
	if ((Test-Path -Path $SteamLibraryFolder) -eq $true)
	{
		Get-ChildItem -Path $SteamLibraryFolder -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue | Add-Content $Logfile
		WriteLog "Каталог '$SteamLibraryFolder' очищен"
	}
}

foreach ($SteamSysFolder in $SteamSysFolders)
{
	if ((Test-Path -Path "$SteamInstallPath\$SteamSysFolder") -eq $true)
	{
		Get-ChildItem -Path "$SteamInstallPath\$SteamSysFolder" -Recurse -Force -Exclude config.vdf, localconfig.vdf, sharedconfig.vdf | Where-Object {($_.LastWriteTime -le (Get-Date).AddHours(-24) )} | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue | Add-Content $Logfile
		WriteLog "Каталог '$SteamInstallPath\$SteamSysFolder' очищен"
	}
}

if(Test-Path 'HKCU:\SOFTWARE\Valve\Steam') {
    Get-ChildItem -Path (Get-ItemProperty -Path 'HKCU:\SOFTWARE\Valve\Steam').SourceModInstallPath | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue | Add-Content $Logfile
	WriteLog "Каталог 'Source Mods' очищен"
}

Remove-Item "$env:localappdata\GameCenter\GameCenter.ini" -Force | Add-Content $Logfile
WriteLog "Настройки VKPlay удалены"
Remove-Item "$env:localappdata\EpicGamesLauncher\Saved\Config\Windows\GameUserSettings.ini" -Force | Add-Content $Logfile
WriteLog "Настройки Epic Games удалены"

foreach ($Path in $ClearPaths)
{
	if ((Test-Path -Path $Path) -eq $true)
	{
		Get-ChildItem -Path $Path | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue | Add-Content $Logfile
		WriteLog "Каталог '$Path' очищен"
	}
}

Start-Sleep -Seconds 1

Clear-RecycleBin -Force
WriteLog "Корзина очищена"
WriteLog "Скрипт завершил свою работу"
# SIG # Begin signature block
# MIIblQYJKoZIhvcNAQcCoIIbhjCCG4ICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU9zrxdE7tVWzpAIH1eXmI0APF
# iUmgghYNMIIDAjCCAeqgAwIBAgIQcVYexSnli75OghC8ffJKETANBgkqhkiG9w0B
# AQsFADAZMRcwFQYDVQQDDA5Tb3BoaWEgUHJvamVjdDAeFw0yMjEwMjcxMTM1MTRa
# Fw0yNDEwMjcxMTQ1MTRaMBkxFzAVBgNVBAMMDlNvcGhpYSBQcm9qZWN0MIIBIjAN
# BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA2/6GS/YC4icplRSOBXza4q6pWcim
# /pZykJiSdZwUvACRBwZrOU0s3eygXc1+j9oMjS2L9oaf/7MjnGXV2Q7HUzEPEA2F
# H6DYWAcc0uFxhqsjs8Dh8HExTzwDk2/KewYd9Qtru7x92r0beajROhW6dN++LpSk
# d/cqCSpL07BMDhoSzQUIvmfqugMzfsxQJ8Vs8diQTt00Zb+jpfWC+r5NX+QZ17tH
# 2fMrUjccrKijNABkE61lHlkUMJtrfo+7twcpKq1ratdZH8Yb08Q+c4aR5MzI//Fz
# cUZaS7H0qQYbNYZPxKKxlmAGWPo7SgfY2CTzpW/Um2+SMyoGz3wb4uAuGQIDAQAB
# o0YwRDAOBgNVHQ8BAf8EBAMCB4AwEwYDVR0lBAwwCgYIKwYBBQUHAwMwHQYDVR0O
# BBYEFMJGwoQBihMSnym6aaZAcZLvl+vYMA0GCSqGSIb3DQEBCwUAA4IBAQAN/wGZ
# q42x4nN+7SizNX+Z4jlfb7MCA+CxfD9da0vJANnuqab1RjsxwNOpAmiuMZLySMjj
# GieC2oog7bn7vvmuQ6yVnCGuXvgYY2JV4JHsPnFvpiWBdaDYWKC66DaNWUF0HiiB
# xjxBBZsfcZZbg/pxAmaDSq5TTNbgmCauTIG0YTnWkcCk2h0pxJCSa4b7ZjsmRmWL
# 00mB+0V1+aoNWP6mVIrOa0XLwCDvxOvmqk6QVW0B5lt3ALshBjTBQhIFVxAOtX/Z
# BelOyFHboM6fza/7ggJ4Qmjq6ksMVnYgmf9/b6nNpPyQ4ZaVX3tolH+MfPjJkljG
# KHQg2UEssTwHFRCEMIIFjTCCBHWgAwIBAgIQDpsYjvnQLefv21DiCEAYWjANBgkq
# hkiG9w0BAQwFADBlMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5j
# MRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSQwIgYDVQQDExtEaWdpQ2VydCBB
# c3N1cmVkIElEIFJvb3QgQ0EwHhcNMjIwODAxMDAwMDAwWhcNMzExMTA5MjM1OTU5
# WjBiMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQL
# ExB3d3cuZGlnaWNlcnQuY29tMSEwHwYDVQQDExhEaWdpQ2VydCBUcnVzdGVkIFJv
# b3QgRzQwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQC/5pBzaN675F1K
# PDAiMGkz7MKnJS7JIT3yithZwuEppz1Yq3aaza57G4QNxDAf8xukOBbrVsaXbR2r
# snnyyhHS5F/WBTxSD1Ifxp4VpX6+n6lXFllVcq9ok3DCsrp1mWpzMpTREEQQLt+C
# 8weE5nQ7bXHiLQwb7iDVySAdYyktzuxeTsiT+CFhmzTrBcZe7FsavOvJz82sNEBf
# sXpm7nfISKhmV1efVFiODCu3T6cw2Vbuyntd463JT17lNecxy9qTXtyOj4DatpGY
# QJB5w3jHtrHEtWoYOAMQjdjUN6QuBX2I9YI+EJFwq1WCQTLX2wRzKm6RAXwhTNS8
# rhsDdV14Ztk6MUSaM0C/CNdaSaTC5qmgZ92kJ7yhTzm1EVgX9yRcRo9k98FpiHaY
# dj1ZXUJ2h4mXaXpI8OCiEhtmmnTK3kse5w5jrubU75KSOp493ADkRSWJtppEGSt+
# wJS00mFt6zPZxd9LBADMfRyVw4/3IbKyEbe7f/LVjHAsQWCqsWMYRJUadmJ+9oCw
# ++hkpjPRiQfhvbfmQ6QYuKZ3AeEPlAwhHbJUKSWJbOUOUlFHdL4mrLZBdd56rF+N
# P8m800ERElvlEFDrMcXKchYiCd98THU/Y+whX8QgUWtvsauGi0/C1kVfnSD8oR7F
# wI+isX4KJpn15GkvmB0t9dmpsh3lGwIDAQABo4IBOjCCATYwDwYDVR0TAQH/BAUw
# AwEB/zAdBgNVHQ4EFgQU7NfjgtJxXWRM3y5nP+e6mK4cD08wHwYDVR0jBBgwFoAU
# Reuir/SSy4IxLVGLp6chnfNtyA8wDgYDVR0PAQH/BAQDAgGGMHkGCCsGAQUFBwEB
# BG0wazAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMEMGCCsG
# AQUFBzAChjdodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1
# cmVkSURSb290Q0EuY3J0MEUGA1UdHwQ+MDwwOqA4oDaGNGh0dHA6Ly9jcmwzLmRp
# Z2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcmwwEQYDVR0gBAow
# CDAGBgRVHSAAMA0GCSqGSIb3DQEBDAUAA4IBAQBwoL9DXFXnOF+go3QbPbYW1/e/
# Vwe9mqyhhyzshV6pGrsi+IcaaVQi7aSId229GhT0E0p6Ly23OO/0/4C5+KH38nLe
# JLxSA8hO0Cre+i1Wz/n096wwepqLsl7Uz9FDRJtDIeuWcqFItJnLnU+nBgMTdydE
# 1Od/6Fmo8L8vC6bp8jQ87PcDx4eo0kxAGTVGamlUsLihVo7spNU96LHc/RzY9Hda
# XFSMb++hUD38dglohJ9vytsgjTVgHAIDyyCwrFigDkBjxZgiwbJZ9VVrzyerbHbO
# byMt9H5xaiNrIv8SuFQtJ37YOtnwtoeW/VvRXKwYw02fc7cBqZ9Xql4o4rmUMIIG
# rjCCBJagAwIBAgIQBzY3tyRUfNhHrP0oZipeWzANBgkqhkiG9w0BAQsFADBiMQsw
# CQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cu
# ZGlnaWNlcnQuY29tMSEwHwYDVQQDExhEaWdpQ2VydCBUcnVzdGVkIFJvb3QgRzQw
# HhcNMjIwMzIzMDAwMDAwWhcNMzcwMzIyMjM1OTU5WjBjMQswCQYDVQQGEwJVUzEX
# MBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNVBAMTMkRpZ2lDZXJ0IFRydXN0
# ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0YW1waW5nIENBMIICIjANBgkqhkiG
# 9w0BAQEFAAOCAg8AMIICCgKCAgEAxoY1BkmzwT1ySVFVxyUDxPKRN6mXUaHW0oPR
# nkyibaCwzIP5WvYRoUQVQl+kiPNo+n3znIkLf50fng8zH1ATCyZzlm34V6gCff1D
# tITaEfFzsbPuK4CEiiIY3+vaPcQXf6sZKz5C3GeO6lE98NZW1OcoLevTsbV15x8G
# ZY2UKdPZ7Gnf2ZCHRgB720RBidx8ald68Dd5n12sy+iEZLRS8nZH92GDGd1ftFQL
# IWhuNyG7QKxfst5Kfc71ORJn7w6lY2zkpsUdzTYNXNXmG6jBZHRAp8ByxbpOH7G1
# WE15/tePc5OsLDnipUjW8LAxE6lXKZYnLvWHpo9OdhVVJnCYJn+gGkcgQ+NDY4B7
# dW4nJZCYOjgRs/b2nuY7W+yB3iIU2YIqx5K/oN7jPqJz+ucfWmyU8lKVEStYdEAo
# q3NDzt9KoRxrOMUp88qqlnNCaJ+2RrOdOqPVA+C/8KI8ykLcGEh/FDTP0kyr75s9
# /g64ZCr6dSgkQe1CvwWcZklSUPRR8zZJTYsg0ixXNXkrqPNFYLwjjVj33GHek/45
# wPmyMKVM1+mYSlg+0wOI/rOP015LdhJRk8mMDDtbiiKowSYI+RQQEgN9XyO7ZONj
# 4KbhPvbCdLI/Hgl27KtdRnXiYKNYCQEoAA6EVO7O6V3IXjASvUaetdN2udIOa5kM
# 0jO0zbECAwEAAaOCAV0wggFZMBIGA1UdEwEB/wQIMAYBAf8CAQAwHQYDVR0OBBYE
# FLoW2W1NhS9zKXaaL3WMaiCPnshvMB8GA1UdIwQYMBaAFOzX44LScV1kTN8uZz/n
# upiuHA9PMA4GA1UdDwEB/wQEAwIBhjATBgNVHSUEDDAKBggrBgEFBQcDCDB3Bggr
# BgEFBQcBAQRrMGkwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNv
# bTBBBggrBgEFBQcwAoY1aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lD
# ZXJ0VHJ1c3RlZFJvb3RHNC5jcnQwQwYDVR0fBDwwOjA4oDagNIYyaHR0cDovL2Ny
# bDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZFJvb3RHNC5jcmwwIAYDVR0g
# BBkwFzAIBgZngQwBBAIwCwYJYIZIAYb9bAcBMA0GCSqGSIb3DQEBCwUAA4ICAQB9
# WY7Ak7ZvmKlEIgF+ZtbYIULhsBguEE0TzzBTzr8Y+8dQXeJLKftwig2qKWn8acHP
# HQfpPmDI2AvlXFvXbYf6hCAlNDFnzbYSlm/EUExiHQwIgqgWvalWzxVzjQEiJc6V
# aT9Hd/tydBTX/6tPiix6q4XNQ1/tYLaqT5Fmniye4Iqs5f2MvGQmh2ySvZ180HAK
# fO+ovHVPulr3qRCyXen/KFSJ8NWKcXZl2szwcqMj+sAngkSumScbqyQeJsG33irr
# 9p6xeZmBo1aGqwpFyd/EjaDnmPv7pp1yr8THwcFqcdnGE4AJxLafzYeHJLtPo0m5
# d2aR8XKc6UsCUqc3fpNTrDsdCEkPlM05et3/JWOZJyw9P2un8WbDQc1PtkCbISFA
# 0LcTJM3cHXg65J6t5TRxktcma+Q4c6umAU+9Pzt4rUyt+8SVe+0KXzM5h0F4ejjp
# nOHdI/0dKNPH+ejxmF/7K9h+8kaddSweJywm228Vex4Ziza4k9Tm8heZWcpw8De/
# mADfIBZPJ/tgZxahZrrdVcA6KYawmKAr7ZVBtzrVFZgxtGIJDwq9gdkT/r+k0fNX
# 2bwE+oLeMt8EifAAzV3C+dAjfwAL5HYCJtnwZXZCpimHCUcr5n8apIUP/JiW9lVU
# Kx+A+sDyDivl1vupL0QVSucTDh3bNzgaoSv27dZ8/DCCBsAwggSooAMCAQICEAxN
# aXJLlPo8Kko9KQeAPVowDQYJKoZIhvcNAQELBQAwYzELMAkGA1UEBhMCVVMxFzAV
# BgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYDVQQDEzJEaWdpQ2VydCBUcnVzdGVk
# IEc0IFJTQTQwOTYgU0hBMjU2IFRpbWVTdGFtcGluZyBDQTAeFw0yMjA5MjEwMDAw
# MDBaFw0zMzExMjEyMzU5NTlaMEYxCzAJBgNVBAYTAlVTMREwDwYDVQQKEwhEaWdp
# Q2VydDEkMCIGA1UEAxMbRGlnaUNlcnQgVGltZXN0YW1wIDIwMjIgLSAyMIICIjAN
# BgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAz+ylJjrGqfJru43BDZrboegUhXQz
# Gias0BxVHh42bbySVQxh9J0Jdz0Vlggva2Sk/QaDFteRkjgcMQKW+3KxlzpVrzPs
# YYrppijbkGNcvYlT4DotjIdCriak5Lt4eLl6FuFWxsC6ZFO7KhbnUEi7iGkMiMbx
# vuAvfTuxylONQIMe58tySSgeTIAehVbnhe3yYbyqOgd99qtu5Wbd4lz1L+2N1E2V
# hGjjgMtqedHSEJFGKes+JvK0jM1MuWbIu6pQOA3ljJRdGVq/9XtAbm8WqJqclUeG
# hXk+DF5mjBoKJL6cqtKctvdPbnjEKD+jHA9QBje6CNk1prUe2nhYHTno+EyREJZ+
# TeHdwq2lfvgtGx/sK0YYoxn2Off1wU9xLokDEaJLu5i/+k/kezbvBkTkVf826uV8
# MefzwlLE5hZ7Wn6lJXPbwGqZIS1j5Vn1TS+QHye30qsU5Thmh1EIa/tTQznQZPpW
# z+D0CuYUbWR4u5j9lMNzIfMvwi4g14Gs0/EH1OG92V1LbjGUKYvmQaRllMBY5eUu
# KZCmt2Fk+tkgbBhRYLqmgQ8JJVPxvzvpqwcOagc5YhnJ1oV/E9mNec9ixezhe7nM
# ZxMHmsF47caIyLBuMnnHC1mDjcbu9Sx8e47LZInxscS451NeX1XSfRkpWQNO+l3q
# RXMchH7XzuLUOncCAwEAAaOCAYswggGHMA4GA1UdDwEB/wQEAwIHgDAMBgNVHRMB
# Af8EAjAAMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMIMCAGA1UdIAQZMBcwCAYGZ4EM
# AQQCMAsGCWCGSAGG/WwHATAfBgNVHSMEGDAWgBS6FtltTYUvcyl2mi91jGogj57I
# bzAdBgNVHQ4EFgQUYore0GH8jzEU7ZcLzT0qlBTfUpwwWgYDVR0fBFMwUTBPoE2g
# S4ZJaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZEc0UlNB
# NDA5NlNIQTI1NlRpbWVTdGFtcGluZ0NBLmNybDCBkAYIKwYBBQUHAQEEgYMwgYAw
# JAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBYBggrBgEFBQcw
# AoZMaHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZEc0
# UlNBNDA5NlNIQTI1NlRpbWVTdGFtcGluZ0NBLmNydDANBgkqhkiG9w0BAQsFAAOC
# AgEAVaoqGvNG83hXNzD8deNP1oUj8fz5lTmbJeb3coqYw3fUZPwV+zbCSVEseIhj
# VQlGOQD8adTKmyn7oz/AyQCbEx2wmIncePLNfIXNU52vYuJhZqMUKkWHSphCK1D8
# G7WeCDAJ+uQt1wmJefkJ5ojOfRu4aqKbwVNgCeijuJ3XrR8cuOyYQfD2DoD75P/f
# nRCn6wC6X0qPGjpStOq/CUkVNTZZmg9U0rIbf35eCa12VIp0bcrSBWcrduv/mLIm
# lTgZiEQU5QpZomvnIj5EIdI/HMCb7XxIstiSDJFPPGaUr10CU+ue4p7k0x+GAWSc
# AMLpWnR1DT3heYi/HAGXyRkjgNc2Wl+WFrFjDMZGQDvOXTXUWT5Dmhiuw8nLw/ub
# E19qtcfg8wXDWd8nYiveQclTuf80EGf2JjKYe/5cQpSBlIKdrAqLxksVStOYkEVg
# M4DgI974A6T2RUflzrgDQkfoQTZxd639ouiXdE4u2h4djFrIHprVwvDGIqhPm73Y
# HJpRxC+a9l+nJ5e6li6FV8Bg53hWf2rvwpWaSxECyIKcyRoFfLpxtU56mWz06J7U
# WpjIn7+NuxhcQ/XQKujiYu54BNu90ftbCqhwfvCXhHjjCANdRyxjqCU4lwHSPzra
# 5eX25pvcfizM/xdMTQCi2NYBDriL7ubgclWJLCcZYfZ3AYwxggTyMIIE7gIBATAt
# MBkxFzAVBgNVBAMMDlNvcGhpYSBQcm9qZWN0AhBxVh7FKeWLvk6CELx98koRMAkG
# BSsOAwIaBQCgeDAYBgorBgEEAYI3AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJ
# AzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMG
# CSqGSIb3DQEJBDEWBBT7xyJ43TxqHyKMOgdVS3dTxAO1WDANBgkqhkiG9w0BAQEF
# AASCAQDG7SxDPoKQT9frsABkPQV/m/YCT6JgT/nxLRhSC3g+0hBCZJ61CfM9SnWH
# z0PUx3vqlAp/PO7C6GHwGs/t+2nSnUMdo2dZEnIKBsBQkimhYPYl126Yvzc3K9uw
# Z57KqDnwdPVyEqSs897nuUv5uou0np6f1C3tpw08NUXSS4JRXhrVuNbDl77alDdM
# yEFa5Mg9nFhaiIote5OEPQHpKwy8dhDjMCf1mBmhLgKrCSCHikid0zeXKAThDwLP
# diGGaoTlrkZGztaPml+WqbeMrCRH60XLDbAipOvZiGRSeKcT4kSke9YCavSk+ZU3
# onv8PsAiFJBziAydpORWUJWSQE6+oYIDIDCCAxwGCSqGSIb3DQEJBjGCAw0wggMJ
# AgEBMHcwYzELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTsw
# OQYDVQQDEzJEaWdpQ2VydCBUcnVzdGVkIEc0IFJTQTQwOTYgU0hBMjU2IFRpbWVT
# dGFtcGluZyBDQQIQDE1pckuU+jwqSj0pB4A9WjANBglghkgBZQMEAgEFAKBpMBgG
# CSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTIyMTAyNzEx
# NDUxNVowLwYJKoZIhvcNAQkEMSIEINoF6WpO1Yqb02OdwU5ySk8qyUI3dHUobAYM
# lztC/2M7MA0GCSqGSIb3DQEBAQUABIICAMZ0l+quo5aAhhRVfodm/bspH+gX7dAO
# XDQvOuTZJaDmPP42h++D0BpTjgwbenrk7ySXdLPR+9aS/+9rXXf+D0cAojhuaIYd
# JT1Bq0iZuoWvDiM5eCS0flVPevltjPBdr6EaYlfWJIRS2lR3jArGixAMVumnUEXN
# PAgIy4hm/z3drP/tUeBmB276Fcpx5595k/tqUgclKEgltX7qbUR2WpHEmEi0Yv7F
# Hgjy7h5xMN0MMU9hHASUSTV4ZyNla8SDG9B76/lghHoYbOted1ixiFwcQMdH0G0O
# 5SGd3dqKkyjHmq33r3PkaocWNf65DZhCwYdMEi57ujecd0IZZevsI3who26AKSWS
# TorfKSI1xMeY5/as1lGP+6NqdRYhGt9xMSw506WmdNYPdX5UcFszjx00sMmDxEEp
# vr8M3tIzss8UO4PZsWF8DdvqoNY020K3uxs1fdZdYFa2ly67Nrsay6cmnkE0WjUF
# UZlwjRfyW0TyzAy0n0fT5Ofq2R9ZfNKTq16z0GtYwJFQdiWBZQGXtudyXgWkuU6g
# 5MMnbz7S573uaQcXA3w7mebdYHV1kjCX6cZPKKCo9fDUIh2rm3mQ+s0TgXmkryAG
# ugqAQGBxq4pewMDinE2b2HAgtD0vR73hunsFbfAOxG5Kimvoln4sFlx0iLfJMcFn
# wty2Po9bAC9x
# SIG # End signature block
