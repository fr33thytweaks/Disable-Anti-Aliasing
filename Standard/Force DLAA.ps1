    If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator"))
    {Start-Process PowerShell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
    Exit}
    $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + " (Administrator)"
    $Host.UI.RawUI.BackgroundColor = "Black"
	$Host.PrivateData.ProgressBackgroundColor = "Black"
    $Host.PrivateData.ProgressForegroundColor = "White"
    Clear-Host

    function Get-FileFromWeb {
    param ([Parameter(Mandatory)][string]$URL, [Parameter(Mandatory)][string]$File)
    function Show-Progress {
    param ([Parameter(Mandatory)][Single]$TotalValue, [Parameter(Mandatory)][Single]$CurrentValue, [Parameter(Mandatory)][string]$ProgressText, [Parameter()][int]$BarSize = 10, [Parameter()][switch]$Complete)
    $percent = $CurrentValue / $TotalValue
    $percentComplete = $percent * 100
    if ($psISE) { Write-Progress "$ProgressText" -id 0 -percentComplete $percentComplete }
    else { Write-Host -NoNewLine "`r$ProgressText $(''.PadRight($BarSize * $percent, [char]9608).PadRight($BarSize, [char]9617)) $($percentComplete.ToString('##0.00').PadLeft(6)) % " }
    }
    try {
    $request = [System.Net.HttpWebRequest]::Create($URL)
    $response = $request.GetResponse()
    if ($response.StatusCode -eq 401 -or $response.StatusCode -eq 403 -or $response.StatusCode -eq 404) { throw "Remote file either doesn't exist, is unauthorized, or is forbidden for '$URL'." }
    if ($File -match '^\.\\') { $File = Join-Path (Get-Location -PSProvider 'FileSystem') ($File -Split '^\.')[1] }
    if ($File -and !(Split-Path $File)) { $File = Join-Path (Get-Location -PSProvider 'FileSystem') $File }
    if ($File) { $fileDirectory = $([System.IO.Path]::GetDirectoryName($File)); if (!(Test-Path($fileDirectory))) { [System.IO.Directory]::CreateDirectory($fileDirectory) | Out-Null } }
    [long]$fullSize = $response.ContentLength
    [byte[]]$buffer = new-object byte[] 1048576
    [long]$total = [long]$count = 0
    $reader = $response.GetResponseStream()
    $writer = new-object System.IO.FileStream $File, 'Create'
    do {
    $count = $reader.Read($buffer, 0, $buffer.Length)
    $writer.Write($buffer, 0, $count)
    $total += $count
    if ($fullSize -gt 0) { Show-Progress -TotalValue $fullSize -CurrentValue $total -ProgressText " $($File.Name)" }
    } while ($count -gt 0)
    }
    finally {
    $reader.Close()
    $writer.Close()
    }
    }

Write-Host "Installing: NvidiaProfileInspector . . ."
# nvidiacontrolpanel - adjust image settings with preview - performance
reg add "HKCU\SOFTWARE\NVIDIA Corporation\Global\NVTweak" /v "Gestalt" /t REG_DWORD /d "1" /f | Out-Null
# check for file
if (-Not (Test-Path -Path "$env:TEMP\Inspector.zip")) {
# download inspector
Get-FileFromWeb -URL "https://ozone3d.net/dl/dlz/nvidiaProfileInspector_2.4.0.4.zip" -File "$env:TEMP\Inspector.zip"
# extract files
Expand-Archive "$env:TEMP\Inspector.zip" -DestinationPath "$env:TEMP\Inspector" -ErrorAction SilentlyContinue
# create customsettingnames.xml
$MultilineComment = @"
<?xml version="1.0" encoding="utf-8"?>
<CustomSettingNames>
	<Settings>
    <CustomSetting>
      <UserfriendlyName>DLSS 3.1.11+ - Force all quality levels to DLAA (base profile only)</UserfriendlyName>
      <HexSettingID>0x10E41DF4</HexSettingID>
      <GroupName>5 - Common</GroupName>
      <MinRequiredDriverVersion>0</MinRequiredDriverVersion>
      <SettingValues>
        <CustomSettingValue>
          <UserfriendlyName>Off</UserfriendlyName>
          <HexValue>0x00000000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>On - All levels will act as DLAA (base profile only)</UserfriendlyName>
          <HexValue>0x00000001</HexValue>
        </CustomSettingValue>
      </SettingValues>
      <SettingMasks />
    </CustomSetting>
    <CustomSetting>
      <UserfriendlyName>DLSS 3.1.11+ - Forced scaling ratio (base profile only)</UserfriendlyName>
      <HexSettingID>0x10E41DF5</HexSettingID>
      <GroupName>5 - Common</GroupName>
      <MinRequiredDriverVersion>0</MinRequiredDriverVersion>
      <SettingValues>
        <CustomSettingValue>
          <UserfriendlyName>Off</UserfriendlyName>
          <HexValue>0x00000000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>Render at 0.33x native</UserfriendlyName>
          <HexValue>0x3EAAAAAB</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>Render at 0.5x native</UserfriendlyName>
          <HexValue>0x3F000000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>Render at 0.75x native</UserfriendlyName>
          <HexValue>0x3F400000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>Render at 0.80x native</UserfriendlyName>
          <HexValue>0x3F4CCCCD</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>Render at 0.85x native</UserfriendlyName>
          <HexValue>0x3F59999A</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>Render at 0.9x native</UserfriendlyName>
          <HexValue>0x3F666666</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>Render at 0.95x native</UserfriendlyName>
          <HexValue>0x3F733333</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>Render at 0.99x native</UserfriendlyName>
          <HexValue>0x3F7D70A4</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>Render at 1.00x native</UserfriendlyName>
          <HexValue>0x3F800000</HexValue>
        </CustomSettingValue>
      </SettingValues>
      <SettingMasks />
    </CustomSetting>
    <CustomSetting>
      <UserfriendlyName>DLSS 3.1.11+ - Forced DLSS3.1 preset letter (base profile only)</UserfriendlyName>
      <HexSettingID>0x10E41DF3</HexSettingID>
      <GroupName>5 - Common</GroupName>
      <MinRequiredDriverVersion>0</MinRequiredDriverVersion>
      <SettingValues>
        <CustomSettingValue>
          <UserfriendlyName>N/A</UserfriendlyName>
          <HexValue>0x00000000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>Preset A</UserfriendlyName>
          <HexValue>0x00000001</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>Preset B</UserfriendlyName>
          <HexValue>0x00000002</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>Preset C</UserfriendlyName>
          <HexValue>0x00000003</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>Preset D</UserfriendlyName>
          <HexValue>0x00000004</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>Preset E (unused)</UserfriendlyName>
          <HexValue>0x00000005</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>Preset F</UserfriendlyName>
          <HexValue>0x00000006</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>Preset G (unused)</UserfriendlyName>
          <HexValue>0x00000007</HexValue>
        </CustomSettingValue>
      </SettingValues>
      <SettingMasks />
    </CustomSetting>
		<CustomSetting>
			<UserfriendlyName>Frame Rate Limiter - Background Application</UserfriendlyName>
			<HexSettingID>0x10835005</HexSettingID>
			<GroupName>2 - Sync and Refresh</GroupName>
			<SettingValues>
				<CustomSettingValue>
					<UserfriendlyName>Off</UserfriendlyName>
					<HexValue>0x00000000</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>5 FPS</UserfriendlyName>
					<HexValue>0x00000005</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>6 FPS</UserfriendlyName>
					<HexValue>0x00000006</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>7 FPS</UserfriendlyName>
					<HexValue>0x00000007</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>8 FPS</UserfriendlyName>
					<HexValue>0x00000008</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>9 FPS</UserfriendlyName>
					<HexValue>0x00000009</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>10 FPS</UserfriendlyName>
					<HexValue>0x0000000A</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>11 FPS</UserfriendlyName>
					<HexValue>0x0000000B</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>12 FPS</UserfriendlyName>
					<HexValue>0x0000000C</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>13 FPS</UserfriendlyName>
					<HexValue>0x0000000D</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>14 FPS</UserfriendlyName>
					<HexValue>0x0000000E</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>15 FPS</UserfriendlyName>
					<HexValue>0x0000000F</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>16 FPS</UserfriendlyName>
					<HexValue>0x00000010</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>17 FPS</UserfriendlyName>
					<HexValue>0x00000011</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>18 FPS</UserfriendlyName>
					<HexValue>0x00000012</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>19 FPS</UserfriendlyName>
					<HexValue>0x00000013</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>20 FPS</UserfriendlyName>
					<HexValue>0x00000014</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>21 FPS</UserfriendlyName>
					<HexValue>0x00000015</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>22 FPS</UserfriendlyName>
					<HexValue>0x00000016</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>23 FPS</UserfriendlyName>
					<HexValue>0x00000017</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>24 FPS</UserfriendlyName>
					<HexValue>0x00000018</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>25 FPS</UserfriendlyName>
					<HexValue>0x00000019</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>26 FPS</UserfriendlyName>
					<HexValue>0x0000001A</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>27 FPS</UserfriendlyName>
					<HexValue>0x0000001B</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>28 FPS</UserfriendlyName>
					<HexValue>0x0000001C</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>29 FPS</UserfriendlyName>
					<HexValue>0x0000001D</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>30 FPS</UserfriendlyName>
					<HexValue>0x0000001E</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>31 FPS</UserfriendlyName>
					<HexValue>0x0000001F</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>32 FPS</UserfriendlyName>
					<HexValue>0x00000020</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>33 FPS</UserfriendlyName>
					<HexValue>0x00000021</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>34 FPS</UserfriendlyName>
					<HexValue>0x00000022</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>35 FPS</UserfriendlyName>
					<HexValue>0x00000023</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>36 FPS</UserfriendlyName>
					<HexValue>0x00000024</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>37 FPS</UserfriendlyName>
					<HexValue>0x00000025</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>38 FPS</UserfriendlyName>
					<HexValue>0x00000026</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>39 FPS</UserfriendlyName>
					<HexValue>0x00000027</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>40 FPS</UserfriendlyName>
					<HexValue>0x00000028</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>41 FPS</UserfriendlyName>
					<HexValue>0x00000029</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>42 FPS</UserfriendlyName>
					<HexValue>0x0000002A</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>43 FPS</UserfriendlyName>
					<HexValue>0x0000002B</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>44 FPS</UserfriendlyName>
					<HexValue>0x0000002C</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>45 FPS</UserfriendlyName>
					<HexValue>0x0000002D</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>46 FPS</UserfriendlyName>
					<HexValue>0x0000002E</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>47 FPS</UserfriendlyName>
					<HexValue>0x0000002F</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>48 FPS</UserfriendlyName>
					<HexValue>0x00000030</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>49 FPS</UserfriendlyName>
					<HexValue>0x00000031</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>50 FPS</UserfriendlyName>
					<HexValue>0x00000032</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>51 FPS</UserfriendlyName>
					<HexValue>0x00000033</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>52 FPS</UserfriendlyName>
					<HexValue>0x00000034</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>53 FPS</UserfriendlyName>
					<HexValue>0x00000035</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>54 FPS</UserfriendlyName>
					<HexValue>0x00000036</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>55 FPS</UserfriendlyName>
					<HexValue>0x00000037</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>56 FPS</UserfriendlyName>
					<HexValue>0x00000038</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>57 FPS</UserfriendlyName>
					<HexValue>0x00000039</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>58 FPS</UserfriendlyName>
					<HexValue>0x0000003A</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>59 FPS</UserfriendlyName>
					<HexValue>0x0000003B</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>60 FPS</UserfriendlyName>
					<HexValue>0x0000003C</HexValue>
				</CustomSettingValue>
			</SettingValues>
		</CustomSetting>

		<CustomSetting>
			<UserfriendlyName>Shadercache - Cachesize</UserfriendlyName>
			<HexSettingID>0x00AC8497</HexSettingID>
			<GroupName>5 - Common</GroupName>
			<SettingValues>
				<CustomSettingValue>
					<UserfriendlyName>Off</UserfriendlyName>
					<HexValue>0x00000000</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>128MB</UserfriendlyName>
					<HexValue>0x00000080</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>256MB</UserfriendlyName>
					<HexValue>0x00000100</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>512MB</UserfriendlyName>
					<HexValue>0x00000200</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>1GB</UserfriendlyName>
					<HexValue>0x00000400</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>4GB</UserfriendlyName>
					<HexValue>0x00001000</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>5GB</UserfriendlyName>
					<HexValue>0x00001400</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>10GB</UserfriendlyName>
					<HexValue>0x00002800</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>100GB</UserfriendlyName>
					<HexValue>0x00019000</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>Unlimited</UserfriendlyName>
					<HexValue>0xFFFFFFFF</HexValue>
				</CustomSettingValue>
			</SettingValues>
		</CustomSetting>

		<CustomSetting>
			<UserfriendlyName>rBAR - Feature</UserfriendlyName>
			<HexSettingID>0X000F00BA</HexSettingID>
			<GroupName>5 - Common</GroupName>
			<SettingValues>
				<CustomSettingValue>
					<UserfriendlyName>Disabled</UserfriendlyName>
					<HexValue>0x00000000</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>Enabled</UserfriendlyName>
					<HexValue>0x00000001</HexValue>
				</CustomSettingValue>
			</SettingValues>
		</CustomSetting>

		<CustomSetting>
			<UserfriendlyName>rBAR - Options</UserfriendlyName>
			<HexSettingID>0X000F00BB</HexSettingID>
			<GroupName>5 - Common</GroupName>
		</CustomSetting>

		<CustomSetting>
			<UserfriendlyName>rBAR - Size Limit</UserfriendlyName>
			<HexSettingID>0X000F00FF</HexSettingID>
			<GroupName>5 - Common</GroupName>
			<DataType>BINARY</DataType>
		</CustomSetting>

		<CustomSetting>
			<UserfriendlyName>GSYNC - Support Indicator Overlay</UserfriendlyName>
			<HexSettingID>0X008DF510</HexSettingID>
			<GroupName>2 - Sync and Refresh</GroupName>
			<SettingValues>
				<CustomSettingValue>
					<UserfriendlyName>Off</UserfriendlyName>
					<HexValue>0x00000000</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>On</UserfriendlyName>
					<HexValue>0x00000004</HexValue>
				</CustomSettingValue>
			</SettingValues>
		</CustomSetting>

		<CustomSetting>
			<UserfriendlyName>Raytracing - (DXR) Enabled</UserfriendlyName>
			<HexSettingID>0X00DE429A</HexSettingID>
			<GroupName>5 - Common</GroupName>
			<OverrideDefault>0x00000001</OverrideDefault>
			<SettingValues>
				<CustomSettingValue>
					<UserfriendlyName>RT Disabled</UserfriendlyName>
					<HexValue>0x00000000</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>Default</UserfriendlyName>
					<HexValue>0x00000001</HexValue>
				</CustomSettingValue>
			</SettingValues>
		</CustomSetting>

		<CustomSetting>
			<UserfriendlyName>Raytracing - (Vulkan RT) Enabled </UserfriendlyName>
			<HexSettingID>0x20BC1A2B</HexSettingID>
			<GroupName>5 - Common</GroupName>
			<OverrideDefault>0x00000001</OverrideDefault>
			<SettingValues>
				<CustomSettingValue>
					<UserfriendlyName>RT Disabled</UserfriendlyName>
					<HexValue>0x00000000</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>Default</UserfriendlyName>
					<HexValue>0x00000001</HexValue>
				</CustomSettingValue>
			</SettingValues>
		</CustomSetting>

		<!--<CustomSetting>
      <HexSettingID>0x0005F512</HexSettingID>
      <Hidden>true</Hidden>
    </CustomSetting>
    <CustomSetting>
      <HexSettingID>0x1075D972</HexSettingID>
      <Hidden>true</Hidden>
    </CustomSetting>-->
		<CustomSetting>
			<UserfriendlyName>SLI - CFR Mode</UserfriendlyName>
			<HexSettingID>0x20343843</HexSettingID>
			<GroupName>6 - SLI</GroupName>
		</CustomSetting>
		<CustomSetting>
			<UserfriendlyName>Ansel - Enabled</UserfriendlyName>
			<HexSettingID>0x1075D972</HexSettingID>
			<GroupName>5 - Common</GroupName>
			<SettingValues>
				<CustomSettingValue>
					<UserfriendlyName>Off</UserfriendlyName>
					<HexValue>0x00000000</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>On</UserfriendlyName>
					<HexValue>0x00000001</HexValue>
				</CustomSettingValue>
			</SettingValues>
		</CustomSetting>
		<!--<CustomSetting>
      <UserfriendlyName>Sharpening Filter</UserfriendlyName>
      <HexSettingID>0x00598928</HexSettingID>
      <MinRequiredDriverVersion>441.87</MinRequiredDriverVersion>
      <GroupName>3 - Antialiasing</GroupName>
      <SettingValues>
        <CustomSettingValue>
          <UserfriendlyName>Off</UserfriendlyName>
          <HexValue>0x00000000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>On</UserfriendlyName>
          <HexValue>0x00000001</HexValue>
        </CustomSettingValue>
      </SettingValues>
    </CustomSetting>
    <CustomSetting>
      <UserfriendlyName>Sharpening Value</UserfriendlyName>
      <HexSettingID>0x002ED8CD</HexSettingID>
      <MinRequiredDriverVersion>441.87</MinRequiredDriverVersion>
      <GroupName>3 - Antialiasing</GroupName>
      <SettingValues>
        <CustomSettingValue>
          <UserfriendlyName>0.00</UserfriendlyName>
          <HexValue>0x00000000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.01</UserfriendlyName>
          <HexValue>0x00000001</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.02</UserfriendlyName>
          <HexValue>0x00000002</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.03</UserfriendlyName>
          <HexValue>0x00000003</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.04</UserfriendlyName>
          <HexValue>0x00000004</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.05</UserfriendlyName>
          <HexValue>0x00000005</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.06</UserfriendlyName>
          <HexValue>0x00000006</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.07</UserfriendlyName>
          <HexValue>0x00000007</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.08</UserfriendlyName>
          <HexValue>0x00000008</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.09</UserfriendlyName>
          <HexValue>0x00000009</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.10</UserfriendlyName>
          <HexValue>0x0000000A</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.11</UserfriendlyName>
          <HexValue>0x0000000B</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.12</UserfriendlyName>
          <HexValue>0x0000000C</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.13</UserfriendlyName>
          <HexValue>0x0000000D</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.14</UserfriendlyName>
          <HexValue>0x0000000E</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.15</UserfriendlyName>
          <HexValue>0x0000000F</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.16</UserfriendlyName>
          <HexValue>0x00000010</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.17</UserfriendlyName>
          <HexValue>0x00000011</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.18</UserfriendlyName>
          <HexValue>0x00000012</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.19</UserfriendlyName>
          <HexValue>0x00000013</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.20</UserfriendlyName>
          <HexValue>0x00000014</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.21</UserfriendlyName>
          <HexValue>0x00000015</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.22</UserfriendlyName>
          <HexValue>0x00000015</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.23</UserfriendlyName>
          <HexValue>0x00000016</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.23</UserfriendlyName>
          <HexValue>0x00000017</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.24</UserfriendlyName>
          <HexValue>0x00000018</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.25</UserfriendlyName>
          <HexValue>0x00000019</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.26</UserfriendlyName>
          <HexValue>0x0000001A</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.27</UserfriendlyName>
          <HexValue>0x0000001B</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.28</UserfriendlyName>
          <HexValue>0x0000001C</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.29</UserfriendlyName>
          <HexValue>0x0000001D</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.30</UserfriendlyName>
          <HexValue>0x0000001E</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.31</UserfriendlyName>
          <HexValue>0x0000001F</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.32</UserfriendlyName>
          <HexValue>0x00000020</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.33</UserfriendlyName>
          <HexValue>0x00000021</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.34</UserfriendlyName>
          <HexValue>0x00000022</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.35</UserfriendlyName>
          <HexValue>0x00000023</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.36</UserfriendlyName>
          <HexValue>0x00000024</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.37</UserfriendlyName>
          <HexValue>0x00000025</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.38</UserfriendlyName>
          <HexValue>0x00000026</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.39</UserfriendlyName>
          <HexValue>0x00000027</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.40</UserfriendlyName>
          <HexValue>0x00000028</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.41</UserfriendlyName>
          <HexValue>0x00000029</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.42</UserfriendlyName>
          <HexValue>0x0000002A</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.43</UserfriendlyName>
          <HexValue>0x0000002B</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.44</UserfriendlyName>
          <HexValue>0x0000002C</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.45</UserfriendlyName>
          <HexValue>0x0000002D</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.46</UserfriendlyName>
          <HexValue>0x0000002E</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.47</UserfriendlyName>
          <HexValue>0x0000002F</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.48</UserfriendlyName>
          <HexValue>0x00000030</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.49</UserfriendlyName>
          <HexValue>0x00000031</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.50</UserfriendlyName>
          <HexValue>0x00000032</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.51</UserfriendlyName>
          <HexValue>0x00000033</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.52</UserfriendlyName>
          <HexValue>0x00000034</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.53</UserfriendlyName>
          <HexValue>0x00000035</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.54</UserfriendlyName>
          <HexValue>0x00000036</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.55</UserfriendlyName>
          <HexValue>0x00000037</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.56</UserfriendlyName>
          <HexValue>0x00000038</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.57</UserfriendlyName>
          <HexValue>0x00000039</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.58</UserfriendlyName>
          <HexValue>0x0000003A</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.59</UserfriendlyName>
          <HexValue>0x0000003B</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.60</UserfriendlyName>
          <HexValue>0x0000003C</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.61</UserfriendlyName>
          <HexValue>0x0000003D</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.62</UserfriendlyName>
          <HexValue>0x0000003E</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.63</UserfriendlyName>
          <HexValue>0x0000003F</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.64</UserfriendlyName>
          <HexValue>0x00000040</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.65</UserfriendlyName>
          <HexValue>0x00000041</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.66</UserfriendlyName>
          <HexValue>0x00000042</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.67</UserfriendlyName>
          <HexValue>0x00000043</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.68</UserfriendlyName>
          <HexValue>0x00000044</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.69</UserfriendlyName>
          <HexValue>0x00000045</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.70</UserfriendlyName>
          <HexValue>0x00000046</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.71</UserfriendlyName>
          <HexValue>0x00000047</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.72</UserfriendlyName>
          <HexValue>0x00000048</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.73</UserfriendlyName>
          <HexValue>0x00000049</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.74</UserfriendlyName>
          <HexValue>0x0000004A</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.75</UserfriendlyName>
          <HexValue>0x0000004B</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.76</UserfriendlyName>
          <HexValue>0x0000004C</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.77</UserfriendlyName>
          <HexValue>0x0000004D</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.78</UserfriendlyName>
          <HexValue>0x0000004E</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.79</UserfriendlyName>
          <HexValue>0x0000004F</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.80</UserfriendlyName>
          <HexValue>0x00000050</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.81</UserfriendlyName>
          <HexValue>0x00000051</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.82</UserfriendlyName>
          <HexValue>0x00000052</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.83</UserfriendlyName>
          <HexValue>0x00000053</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.84</UserfriendlyName>
          <HexValue>0x00000054</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.85</UserfriendlyName>
          <HexValue>0x00000055</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.86</UserfriendlyName>
          <HexValue>0x00000056</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.87</UserfriendlyName>
          <HexValue>0x00000057</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.88</UserfriendlyName>
          <HexValue>0x00000058</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.89</UserfriendlyName>
          <HexValue>0x00000059</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.90</UserfriendlyName>
          <HexValue>0x0000005A</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.91</UserfriendlyName>
          <HexValue>0x0000005B</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.92</UserfriendlyName>
          <HexValue>0x0000005C</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.93</UserfriendlyName>
          <HexValue>0x0000005D</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.94</UserfriendlyName>
          <HexValue>0x0000005E</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.95</UserfriendlyName>
          <HexValue>0x0000005F</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.96</UserfriendlyName>
          <HexValue>0x00000060</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.97</UserfriendlyName>
          <HexValue>0x00000061</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.98</UserfriendlyName>
          <HexValue>0x00000062</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.99</UserfriendlyName>
          <HexValue>0x00000063</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>1.00</UserfriendlyName>
          <HexValue>0x00000064</HexValue>
        </CustomSettingValue>
      </SettingValues>
      <SettingMasks />
    </CustomSetting>-->
		<!--
    <CustomSetting>
      <UserfriendlyName>Sharpening - Denoising Factor</UserfriendlyName>
      <HexSettingID>0x002ED8CE</HexSettingID>
      <MinRequiredDriverVersion>441.87</MinRequiredDriverVersion>
      <GroupName>3 - Antialiasing</GroupName>
      <SettingValues>
        <CustomSettingValue>
          <UserfriendlyName>0.00</UserfriendlyName>
          <HexValue>0x00000000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.01</UserfriendlyName>
          <HexValue>0x00000001</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.02</UserfriendlyName>
          <HexValue>0x00000002</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.03</UserfriendlyName>
          <HexValue>0x00000003</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.04</UserfriendlyName>
          <HexValue>0x00000004</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.05</UserfriendlyName>
          <HexValue>0x00000005</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.06</UserfriendlyName>
          <HexValue>0x00000006</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.07</UserfriendlyName>
          <HexValue>0x00000007</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.08</UserfriendlyName>
          <HexValue>0x00000008</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.09</UserfriendlyName>
          <HexValue>0x00000009</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.10</UserfriendlyName>
          <HexValue>0x0000000A</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.11</UserfriendlyName>
          <HexValue>0x0000000B</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.12</UserfriendlyName>
          <HexValue>0x0000000C</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.13</UserfriendlyName>
          <HexValue>0x0000000D</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.14</UserfriendlyName>
          <HexValue>0x0000000E</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.15</UserfriendlyName>
          <HexValue>0x0000000F</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.16</UserfriendlyName>
          <HexValue>0x00000010</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.17</UserfriendlyName>
          <HexValue>0x00000011</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.18</UserfriendlyName>
          <HexValue>0x00000012</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.19</UserfriendlyName>
          <HexValue>0x00000013</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.20</UserfriendlyName>
          <HexValue>0x00000014</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.21</UserfriendlyName>
          <HexValue>0x00000015</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.22</UserfriendlyName>
          <HexValue>0x00000015</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.23</UserfriendlyName>
          <HexValue>0x00000016</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.23</UserfriendlyName>
          <HexValue>0x00000017</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.24</UserfriendlyName>
          <HexValue>0x00000018</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.25</UserfriendlyName>
          <HexValue>0x00000019</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.26</UserfriendlyName>
          <HexValue>0x0000001A</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.27</UserfriendlyName>
          <HexValue>0x0000001B</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.28</UserfriendlyName>
          <HexValue>0x0000001C</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.29</UserfriendlyName>
          <HexValue>0x0000001D</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.30</UserfriendlyName>
          <HexValue>0x0000001E</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.31</UserfriendlyName>
          <HexValue>0x0000001F</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.32</UserfriendlyName>
          <HexValue>0x00000020</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.33</UserfriendlyName>
          <HexValue>0x00000021</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.34</UserfriendlyName>
          <HexValue>0x00000022</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.35</UserfriendlyName>
          <HexValue>0x00000023</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.36</UserfriendlyName>
          <HexValue>0x00000024</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.37</UserfriendlyName>
          <HexValue>0x00000025</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.38</UserfriendlyName>
          <HexValue>0x00000026</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.39</UserfriendlyName>
          <HexValue>0x00000027</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.40</UserfriendlyName>
          <HexValue>0x00000028</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.41</UserfriendlyName>
          <HexValue>0x00000029</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.42</UserfriendlyName>
          <HexValue>0x0000002A</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.43</UserfriendlyName>
          <HexValue>0x0000002B</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.44</UserfriendlyName>
          <HexValue>0x0000002C</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.45</UserfriendlyName>
          <HexValue>0x0000002D</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.46</UserfriendlyName>
          <HexValue>0x0000002E</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.47</UserfriendlyName>
          <HexValue>0x0000002F</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.48</UserfriendlyName>
          <HexValue>0x00000030</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.49</UserfriendlyName>
          <HexValue>0x00000031</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.50</UserfriendlyName>
          <HexValue>0x00000032</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.51</UserfriendlyName>
          <HexValue>0x00000033</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.52</UserfriendlyName>
          <HexValue>0x00000034</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.53</UserfriendlyName>
          <HexValue>0x00000035</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.54</UserfriendlyName>
          <HexValue>0x00000036</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.55</UserfriendlyName>
          <HexValue>0x00000037</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.56</UserfriendlyName>
          <HexValue>0x00000038</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.57</UserfriendlyName>
          <HexValue>0x00000039</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.58</UserfriendlyName>
          <HexValue>0x0000003A</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.59</UserfriendlyName>
          <HexValue>0x0000003B</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.60</UserfriendlyName>
          <HexValue>0x0000003C</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.61</UserfriendlyName>
          <HexValue>0x0000003D</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.62</UserfriendlyName>
          <HexValue>0x0000003E</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.63</UserfriendlyName>
          <HexValue>0x0000003F</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.64</UserfriendlyName>
          <HexValue>0x00000040</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.65</UserfriendlyName>
          <HexValue>0x00000041</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.66</UserfriendlyName>
          <HexValue>0x00000042</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.67</UserfriendlyName>
          <HexValue>0x00000043</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.68</UserfriendlyName>
          <HexValue>0x00000044</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.69</UserfriendlyName>
          <HexValue>0x00000045</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.70</UserfriendlyName>
          <HexValue>0x00000046</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.71</UserfriendlyName>
          <HexValue>0x00000047</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.72</UserfriendlyName>
          <HexValue>0x00000048</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.73</UserfriendlyName>
          <HexValue>0x00000049</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.74</UserfriendlyName>
          <HexValue>0x0000004A</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.75</UserfriendlyName>
          <HexValue>0x0000004B</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.76</UserfriendlyName>
          <HexValue>0x0000004C</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.77</UserfriendlyName>
          <HexValue>0x0000004D</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.78</UserfriendlyName>
          <HexValue>0x0000004E</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.79</UserfriendlyName>
          <HexValue>0x0000004F</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.80</UserfriendlyName>
          <HexValue>0x00000050</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.81</UserfriendlyName>
          <HexValue>0x00000051</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.82</UserfriendlyName>
          <HexValue>0x00000052</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.83</UserfriendlyName>
          <HexValue>0x00000053</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.84</UserfriendlyName>
          <HexValue>0x00000054</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.85</UserfriendlyName>
          <HexValue>0x00000055</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.86</UserfriendlyName>
          <HexValue>0x00000056</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.87</UserfriendlyName>
          <HexValue>0x00000057</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.88</UserfriendlyName>
          <HexValue>0x00000058</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.89</UserfriendlyName>
          <HexValue>0x00000059</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.90</UserfriendlyName>
          <HexValue>0x0000005A</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.91</UserfriendlyName>
          <HexValue>0x0000005B</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.92</UserfriendlyName>
          <HexValue>0x0000005C</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.93</UserfriendlyName>
          <HexValue>0x0000005D</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.94</UserfriendlyName>
          <HexValue>0x0000005E</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.95</UserfriendlyName>
          <HexValue>0x0000005F</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.96</UserfriendlyName>
          <HexValue>0x00000060</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.97</UserfriendlyName>
          <HexValue>0x00000061</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.98</UserfriendlyName>
          <HexValue>0x00000062</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.99</UserfriendlyName>
          <HexValue>0x00000063</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>1.00</UserfriendlyName>
          <HexValue>0x00000064</HexValue>
        </CustomSettingValue>
      </SettingValues>
      <SettingMasks />
    </CustomSetting>-->
		<CustomSetting>
			<UserfriendlyName>Frame Rate Limiter V3</UserfriendlyName>
			<HexSettingID>0x10835002</HexSettingID>
			<MinRequiredDriverVersion>441.87</MinRequiredDriverVersion>
			<GroupName>2 - Sync and Refresh</GroupName>
			<SettingValues>
				<CustomSettingValue>
					<UserfriendlyName>Off</UserfriendlyName>
					<HexValue>0x00000000</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>20 FPS</UserfriendlyName>
					<HexValue>0x00000014</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>21 FPS</UserfriendlyName>
					<HexValue>0x00000015</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>22 FPS</UserfriendlyName>
					<HexValue>0x00000016</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>23 FPS</UserfriendlyName>
					<HexValue>0x00000017</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>24 FPS</UserfriendlyName>
					<HexValue>0x00000018</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>25 FPS</UserfriendlyName>
					<HexValue>0x00000019</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>26 FPS</UserfriendlyName>
					<HexValue>0x0000001A</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>27 FPS</UserfriendlyName>
					<HexValue>0x0000001B</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>28 FPS</UserfriendlyName>
					<HexValue>0x0000001C</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>29 FPS</UserfriendlyName>
					<HexValue>0x0000001D</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>30 FPS</UserfriendlyName>
					<HexValue>0x0000001E</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>31 FPS</UserfriendlyName>
					<HexValue>0x0000001F</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>32 FPS</UserfriendlyName>
					<HexValue>0x00000020</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>33 FPS</UserfriendlyName>
					<HexValue>0x00000021</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>34 FPS</UserfriendlyName>
					<HexValue>0x00000022</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>35 FPS</UserfriendlyName>
					<HexValue>0x00000023</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>36 FPS</UserfriendlyName>
					<HexValue>0x00000024</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>37 FPS</UserfriendlyName>
					<HexValue>0x00000025</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>38 FPS</UserfriendlyName>
					<HexValue>0x00000026</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>39 FPS</UserfriendlyName>
					<HexValue>0x00000027</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>40 FPS</UserfriendlyName>
					<HexValue>0x00000028</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>41 FPS</UserfriendlyName>
					<HexValue>0x00000029</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>42 FPS</UserfriendlyName>
					<HexValue>0x0000002A</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>43 FPS</UserfriendlyName>
					<HexValue>0x0000002B</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>44 FPS</UserfriendlyName>
					<HexValue>0x0000002C</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>45 FPS</UserfriendlyName>
					<HexValue>0x0000002D</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>46 FPS</UserfriendlyName>
					<HexValue>0x0000002E</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>47 FPS</UserfriendlyName>
					<HexValue>0x0000002F</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>48 FPS</UserfriendlyName>
					<HexValue>0x00000030</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>49 FPS</UserfriendlyName>
					<HexValue>0x00000031</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>50 FPS</UserfriendlyName>
					<HexValue>0x00000032</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>51 FPS</UserfriendlyName>
					<HexValue>0x00000033</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>52 FPS</UserfriendlyName>
					<HexValue>0x00000034</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>53 FPS</UserfriendlyName>
					<HexValue>0x00000035</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>54 FPS</UserfriendlyName>
					<HexValue>0x00000036</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>55 FPS</UserfriendlyName>
					<HexValue>0x00000037</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>56 FPS</UserfriendlyName>
					<HexValue>0x00000038</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>57 FPS</UserfriendlyName>
					<HexValue>0x00000039</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>58 FPS</UserfriendlyName>
					<HexValue>0x0000003A</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>59 FPS</UserfriendlyName>
					<HexValue>0x0000003B</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>60 FPS</UserfriendlyName>
					<HexValue>0x0000003C</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>61 FPS</UserfriendlyName>
					<HexValue>0x0000003D</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>62 FPS</UserfriendlyName>
					<HexValue>0x0000003E</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>63 FPS</UserfriendlyName>
					<HexValue>0x0000003F</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>64 FPS</UserfriendlyName>
					<HexValue>0x00000040</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>65 FPS</UserfriendlyName>
					<HexValue>0x00000041</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>66 FPS</UserfriendlyName>
					<HexValue>0x00000042</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>67 FPS</UserfriendlyName>
					<HexValue>0x00000043</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>68 FPS</UserfriendlyName>
					<HexValue>0x00000044</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>69 FPS</UserfriendlyName>
					<HexValue>0x00000045</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>70 FPS</UserfriendlyName>
					<HexValue>0x00000046</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>71 FPS</UserfriendlyName>
					<HexValue>0x00000047</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>72 FPS</UserfriendlyName>
					<HexValue>0x00000048</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>73 FPS</UserfriendlyName>
					<HexValue>0x00000049</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>74 FPS</UserfriendlyName>
					<HexValue>0x0000004A</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>75 FPS</UserfriendlyName>
					<HexValue>0x0000004B</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>76 FPS</UserfriendlyName>
					<HexValue>0x0000004C</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>77 FPS</UserfriendlyName>
					<HexValue>0x0000004D</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>78 FPS</UserfriendlyName>
					<HexValue>0x0000004E</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>79 FPS</UserfriendlyName>
					<HexValue>0x0000004F</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>80 FPS</UserfriendlyName>
					<HexValue>0x00000050</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>81 FPS</UserfriendlyName>
					<HexValue>0x00000051</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>82 FPS</UserfriendlyName>
					<HexValue>0x00000052</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>83 FPS</UserfriendlyName>
					<HexValue>0x00000053</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>84 FPS</UserfriendlyName>
					<HexValue>0x00000054</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>85 FPS</UserfriendlyName>
					<HexValue>0x00000055</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>86 FPS</UserfriendlyName>
					<HexValue>0x00000056</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>87 FPS</UserfriendlyName>
					<HexValue>0x00000057</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>88 FPS</UserfriendlyName>
					<HexValue>0x00000058</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>89 FPS</UserfriendlyName>
					<HexValue>0x00000059</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>90 FPS</UserfriendlyName>
					<HexValue>0x0000005A</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>91 FPS</UserfriendlyName>
					<HexValue>0x0000005B</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>92 FPS</UserfriendlyName>
					<HexValue>0x0000005C</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>93 FPS</UserfriendlyName>
					<HexValue>0x0000005D</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>94 FPS</UserfriendlyName>
					<HexValue>0x0000005E</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>95 FPS</UserfriendlyName>
					<HexValue>0x0000005F</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>96 FPS</UserfriendlyName>
					<HexValue>0x00000060</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>97 FPS</UserfriendlyName>
					<HexValue>0x00000061</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>98 FPS</UserfriendlyName>
					<HexValue>0x00000062</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>99 FPS</UserfriendlyName>
					<HexValue>0x00000063</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>100 FPS</UserfriendlyName>
					<HexValue>0x00000064</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>101 FPS</UserfriendlyName>
					<HexValue>0x00000065</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>102 FPS</UserfriendlyName>
					<HexValue>0x00000066</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>103 FPS</UserfriendlyName>
					<HexValue>0x00000067</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>104 FPS</UserfriendlyName>
					<HexValue>0x00000068</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>105 FPS</UserfriendlyName>
					<HexValue>0x00000069</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>106 FPS</UserfriendlyName>
					<HexValue>0x0000006A</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>107 FPS</UserfriendlyName>
					<HexValue>0x0000006B</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>108 FPS</UserfriendlyName>
					<HexValue>0x0000006C</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>109 FPS</UserfriendlyName>
					<HexValue>0x0000006D</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>110 FPS</UserfriendlyName>
					<HexValue>0x0000006E</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>111 FPS</UserfriendlyName>
					<HexValue>0x0000006F</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>112 FPS</UserfriendlyName>
					<HexValue>0x00000070</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>113 FPS</UserfriendlyName>
					<HexValue>0x00000071</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>114 FPS</UserfriendlyName>
					<HexValue>0x00000072</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>115 FPS</UserfriendlyName>
					<HexValue>0x00000073</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>116 FPS</UserfriendlyName>
					<HexValue>0x00000074</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>117 FPS</UserfriendlyName>
					<HexValue>0x00000075</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>118 FPS</UserfriendlyName>
					<HexValue>0x00000076</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>119 FPS</UserfriendlyName>
					<HexValue>0x00000077</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>120 FPS</UserfriendlyName>
					<HexValue>0x00000078</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>121 FPS</UserfriendlyName>
					<HexValue>0x00000079</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>122 FPS</UserfriendlyName>
					<HexValue>0x0000007A</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>123 FPS</UserfriendlyName>
					<HexValue>0x0000007B</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>124 FPS</UserfriendlyName>
					<HexValue>0x0000007C</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>125 FPS</UserfriendlyName>
					<HexValue>0x0000007D</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>126 FPS</UserfriendlyName>
					<HexValue>0x0000007E</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>127 FPS</UserfriendlyName>
					<HexValue>0x0000007F</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>128 FPS</UserfriendlyName>
					<HexValue>0x00000080</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>129 FPS</UserfriendlyName>
					<HexValue>0x00000081</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>130 FPS</UserfriendlyName>
					<HexValue>0x00000082</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>131 FPS</UserfriendlyName>
					<HexValue>0x00000083</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>132 FPS</UserfriendlyName>
					<HexValue>0x00000084</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>133 FPS</UserfriendlyName>
					<HexValue>0x00000085</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>134 FPS</UserfriendlyName>
					<HexValue>0x00000086</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>135 FPS</UserfriendlyName>
					<HexValue>0x00000087</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>136 FPS</UserfriendlyName>
					<HexValue>0x00000088</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>137 FPS</UserfriendlyName>
					<HexValue>0x00000089</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>138 FPS</UserfriendlyName>
					<HexValue>0x0000008A</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>139 FPS</UserfriendlyName>
					<HexValue>0x0000008B</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>140 FPS</UserfriendlyName>
					<HexValue>0x0000008C</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>141 FPS</UserfriendlyName>
					<HexValue>0x0000008D</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>142 FPS</UserfriendlyName>
					<HexValue>0x0000008E</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>143 FPS</UserfriendlyName>
					<HexValue>0x0000008F</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>144 FPS</UserfriendlyName>
					<HexValue>0x00000090</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>145 FPS</UserfriendlyName>
					<HexValue>0x00000091</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>146 FPS</UserfriendlyName>
					<HexValue>0x00000092</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>147 FPS</UserfriendlyName>
					<HexValue>0x00000093</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>148 FPS</UserfriendlyName>
					<HexValue>0x00000094</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>149 FPS</UserfriendlyName>
					<HexValue>0x00000095</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>150 FPS</UserfriendlyName>
					<HexValue>0x00000096</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>151 FPS</UserfriendlyName>
					<HexValue>0x00000097</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>152 FPS</UserfriendlyName>
					<HexValue>0x00000098</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>153 FPS</UserfriendlyName>
					<HexValue>0x00000099</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>154 FPS</UserfriendlyName>
					<HexValue>0x0000009A</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>155 FPS</UserfriendlyName>
					<HexValue>0x0000009B</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>156 FPS</UserfriendlyName>
					<HexValue>0x0000009C</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>157 FPS</UserfriendlyName>
					<HexValue>0x0000009D</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>158 FPS</UserfriendlyName>
					<HexValue>0x0000009E</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>159 FPS</UserfriendlyName>
					<HexValue>0x0000009F</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>160 FPS</UserfriendlyName>
					<HexValue>0x000000A0</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>161 FPS</UserfriendlyName>
					<HexValue>0x000000A1</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>162 FPS</UserfriendlyName>
					<HexValue>0x000000A2</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>163 FPS</UserfriendlyName>
					<HexValue>0x000000A3</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>164 FPS</UserfriendlyName>
					<HexValue>0x000000A4</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>165 FPS</UserfriendlyName>
					<HexValue>0x000000A5</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>166 FPS</UserfriendlyName>
					<HexValue>0x000000A6</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>167 FPS</UserfriendlyName>
					<HexValue>0x000000A7</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>168 FPS</UserfriendlyName>
					<HexValue>0x000000A8</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>169 FPS</UserfriendlyName>
					<HexValue>0x000000A9</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>170 FPS</UserfriendlyName>
					<HexValue>0x000000AA</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>171 FPS</UserfriendlyName>
					<HexValue>0x000000AB</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>172 FPS</UserfriendlyName>
					<HexValue>0x000000AC</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>173 FPS</UserfriendlyName>
					<HexValue>0x000000AD</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>174 FPS</UserfriendlyName>
					<HexValue>0x000000AE</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>175 FPS</UserfriendlyName>
					<HexValue>0x000000AF</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>176 FPS</UserfriendlyName>
					<HexValue>0x000000B0</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>177 FPS</UserfriendlyName>
					<HexValue>0x000000B1</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>178 FPS</UserfriendlyName>
					<HexValue>0x000000B2</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>179 FPS</UserfriendlyName>
					<HexValue>0x000000B3</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>180 FPS</UserfriendlyName>
					<HexValue>0x000000B4</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>181 FPS</UserfriendlyName>
					<HexValue>0x000000B5</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>182 FPS</UserfriendlyName>
					<HexValue>0x000000B6</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>183 FPS</UserfriendlyName>
					<HexValue>0x000000B7</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>184 FPS</UserfriendlyName>
					<HexValue>0x000000B8</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>185 FPS</UserfriendlyName>
					<HexValue>0x000000B9</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>186 FPS</UserfriendlyName>
					<HexValue>0x000000BA</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>187 FPS</UserfriendlyName>
					<HexValue>0x000000BB</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>188 FPS</UserfriendlyName>
					<HexValue>0x000000BC</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>189 FPS</UserfriendlyName>
					<HexValue>0x000000BD</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>190 FPS</UserfriendlyName>
					<HexValue>0x000000BE</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>191 FPS</UserfriendlyName>
					<HexValue>0x000000BF</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>192 FPS</UserfriendlyName>
					<HexValue>0x000000C0</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>193 FPS</UserfriendlyName>
					<HexValue>0x000000C1</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>194 FPS</UserfriendlyName>
					<HexValue>0x000000C2</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>195 FPS</UserfriendlyName>
					<HexValue>0x000000C3</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>196 FPS</UserfriendlyName>
					<HexValue>0x000000C4</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>197 FPS</UserfriendlyName>
					<HexValue>0x000000C5</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>198 FPS</UserfriendlyName>
					<HexValue>0x000000C6</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>199 FPS</UserfriendlyName>
					<HexValue>0x000000C7</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>200 FPS</UserfriendlyName>
					<HexValue>0x000000C8</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>201 FPS</UserfriendlyName>
					<HexValue>0x000000C9</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>202 FPS</UserfriendlyName>
					<HexValue>0x000000CA</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>203 FPS</UserfriendlyName>
					<HexValue>0x000000CB</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>204 FPS</UserfriendlyName>
					<HexValue>0x000000CC</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>205 FPS</UserfriendlyName>
					<HexValue>0x000000CD</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>206 FPS</UserfriendlyName>
					<HexValue>0x000000CE</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>207 FPS</UserfriendlyName>
					<HexValue>0x000000CF</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>208 FPS</UserfriendlyName>
					<HexValue>0x000000D0</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>209 FPS</UserfriendlyName>
					<HexValue>0x000000D1</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>210 FPS</UserfriendlyName>
					<HexValue>0x000000D2</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>211 FPS</UserfriendlyName>
					<HexValue>0x000000D3</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>212 FPS</UserfriendlyName>
					<HexValue>0x000000D4</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>213 FPS</UserfriendlyName>
					<HexValue>0x000000D5</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>214 FPS</UserfriendlyName>
					<HexValue>0x000000D6</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>215 FPS</UserfriendlyName>
					<HexValue>0x000000D7</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>216 FPS</UserfriendlyName>
					<HexValue>0x000000D8</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>217 FPS</UserfriendlyName>
					<HexValue>0x000000D9</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>218 FPS</UserfriendlyName>
					<HexValue>0x000000DA</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>219 FPS</UserfriendlyName>
					<HexValue>0x000000DB</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>220 FPS</UserfriendlyName>
					<HexValue>0x000000DC</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>221 FPS</UserfriendlyName>
					<HexValue>0x000000DD</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>222 FPS</UserfriendlyName>
					<HexValue>0x000000DE</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>223 FPS</UserfriendlyName>
					<HexValue>0x000000DF</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>224 FPS</UserfriendlyName>
					<HexValue>0x000000E0</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>225 FPS</UserfriendlyName>
					<HexValue>0x000000E1</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>226 FPS</UserfriendlyName>
					<HexValue>0x000000E2</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>227 FPS</UserfriendlyName>
					<HexValue>0x000000E3</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>228 FPS</UserfriendlyName>
					<HexValue>0x000000E4</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>229 FPS</UserfriendlyName>
					<HexValue>0x000000E5</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>230 FPS</UserfriendlyName>
					<HexValue>0x000000E6</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>231 FPS</UserfriendlyName>
					<HexValue>0x000000E7</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>232 FPS</UserfriendlyName>
					<HexValue>0x000000E8</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>233 FPS</UserfriendlyName>
					<HexValue>0x000000E9</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>234 FPS</UserfriendlyName>
					<HexValue>0x000000EA</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>235 FPS</UserfriendlyName>
					<HexValue>0x000000EB</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>236 FPS</UserfriendlyName>
					<HexValue>0x000000EC</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>237 FPS</UserfriendlyName>
					<HexValue>0x000000ED</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>238 FPS</UserfriendlyName>
					<HexValue>0x000000EE</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>239 FPS</UserfriendlyName>
					<HexValue>0x000000EF</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>240 FPS</UserfriendlyName>
					<HexValue>0x000000F0</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>241 FPS</UserfriendlyName>
					<HexValue>0x000000F1</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>242 FPS</UserfriendlyName>
					<HexValue>0x000000F2</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>243 FPS</UserfriendlyName>
					<HexValue>0x000000F3</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>244 FPS</UserfriendlyName>
					<HexValue>0x000000F4</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>245 FPS</UserfriendlyName>
					<HexValue>0x000000F5</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>246 FPS</UserfriendlyName>
					<HexValue>0x000000F6</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>247 FPS</UserfriendlyName>
					<HexValue>0x000000F7</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>248 FPS</UserfriendlyName>
					<HexValue>0x000000F8</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>249 FPS</UserfriendlyName>
					<HexValue>0x000000F9</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>250 FPS</UserfriendlyName>
					<HexValue>0x000000FA</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>251 FPS</UserfriendlyName>
					<HexValue>0x000000FB</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>252 FPS</UserfriendlyName>
					<HexValue>0x000000FC</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>253 FPS</UserfriendlyName>
					<HexValue>0x000000FD</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>254 FPS</UserfriendlyName>
					<HexValue>0x000000FE</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>255 FPS</UserfriendlyName>
					<HexValue>0x000000FF</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>256 FPS</UserfriendlyName>
					<HexValue>0x00000100</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>257 FPS</UserfriendlyName>
					<HexValue>0x00000101</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>258 FPS</UserfriendlyName>
					<HexValue>0x00000102</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>259 FPS</UserfriendlyName>
					<HexValue>0x00000103</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>260 FPS</UserfriendlyName>
					<HexValue>0x00000104</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>261 FPS</UserfriendlyName>
					<HexValue>0x00000105</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>262 FPS</UserfriendlyName>
					<HexValue>0x00000106</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>263 FPS</UserfriendlyName>
					<HexValue>0x00000107</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>264 FPS</UserfriendlyName>
					<HexValue>0x00000108</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>265 FPS</UserfriendlyName>
					<HexValue>0x00000109</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>266 FPS</UserfriendlyName>
					<HexValue>0x0000010A</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>267 FPS</UserfriendlyName>
					<HexValue>0x0000010B</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>268 FPS</UserfriendlyName>
					<HexValue>0x0000010C</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>269 FPS</UserfriendlyName>
					<HexValue>0x0000010D</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>270 FPS</UserfriendlyName>
					<HexValue>0x0000010E</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>271 FPS</UserfriendlyName>
					<HexValue>0x0000010F</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>272 FPS</UserfriendlyName>
					<HexValue>0x00000110</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>273 FPS</UserfriendlyName>
					<HexValue>0x00000111</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>274 FPS</UserfriendlyName>
					<HexValue>0x00000112</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>275 FPS</UserfriendlyName>
					<HexValue>0x00000113</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>276 FPS</UserfriendlyName>
					<HexValue>0x00000114</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>277 FPS</UserfriendlyName>
					<HexValue>0x00000115</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>278 FPS</UserfriendlyName>
					<HexValue>0x00000116</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>279 FPS</UserfriendlyName>
					<HexValue>0x00000117</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>280 FPS</UserfriendlyName>
					<HexValue>0x00000118</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>281 FPS</UserfriendlyName>
					<HexValue>0x00000119</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>282 FPS</UserfriendlyName>
					<HexValue>0x0000011A</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>283 FPS</UserfriendlyName>
					<HexValue>0x0000011B</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>284 FPS</UserfriendlyName>
					<HexValue>0x0000011C</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>285 FPS</UserfriendlyName>
					<HexValue>0x0000011D</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>286 FPS</UserfriendlyName>
					<HexValue>0x0000011E</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>287 FPS</UserfriendlyName>
					<HexValue>0x0000011F</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>288 FPS</UserfriendlyName>
					<HexValue>0x00000120</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>289 FPS</UserfriendlyName>
					<HexValue>0x00000121</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>290 FPS</UserfriendlyName>
					<HexValue>0x00000122</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>291 FPS</UserfriendlyName>
					<HexValue>0x00000123</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>292 FPS</UserfriendlyName>
					<HexValue>0x00000124</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>293 FPS</UserfriendlyName>
					<HexValue>0x00000125</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>294 FPS</UserfriendlyName>
					<HexValue>0x00000126</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>295 FPS</UserfriendlyName>
					<HexValue>0x00000127</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>296 FPS</UserfriendlyName>
					<HexValue>0x00000128</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>297 FPS</UserfriendlyName>
					<HexValue>0x00000129</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>298 FPS</UserfriendlyName>
					<HexValue>0x0000012A</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>299 FPS</UserfriendlyName>
					<HexValue>0x0000012B</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>300 FPS</UserfriendlyName>
					<HexValue>0x0000012C</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>301 FPS</UserfriendlyName>
					<HexValue>0x0000012D</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>302 FPS</UserfriendlyName>
					<HexValue>0x0000012E</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>303 FPS</UserfriendlyName>
					<HexValue>0x0000012F</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>304 FPS</UserfriendlyName>
					<HexValue>0x00000130</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>305 FPS</UserfriendlyName>
					<HexValue>0x00000131</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>306 FPS</UserfriendlyName>
					<HexValue>0x00000132</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>307 FPS</UserfriendlyName>
					<HexValue>0x00000133</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>308 FPS</UserfriendlyName>
					<HexValue>0x00000134</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>309 FPS</UserfriendlyName>
					<HexValue>0x00000135</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>310 FPS</UserfriendlyName>
					<HexValue>0x00000136</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>311 FPS</UserfriendlyName>
					<HexValue>0x00000137</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>312 FPS</UserfriendlyName>
					<HexValue>0x00000138</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>313 FPS</UserfriendlyName>
					<HexValue>0x00000139</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>314 FPS</UserfriendlyName>
					<HexValue>0x0000013A</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>315 FPS</UserfriendlyName>
					<HexValue>0x0000013B</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>316 FPS</UserfriendlyName>
					<HexValue>0x0000013C</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>317 FPS</UserfriendlyName>
					<HexValue>0x0000013D</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>318 FPS</UserfriendlyName>
					<HexValue>0x0000013E</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>319 FPS</UserfriendlyName>
					<HexValue>0x0000013F</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>320 FPS</UserfriendlyName>
					<HexValue>0x00000140</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>321 FPS</UserfriendlyName>
					<HexValue>0x00000141</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>322 FPS</UserfriendlyName>
					<HexValue>0x00000142</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>323 FPS</UserfriendlyName>
					<HexValue>0x00000143</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>324 FPS</UserfriendlyName>
					<HexValue>0x00000144</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>325 FPS</UserfriendlyName>
					<HexValue>0x00000145</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>326 FPS</UserfriendlyName>
					<HexValue>0x00000146</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>327 FPS</UserfriendlyName>
					<HexValue>0x00000147</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>328 FPS</UserfriendlyName>
					<HexValue>0x00000148</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>329 FPS</UserfriendlyName>
					<HexValue>0x00000149</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>330 FPS</UserfriendlyName>
					<HexValue>0x0000014A</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>331 FPS</UserfriendlyName>
					<HexValue>0x0000014B</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>332 FPS</UserfriendlyName>
					<HexValue>0x0000014C</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>333 FPS</UserfriendlyName>
					<HexValue>0x0000014D</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>334 FPS</UserfriendlyName>
					<HexValue>0x0000014E</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>335 FPS</UserfriendlyName>
					<HexValue>0x0000014F</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>336 FPS</UserfriendlyName>
					<HexValue>0x00000150</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>337 FPS</UserfriendlyName>
					<HexValue>0x00000151</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>338 FPS</UserfriendlyName>
					<HexValue>0x00000152</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>339 FPS</UserfriendlyName>
					<HexValue>0x00000153</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>340 FPS</UserfriendlyName>
					<HexValue>0x00000154</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>341 FPS</UserfriendlyName>
					<HexValue>0x00000155</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>342 FPS</UserfriendlyName>
					<HexValue>0x00000156</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>343 FPS</UserfriendlyName>
					<HexValue>0x00000157</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>344 FPS</UserfriendlyName>
					<HexValue>0x00000158</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>345 FPS</UserfriendlyName>
					<HexValue>0x00000159</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>346 FPS</UserfriendlyName>
					<HexValue>0x0000015A</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>347 FPS</UserfriendlyName>
					<HexValue>0x0000015B</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>348 FPS</UserfriendlyName>
					<HexValue>0x0000015C</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>349 FPS</UserfriendlyName>
					<HexValue>0x0000015D</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>350 FPS</UserfriendlyName>
					<HexValue>0x0000015E</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>351 FPS</UserfriendlyName>
					<HexValue>0x0000015F</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>352 FPS</UserfriendlyName>
					<HexValue>0x00000160</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>353 FPS</UserfriendlyName>
					<HexValue>0x00000161</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>354 FPS</UserfriendlyName>
					<HexValue>0x00000162</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>355 FPS</UserfriendlyName>
					<HexValue>0x00000163</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>356 FPS</UserfriendlyName>
					<HexValue>0x00000164</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>357 FPS</UserfriendlyName>
					<HexValue>0x00000165</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>358 FPS</UserfriendlyName>
					<HexValue>0x00000166</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>359 FPS</UserfriendlyName>
					<HexValue>0x00000167</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>360 FPS</UserfriendlyName>
					<HexValue>0x00000168</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>361 FPS</UserfriendlyName>
					<HexValue>0x00000169</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>362 FPS</UserfriendlyName>
					<HexValue>0x0000016A</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>363 FPS</UserfriendlyName>
					<HexValue>0x0000016B</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>364 FPS</UserfriendlyName>
					<HexValue>0x0000016C</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>365 FPS</UserfriendlyName>
					<HexValue>0x0000016D</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>366 FPS</UserfriendlyName>
					<HexValue>0x0000016E</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>367 FPS</UserfriendlyName>
					<HexValue>0x0000016F</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>368 FPS</UserfriendlyName>
					<HexValue>0x00000170</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>369 FPS</UserfriendlyName>
					<HexValue>0x00000171</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>370 FPS</UserfriendlyName>
					<HexValue>0x00000172</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>371 FPS</UserfriendlyName>
					<HexValue>0x00000173</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>372 FPS</UserfriendlyName>
					<HexValue>0x00000174</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>373 FPS</UserfriendlyName>
					<HexValue>0x00000175</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>374 FPS</UserfriendlyName>
					<HexValue>0x00000176</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>375 FPS</UserfriendlyName>
					<HexValue>0x00000177</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>376 FPS</UserfriendlyName>
					<HexValue>0x00000178</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>377 FPS</UserfriendlyName>
					<HexValue>0x00000179</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>378 FPS</UserfriendlyName>
					<HexValue>0x0000017A</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>379 FPS</UserfriendlyName>
					<HexValue>0x0000017B</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>380 FPS</UserfriendlyName>
					<HexValue>0x0000017C</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>381 FPS</UserfriendlyName>
					<HexValue>0x0000017D</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>382 FPS</UserfriendlyName>
					<HexValue>0x0000017E</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>383 FPS</UserfriendlyName>
					<HexValue>0x0000017F</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>384 FPS</UserfriendlyName>
					<HexValue>0x00000180</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>385 FPS</UserfriendlyName>
					<HexValue>0x00000181</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>386 FPS</UserfriendlyName>
					<HexValue>0x00000182</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>387 FPS</UserfriendlyName>
					<HexValue>0x00000183</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>388 FPS</UserfriendlyName>
					<HexValue>0x00000184</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>389 FPS</UserfriendlyName>
					<HexValue>0x00000185</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>390 FPS</UserfriendlyName>
					<HexValue>0x00000186</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>391 FPS</UserfriendlyName>
					<HexValue>0x00000187</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>392 FPS</UserfriendlyName>
					<HexValue>0x00000188</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>393 FPS</UserfriendlyName>
					<HexValue>0x00000189</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>394 FPS</UserfriendlyName>
					<HexValue>0x0000018A</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>395 FPS</UserfriendlyName>
					<HexValue>0x0000018B</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>396 FPS</UserfriendlyName>
					<HexValue>0x0000018C</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>397 FPS</UserfriendlyName>
					<HexValue>0x0000018D</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>398 FPS</UserfriendlyName>
					<HexValue>0x0000018E</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>399 FPS</UserfriendlyName>
					<HexValue>0x0000018F</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>400 FPS</UserfriendlyName>
					<HexValue>0x00000190</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>401 FPS</UserfriendlyName>
					<HexValue>0x00000191</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>402 FPS</UserfriendlyName>
					<HexValue>0x00000192</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>403 FPS</UserfriendlyName>
					<HexValue>0x00000193</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>404 FPS</UserfriendlyName>
					<HexValue>0x00000194</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>405 FPS</UserfriendlyName>
					<HexValue>0x00000195</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>406 FPS</UserfriendlyName>
					<HexValue>0x00000196</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>407 FPS</UserfriendlyName>
					<HexValue>0x00000197</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>408 FPS</UserfriendlyName>
					<HexValue>0x00000198</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>409 FPS</UserfriendlyName>
					<HexValue>0x00000199</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>410 FPS</UserfriendlyName>
					<HexValue>0x0000019A</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>411 FPS</UserfriendlyName>
					<HexValue>0x0000019B</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>412 FPS</UserfriendlyName>
					<HexValue>0x0000019C</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>413 FPS</UserfriendlyName>
					<HexValue>0x0000019D</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>414 FPS</UserfriendlyName>
					<HexValue>0x0000019E</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>415 FPS</UserfriendlyName>
					<HexValue>0x0000019F</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>416 FPS</UserfriendlyName>
					<HexValue>0x000001A0</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>417 FPS</UserfriendlyName>
					<HexValue>0x000001A1</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>418 FPS</UserfriendlyName>
					<HexValue>0x000001A2</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>419 FPS</UserfriendlyName>
					<HexValue>0x000001A3</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>420 FPS</UserfriendlyName>
					<HexValue>0x000001A4</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>421 FPS</UserfriendlyName>
					<HexValue>0x000001A5</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>422 FPS</UserfriendlyName>
					<HexValue>0x000001A6</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>423 FPS</UserfriendlyName>
					<HexValue>0x000001A7</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>424 FPS</UserfriendlyName>
					<HexValue>0x000001A8</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>425 FPS</UserfriendlyName>
					<HexValue>0x000001A9</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>426 FPS</UserfriendlyName>
					<HexValue>0x000001AA</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>427 FPS</UserfriendlyName>
					<HexValue>0x000001AB</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>428 FPS</UserfriendlyName>
					<HexValue>0x000001AC</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>429 FPS</UserfriendlyName>
					<HexValue>0x000001AD</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>430 FPS</UserfriendlyName>
					<HexValue>0x000001AE</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>431 FPS</UserfriendlyName>
					<HexValue>0x000001AF</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>432 FPS</UserfriendlyName>
					<HexValue>0x000001B0</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>433 FPS</UserfriendlyName>
					<HexValue>0x000001B1</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>434 FPS</UserfriendlyName>
					<HexValue>0x000001B2</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>435 FPS</UserfriendlyName>
					<HexValue>0x000001B3</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>436 FPS</UserfriendlyName>
					<HexValue>0x000001B4</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>437 FPS</UserfriendlyName>
					<HexValue>0x000001B5</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>438 FPS</UserfriendlyName>
					<HexValue>0x000001B6</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>439 FPS</UserfriendlyName>
					<HexValue>0x000001B7</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>440 FPS</UserfriendlyName>
					<HexValue>0x000001B8</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>441 FPS</UserfriendlyName>
					<HexValue>0x000001B9</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>442 FPS</UserfriendlyName>
					<HexValue>0x000001BA</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>443 FPS</UserfriendlyName>
					<HexValue>0x000001BB</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>444 FPS</UserfriendlyName>
					<HexValue>0x000001BC</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>445 FPS</UserfriendlyName>
					<HexValue>0x000001BD</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>446 FPS</UserfriendlyName>
					<HexValue>0x000001BE</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>447 FPS</UserfriendlyName>
					<HexValue>0x000001BF</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>448 FPS</UserfriendlyName>
					<HexValue>0x000001C0</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>449 FPS</UserfriendlyName>
					<HexValue>0x000001C1</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>450 FPS</UserfriendlyName>
					<HexValue>0x000001C2</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>451 FPS</UserfriendlyName>
					<HexValue>0x000001C3</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>452 FPS</UserfriendlyName>
					<HexValue>0x000001C4</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>453 FPS</UserfriendlyName>
					<HexValue>0x000001C5</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>454 FPS</UserfriendlyName>
					<HexValue>0x000001C6</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>455 FPS</UserfriendlyName>
					<HexValue>0x000001C7</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>456 FPS</UserfriendlyName>
					<HexValue>0x000001C8</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>457 FPS</UserfriendlyName>
					<HexValue>0x000001C9</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>458 FPS</UserfriendlyName>
					<HexValue>0x000001CA</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>459 FPS</UserfriendlyName>
					<HexValue>0x000001CB</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>460 FPS</UserfriendlyName>
					<HexValue>0x000001CC</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>461 FPS</UserfriendlyName>
					<HexValue>0x000001CD</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>462 FPS</UserfriendlyName>
					<HexValue>0x000001CE</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>463 FPS</UserfriendlyName>
					<HexValue>0x000001CF</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>464 FPS</UserfriendlyName>
					<HexValue>0x000001D0</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>465 FPS</UserfriendlyName>
					<HexValue>0x000001D1</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>466 FPS</UserfriendlyName>
					<HexValue>0x000001D2</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>467 FPS</UserfriendlyName>
					<HexValue>0x000001D3</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>468 FPS</UserfriendlyName>
					<HexValue>0x000001D4</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>469 FPS</UserfriendlyName>
					<HexValue>0x000001D5</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>470 FPS</UserfriendlyName>
					<HexValue>0x000001D6</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>471 FPS</UserfriendlyName>
					<HexValue>0x000001D7</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>472 FPS</UserfriendlyName>
					<HexValue>0x000001D8</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>473 FPS</UserfriendlyName>
					<HexValue>0x000001D9</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>474 FPS</UserfriendlyName>
					<HexValue>0x000001DA</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>475 FPS</UserfriendlyName>
					<HexValue>0x000001DB</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>476 FPS</UserfriendlyName>
					<HexValue>0x000001DC</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>477 FPS</UserfriendlyName>
					<HexValue>0x000001DD</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>478 FPS</UserfriendlyName>
					<HexValue>0x000001DE</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>479 FPS</UserfriendlyName>
					<HexValue>0x000001DF</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>480 FPS</UserfriendlyName>
					<HexValue>0x000001E0</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>481 FPS</UserfriendlyName>
					<HexValue>0x000001E1</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>482 FPS</UserfriendlyName>
					<HexValue>0x000001E2</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>483 FPS</UserfriendlyName>
					<HexValue>0x000001E3</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>484 FPS</UserfriendlyName>
					<HexValue>0x000001E4</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>485 FPS</UserfriendlyName>
					<HexValue>0x000001E5</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>486 FPS</UserfriendlyName>
					<HexValue>0x000001E6</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>487 FPS</UserfriendlyName>
					<HexValue>0x000001E7</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>488 FPS</UserfriendlyName>
					<HexValue>0x000001E8</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>489 FPS</UserfriendlyName>
					<HexValue>0x000001E9</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>490 FPS</UserfriendlyName>
					<HexValue>0x000001EA</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>491 FPS</UserfriendlyName>
					<HexValue>0x000001EB</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>492 FPS</UserfriendlyName>
					<HexValue>0x000001EC</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>493 FPS</UserfriendlyName>
					<HexValue>0x000001ED</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>494 FPS</UserfriendlyName>
					<HexValue>0x000001EE</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>495 FPS</UserfriendlyName>
					<HexValue>0x000001EF</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>496 FPS</UserfriendlyName>
					<HexValue>0x000001F0</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>497 FPS</UserfriendlyName>
					<HexValue>0x000001F1</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>498 FPS</UserfriendlyName>
					<HexValue>0x000001F2</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>499 FPS</UserfriendlyName>
					<HexValue>0x000001F3</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>500 FPS</UserfriendlyName>
					<HexValue>0x000001F4</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>501 FPS</UserfriendlyName>
					<HexValue>0x000001F5</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>502 FPS</UserfriendlyName>
					<HexValue>0x000001F6</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>503 FPS</UserfriendlyName>
					<HexValue>0x000001F7</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>504 FPS</UserfriendlyName>
					<HexValue>0x000001F8</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>505 FPS</UserfriendlyName>
					<HexValue>0x000001F9</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>506 FPS</UserfriendlyName>
					<HexValue>0x000001FA</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>507 FPS</UserfriendlyName>
					<HexValue>0x000001FB</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>508 FPS</UserfriendlyName>
					<HexValue>0x000001FC</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>509 FPS</UserfriendlyName>
					<HexValue>0x000001FD</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>510 FPS</UserfriendlyName>
					<HexValue>0x000001FE</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>511 FPS</UserfriendlyName>
					<HexValue>0x000001FF</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>512 FPS</UserfriendlyName>
					<HexValue>0x00000200</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>513 FPS</UserfriendlyName>
					<HexValue>0x00000201</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>514 FPS</UserfriendlyName>
					<HexValue>0x00000202</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>515 FPS</UserfriendlyName>
					<HexValue>0x00000203</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>516 FPS</UserfriendlyName>
					<HexValue>0x00000204</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>517 FPS</UserfriendlyName>
					<HexValue>0x00000205</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>518 FPS</UserfriendlyName>
					<HexValue>0x00000206</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>519 FPS</UserfriendlyName>
					<HexValue>0x00000207</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>520 FPS</UserfriendlyName>
					<HexValue>0x00000208</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>521 FPS</UserfriendlyName>
					<HexValue>0x00000209</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>522 FPS</UserfriendlyName>
					<HexValue>0x0000020A</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>523 FPS</UserfriendlyName>
					<HexValue>0x0000020B</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>524 FPS</UserfriendlyName>
					<HexValue>0x0000020C</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>525 FPS</UserfriendlyName>
					<HexValue>0x0000020D</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>526 FPS</UserfriendlyName>
					<HexValue>0x0000020E</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>527 FPS</UserfriendlyName>
					<HexValue>0x0000020F</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>528 FPS</UserfriendlyName>
					<HexValue>0x00000210</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>529 FPS</UserfriendlyName>
					<HexValue>0x00000211</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>530 FPS</UserfriendlyName>
					<HexValue>0x00000212</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>531 FPS</UserfriendlyName>
					<HexValue>0x00000213</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>532 FPS</UserfriendlyName>
					<HexValue>0x00000214</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>533 FPS</UserfriendlyName>
					<HexValue>0x00000215</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>534 FPS</UserfriendlyName>
					<HexValue>0x00000216</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>535 FPS</UserfriendlyName>
					<HexValue>0x00000217</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>536 FPS</UserfriendlyName>
					<HexValue>0x00000218</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>537 FPS</UserfriendlyName>
					<HexValue>0x00000219</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>538 FPS</UserfriendlyName>
					<HexValue>0x0000021A</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>539 FPS</UserfriendlyName>
					<HexValue>0x0000021B</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>540 FPS</UserfriendlyName>
					<HexValue>0x0000021C</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>541 FPS</UserfriendlyName>
					<HexValue>0x0000021D</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>542 FPS</UserfriendlyName>
					<HexValue>0x0000021E</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>543 FPS</UserfriendlyName>
					<HexValue>0x0000021F</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>544 FPS</UserfriendlyName>
					<HexValue>0x00000220</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>545 FPS</UserfriendlyName>
					<HexValue>0x00000221</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>546 FPS</UserfriendlyName>
					<HexValue>0x00000222</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>547 FPS</UserfriendlyName>
					<HexValue>0x00000223</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>548 FPS</UserfriendlyName>
					<HexValue>0x00000224</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>549 FPS</UserfriendlyName>
					<HexValue>0x00000225</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>550 FPS</UserfriendlyName>
					<HexValue>0x00000226</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>551 FPS</UserfriendlyName>
					<HexValue>0x00000227</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>552 FPS</UserfriendlyName>
					<HexValue>0x00000228</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>553 FPS</UserfriendlyName>
					<HexValue>0x00000229</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>554 FPS</UserfriendlyName>
					<HexValue>0x0000022A</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>555 FPS</UserfriendlyName>
					<HexValue>0x0000022B</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>556 FPS</UserfriendlyName>
					<HexValue>0x0000022C</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>557 FPS</UserfriendlyName>
					<HexValue>0x0000022D</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>558 FPS</UserfriendlyName>
					<HexValue>0x0000022E</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>559 FPS</UserfriendlyName>
					<HexValue>0x0000022F</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>560 FPS</UserfriendlyName>
					<HexValue>0x00000230</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>561 FPS</UserfriendlyName>
					<HexValue>0x00000231</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>562 FPS</UserfriendlyName>
					<HexValue>0x00000232</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>563 FPS</UserfriendlyName>
					<HexValue>0x00000233</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>564 FPS</UserfriendlyName>
					<HexValue>0x00000234</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>565 FPS</UserfriendlyName>
					<HexValue>0x00000235</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>566 FPS</UserfriendlyName>
					<HexValue>0x00000236</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>567 FPS</UserfriendlyName>
					<HexValue>0x00000237</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>568 FPS</UserfriendlyName>
					<HexValue>0x00000238</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>569 FPS</UserfriendlyName>
					<HexValue>0x00000239</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>570 FPS</UserfriendlyName>
					<HexValue>0x0000023A</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>571 FPS</UserfriendlyName>
					<HexValue>0x0000023B</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>572 FPS</UserfriendlyName>
					<HexValue>0x0000023C</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>573 FPS</UserfriendlyName>
					<HexValue>0x0000023D</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>574 FPS</UserfriendlyName>
					<HexValue>0x0000023E</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>575 FPS</UserfriendlyName>
					<HexValue>0x0000023F</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>576 FPS</UserfriendlyName>
					<HexValue>0x00000240</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>577 FPS</UserfriendlyName>
					<HexValue>0x00000241</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>578 FPS</UserfriendlyName>
					<HexValue>0x00000242</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>579 FPS</UserfriendlyName>
					<HexValue>0x00000243</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>580 FPS</UserfriendlyName>
					<HexValue>0x00000244</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>581 FPS</UserfriendlyName>
					<HexValue>0x00000245</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>582 FPS</UserfriendlyName>
					<HexValue>0x00000246</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>583 FPS</UserfriendlyName>
					<HexValue>0x00000247</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>584 FPS</UserfriendlyName>
					<HexValue>0x00000248</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>585 FPS</UserfriendlyName>
					<HexValue>0x00000249</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>586 FPS</UserfriendlyName>
					<HexValue>0x0000024A</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>587 FPS</UserfriendlyName>
					<HexValue>0x0000024B</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>588 FPS</UserfriendlyName>
					<HexValue>0x0000024C</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>589 FPS</UserfriendlyName>
					<HexValue>0x0000024D</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>590 FPS</UserfriendlyName>
					<HexValue>0x0000024E</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>591 FPS</UserfriendlyName>
					<HexValue>0x0000024F</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>592 FPS</UserfriendlyName>
					<HexValue>0x00000250</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>593 FPS</UserfriendlyName>
					<HexValue>0x00000251</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>594 FPS</UserfriendlyName>
					<HexValue>0x00000252</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>595 FPS</UserfriendlyName>
					<HexValue>0x00000253</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>596 FPS</UserfriendlyName>
					<HexValue>0x00000254</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>597 FPS</UserfriendlyName>
					<HexValue>0x00000255</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>598 FPS</UserfriendlyName>
					<HexValue>0x00000256</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>599 FPS</UserfriendlyName>
					<HexValue>0x00000257</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>600 FPS</UserfriendlyName>
					<HexValue>0x00000258</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>601 FPS</UserfriendlyName>
					<HexValue>0x00000259</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>602 FPS</UserfriendlyName>
					<HexValue>0x0000025A</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>603 FPS</UserfriendlyName>
					<HexValue>0x0000025B</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>604 FPS</UserfriendlyName>
					<HexValue>0x0000025C</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>605 FPS</UserfriendlyName>
					<HexValue>0x0000025D</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>606 FPS</UserfriendlyName>
					<HexValue>0x0000025E</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>607 FPS</UserfriendlyName>
					<HexValue>0x0000025F</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>608 FPS</UserfriendlyName>
					<HexValue>0x00000260</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>609 FPS</UserfriendlyName>
					<HexValue>0x00000261</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>610 FPS</UserfriendlyName>
					<HexValue>0x00000262</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>611 FPS</UserfriendlyName>
					<HexValue>0x00000263</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>612 FPS</UserfriendlyName>
					<HexValue>0x00000264</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>613 FPS</UserfriendlyName>
					<HexValue>0x00000265</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>614 FPS</UserfriendlyName>
					<HexValue>0x00000266</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>615 FPS</UserfriendlyName>
					<HexValue>0x00000267</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>616 FPS</UserfriendlyName>
					<HexValue>0x00000268</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>617 FPS</UserfriendlyName>
					<HexValue>0x00000269</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>618 FPS</UserfriendlyName>
					<HexValue>0x0000026A</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>619 FPS</UserfriendlyName>
					<HexValue>0x0000026B</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>620 FPS</UserfriendlyName>
					<HexValue>0x0000026C</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>621 FPS</UserfriendlyName>
					<HexValue>0x0000026D</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>622 FPS</UserfriendlyName>
					<HexValue>0x0000026E</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>623 FPS</UserfriendlyName>
					<HexValue>0x0000026F</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>624 FPS</UserfriendlyName>
					<HexValue>0x00000270</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>625 FPS</UserfriendlyName>
					<HexValue>0x00000271</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>626 FPS</UserfriendlyName>
					<HexValue>0x00000272</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>627 FPS</UserfriendlyName>
					<HexValue>0x00000273</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>628 FPS</UserfriendlyName>
					<HexValue>0x00000274</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>629 FPS</UserfriendlyName>
					<HexValue>0x00000275</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>630 FPS</UserfriendlyName>
					<HexValue>0x00000276</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>631 FPS</UserfriendlyName>
					<HexValue>0x00000277</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>632 FPS</UserfriendlyName>
					<HexValue>0x00000278</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>633 FPS</UserfriendlyName>
					<HexValue>0x00000279</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>634 FPS</UserfriendlyName>
					<HexValue>0x0000027A</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>635 FPS</UserfriendlyName>
					<HexValue>0x0000027B</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>636 FPS</UserfriendlyName>
					<HexValue>0x0000027C</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>637 FPS</UserfriendlyName>
					<HexValue>0x0000027D</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>638 FPS</UserfriendlyName>
					<HexValue>0x0000027E</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>639 FPS</UserfriendlyName>
					<HexValue>0x0000027F</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>640 FPS</UserfriendlyName>
					<HexValue>0x00000280</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>641 FPS</UserfriendlyName>
					<HexValue>0x00000281</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>642 FPS</UserfriendlyName>
					<HexValue>0x00000282</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>643 FPS</UserfriendlyName>
					<HexValue>0x00000283</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>644 FPS</UserfriendlyName>
					<HexValue>0x00000284</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>645 FPS</UserfriendlyName>
					<HexValue>0x00000285</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>646 FPS</UserfriendlyName>
					<HexValue>0x00000286</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>647 FPS</UserfriendlyName>
					<HexValue>0x00000287</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>648 FPS</UserfriendlyName>
					<HexValue>0x00000288</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>649 FPS</UserfriendlyName>
					<HexValue>0x00000289</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>650 FPS</UserfriendlyName>
					<HexValue>0x0000028A</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>651 FPS</UserfriendlyName>
					<HexValue>0x0000028B</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>652 FPS</UserfriendlyName>
					<HexValue>0x0000028C</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>653 FPS</UserfriendlyName>
					<HexValue>0x0000028D</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>654 FPS</UserfriendlyName>
					<HexValue>0x0000028E</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>655 FPS</UserfriendlyName>
					<HexValue>0x0000028F</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>656 FPS</UserfriendlyName>
					<HexValue>0x00000290</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>657 FPS</UserfriendlyName>
					<HexValue>0x00000291</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>658 FPS</UserfriendlyName>
					<HexValue>0x00000292</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>659 FPS</UserfriendlyName>
					<HexValue>0x00000293</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>660 FPS</UserfriendlyName>
					<HexValue>0x00000294</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>661 FPS</UserfriendlyName>
					<HexValue>0x00000295</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>662 FPS</UserfriendlyName>
					<HexValue>0x00000296</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>663 FPS</UserfriendlyName>
					<HexValue>0x00000297</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>664 FPS</UserfriendlyName>
					<HexValue>0x00000298</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>665 FPS</UserfriendlyName>
					<HexValue>0x00000299</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>666 FPS</UserfriendlyName>
					<HexValue>0x0000029A</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>667 FPS</UserfriendlyName>
					<HexValue>0x0000029B</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>668 FPS</UserfriendlyName>
					<HexValue>0x0000029C</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>669 FPS</UserfriendlyName>
					<HexValue>0x0000029D</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>670 FPS</UserfriendlyName>
					<HexValue>0x0000029E</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>671 FPS</UserfriendlyName>
					<HexValue>0x0000029F</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>672 FPS</UserfriendlyName>
					<HexValue>0x000002A0</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>673 FPS</UserfriendlyName>
					<HexValue>0x000002A1</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>674 FPS</UserfriendlyName>
					<HexValue>0x000002A2</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>675 FPS</UserfriendlyName>
					<HexValue>0x000002A3</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>676 FPS</UserfriendlyName>
					<HexValue>0x000002A4</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>677 FPS</UserfriendlyName>
					<HexValue>0x000002A5</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>678 FPS</UserfriendlyName>
					<HexValue>0x000002A6</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>679 FPS</UserfriendlyName>
					<HexValue>0x000002A7</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>680 FPS</UserfriendlyName>
					<HexValue>0x000002A8</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>681 FPS</UserfriendlyName>
					<HexValue>0x000002A9</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>682 FPS</UserfriendlyName>
					<HexValue>0x000002AA</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>683 FPS</UserfriendlyName>
					<HexValue>0x000002AB</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>684 FPS</UserfriendlyName>
					<HexValue>0x000002AC</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>685 FPS</UserfriendlyName>
					<HexValue>0x000002AD</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>686 FPS</UserfriendlyName>
					<HexValue>0x000002AE</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>687 FPS</UserfriendlyName>
					<HexValue>0x000002AF</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>688 FPS</UserfriendlyName>
					<HexValue>0x000002B0</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>689 FPS</UserfriendlyName>
					<HexValue>0x000002B1</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>690 FPS</UserfriendlyName>
					<HexValue>0x000002B2</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>691 FPS</UserfriendlyName>
					<HexValue>0x000002B3</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>692 FPS</UserfriendlyName>
					<HexValue>0x000002B4</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>693 FPS</UserfriendlyName>
					<HexValue>0x000002B5</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>694 FPS</UserfriendlyName>
					<HexValue>0x000002B6</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>695 FPS</UserfriendlyName>
					<HexValue>0x000002B7</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>696 FPS</UserfriendlyName>
					<HexValue>0x000002B8</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>697 FPS</UserfriendlyName>
					<HexValue>0x000002B9</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>698 FPS</UserfriendlyName>
					<HexValue>0x000002BA</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>699 FPS</UserfriendlyName>
					<HexValue>0x000002BB</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>700 FPS</UserfriendlyName>
					<HexValue>0x000002BC</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>701 FPS</UserfriendlyName>
					<HexValue>0x000002BD</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>702 FPS</UserfriendlyName>
					<HexValue>0x000002BE</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>703 FPS</UserfriendlyName>
					<HexValue>0x000002BF</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>704 FPS</UserfriendlyName>
					<HexValue>0x000002C0</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>705 FPS</UserfriendlyName>
					<HexValue>0x000002C1</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>706 FPS</UserfriendlyName>
					<HexValue>0x000002C2</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>707 FPS</UserfriendlyName>
					<HexValue>0x000002C3</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>708 FPS</UserfriendlyName>
					<HexValue>0x000002C4</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>709 FPS</UserfriendlyName>
					<HexValue>0x000002C5</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>710 FPS</UserfriendlyName>
					<HexValue>0x000002C6</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>711 FPS</UserfriendlyName>
					<HexValue>0x000002C7</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>712 FPS</UserfriendlyName>
					<HexValue>0x000002C8</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>713 FPS</UserfriendlyName>
					<HexValue>0x000002C9</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>714 FPS</UserfriendlyName>
					<HexValue>0x000002CA</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>715 FPS</UserfriendlyName>
					<HexValue>0x000002CB</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>716 FPS</UserfriendlyName>
					<HexValue>0x000002CC</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>717 FPS</UserfriendlyName>
					<HexValue>0x000002CD</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>718 FPS</UserfriendlyName>
					<HexValue>0x000002CE</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>719 FPS</UserfriendlyName>
					<HexValue>0x000002CF</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>720 FPS</UserfriendlyName>
					<HexValue>0x000002D0</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>721 FPS</UserfriendlyName>
					<HexValue>0x000002D1</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>722 FPS</UserfriendlyName>
					<HexValue>0x000002D2</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>723 FPS</UserfriendlyName>
					<HexValue>0x000002D3</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>724 FPS</UserfriendlyName>
					<HexValue>0x000002D4</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>725 FPS</UserfriendlyName>
					<HexValue>0x000002D5</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>726 FPS</UserfriendlyName>
					<HexValue>0x000002D6</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>727 FPS</UserfriendlyName>
					<HexValue>0x000002D7</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>728 FPS</UserfriendlyName>
					<HexValue>0x000002D8</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>729 FPS</UserfriendlyName>
					<HexValue>0x000002D9</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>730 FPS</UserfriendlyName>
					<HexValue>0x000002DA</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>731 FPS</UserfriendlyName>
					<HexValue>0x000002DB</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>732 FPS</UserfriendlyName>
					<HexValue>0x000002DC</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>733 FPS</UserfriendlyName>
					<HexValue>0x000002DD</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>734 FPS</UserfriendlyName>
					<HexValue>0x000002DE</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>735 FPS</UserfriendlyName>
					<HexValue>0x000002DF</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>736 FPS</UserfriendlyName>
					<HexValue>0x000002E0</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>737 FPS</UserfriendlyName>
					<HexValue>0x000002E1</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>738 FPS</UserfriendlyName>
					<HexValue>0x000002E2</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>739 FPS</UserfriendlyName>
					<HexValue>0x000002E3</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>740 FPS</UserfriendlyName>
					<HexValue>0x000002E4</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>741 FPS</UserfriendlyName>
					<HexValue>0x000002E5</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>742 FPS</UserfriendlyName>
					<HexValue>0x000002E6</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>743 FPS</UserfriendlyName>
					<HexValue>0x000002E7</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>744 FPS</UserfriendlyName>
					<HexValue>0x000002E8</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>745 FPS</UserfriendlyName>
					<HexValue>0x000002E9</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>746 FPS</UserfriendlyName>
					<HexValue>0x000002EA</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>747 FPS</UserfriendlyName>
					<HexValue>0x000002EB</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>748 FPS</UserfriendlyName>
					<HexValue>0x000002EC</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>749 FPS</UserfriendlyName>
					<HexValue>0x000002ED</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>750 FPS</UserfriendlyName>
					<HexValue>0x000002EE</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>751 FPS</UserfriendlyName>
					<HexValue>0x000002EF</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>752 FPS</UserfriendlyName>
					<HexValue>0x000002F0</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>753 FPS</UserfriendlyName>
					<HexValue>0x000002F1</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>754 FPS</UserfriendlyName>
					<HexValue>0x000002F2</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>755 FPS</UserfriendlyName>
					<HexValue>0x000002F3</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>756 FPS</UserfriendlyName>
					<HexValue>0x000002F4</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>757 FPS</UserfriendlyName>
					<HexValue>0x000002F5</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>758 FPS</UserfriendlyName>
					<HexValue>0x000002F6</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>759 FPS</UserfriendlyName>
					<HexValue>0x000002F7</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>760 FPS</UserfriendlyName>
					<HexValue>0x000002F8</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>761 FPS</UserfriendlyName>
					<HexValue>0x000002F9</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>762 FPS</UserfriendlyName>
					<HexValue>0x000002FA</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>763 FPS</UserfriendlyName>
					<HexValue>0x000002FB</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>764 FPS</UserfriendlyName>
					<HexValue>0x000002FC</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>765 FPS</UserfriendlyName>
					<HexValue>0x000002FD</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>766 FPS</UserfriendlyName>
					<HexValue>0x000002FE</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>767 FPS</UserfriendlyName>
					<HexValue>0x000002FF</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>768 FPS</UserfriendlyName>
					<HexValue>0x00000300</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>769 FPS</UserfriendlyName>
					<HexValue>0x00000301</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>770 FPS</UserfriendlyName>
					<HexValue>0x00000302</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>771 FPS</UserfriendlyName>
					<HexValue>0x00000303</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>772 FPS</UserfriendlyName>
					<HexValue>0x00000304</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>773 FPS</UserfriendlyName>
					<HexValue>0x00000305</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>774 FPS</UserfriendlyName>
					<HexValue>0x00000306</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>775 FPS</UserfriendlyName>
					<HexValue>0x00000307</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>776 FPS</UserfriendlyName>
					<HexValue>0x00000308</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>777 FPS</UserfriendlyName>
					<HexValue>0x00000309</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>778 FPS</UserfriendlyName>
					<HexValue>0x0000030A</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>779 FPS</UserfriendlyName>
					<HexValue>0x0000030B</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>780 FPS</UserfriendlyName>
					<HexValue>0x0000030C</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>781 FPS</UserfriendlyName>
					<HexValue>0x0000030D</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>782 FPS</UserfriendlyName>
					<HexValue>0x0000030E</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>783 FPS</UserfriendlyName>
					<HexValue>0x0000030F</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>784 FPS</UserfriendlyName>
					<HexValue>0x00000310</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>785 FPS</UserfriendlyName>
					<HexValue>0x00000311</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>786 FPS</UserfriendlyName>
					<HexValue>0x00000312</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>787 FPS</UserfriendlyName>
					<HexValue>0x00000313</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>788 FPS</UserfriendlyName>
					<HexValue>0x00000314</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>789 FPS</UserfriendlyName>
					<HexValue>0x00000315</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>790 FPS</UserfriendlyName>
					<HexValue>0x00000316</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>791 FPS</UserfriendlyName>
					<HexValue>0x00000317</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>792 FPS</UserfriendlyName>
					<HexValue>0x00000318</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>793 FPS</UserfriendlyName>
					<HexValue>0x00000319</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>794 FPS</UserfriendlyName>
					<HexValue>0x0000031A</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>795 FPS</UserfriendlyName>
					<HexValue>0x0000031B</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>796 FPS</UserfriendlyName>
					<HexValue>0x0000031C</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>797 FPS</UserfriendlyName>
					<HexValue>0x0000031D</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>798 FPS</UserfriendlyName>
					<HexValue>0x0000031E</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>799 FPS</UserfriendlyName>
					<HexValue>0x0000031F</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>800 FPS</UserfriendlyName>
					<HexValue>0x00000320</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>801 FPS</UserfriendlyName>
					<HexValue>0x00000321</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>802 FPS</UserfriendlyName>
					<HexValue>0x00000322</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>803 FPS</UserfriendlyName>
					<HexValue>0x00000323</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>804 FPS</UserfriendlyName>
					<HexValue>0x00000324</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>805 FPS</UserfriendlyName>
					<HexValue>0x00000325</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>806 FPS</UserfriendlyName>
					<HexValue>0x00000326</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>807 FPS</UserfriendlyName>
					<HexValue>0x00000327</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>808 FPS</UserfriendlyName>
					<HexValue>0x00000328</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>809 FPS</UserfriendlyName>
					<HexValue>0x00000329</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>810 FPS</UserfriendlyName>
					<HexValue>0x0000032A</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>811 FPS</UserfriendlyName>
					<HexValue>0x0000032B</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>812 FPS</UserfriendlyName>
					<HexValue>0x0000032C</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>813 FPS</UserfriendlyName>
					<HexValue>0x0000032D</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>814 FPS</UserfriendlyName>
					<HexValue>0x0000032E</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>815 FPS</UserfriendlyName>
					<HexValue>0x0000032F</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>816 FPS</UserfriendlyName>
					<HexValue>0x00000330</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>817 FPS</UserfriendlyName>
					<HexValue>0x00000331</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>818 FPS</UserfriendlyName>
					<HexValue>0x00000332</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>819 FPS</UserfriendlyName>
					<HexValue>0x00000333</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>820 FPS</UserfriendlyName>
					<HexValue>0x00000334</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>821 FPS</UserfriendlyName>
					<HexValue>0x00000335</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>822 FPS</UserfriendlyName>
					<HexValue>0x00000336</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>823 FPS</UserfriendlyName>
					<HexValue>0x00000337</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>824 FPS</UserfriendlyName>
					<HexValue>0x00000338</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>825 FPS</UserfriendlyName>
					<HexValue>0x00000339</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>826 FPS</UserfriendlyName>
					<HexValue>0x0000033A</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>827 FPS</UserfriendlyName>
					<HexValue>0x0000033B</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>828 FPS</UserfriendlyName>
					<HexValue>0x0000033C</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>829 FPS</UserfriendlyName>
					<HexValue>0x0000033D</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>830 FPS</UserfriendlyName>
					<HexValue>0x0000033E</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>831 FPS</UserfriendlyName>
					<HexValue>0x0000033F</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>832 FPS</UserfriendlyName>
					<HexValue>0x00000340</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>833 FPS</UserfriendlyName>
					<HexValue>0x00000341</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>834 FPS</UserfriendlyName>
					<HexValue>0x00000342</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>835 FPS</UserfriendlyName>
					<HexValue>0x00000343</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>836 FPS</UserfriendlyName>
					<HexValue>0x00000344</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>837 FPS</UserfriendlyName>
					<HexValue>0x00000345</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>838 FPS</UserfriendlyName>
					<HexValue>0x00000346</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>839 FPS</UserfriendlyName>
					<HexValue>0x00000347</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>840 FPS</UserfriendlyName>
					<HexValue>0x00000348</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>841 FPS</UserfriendlyName>
					<HexValue>0x00000349</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>842 FPS</UserfriendlyName>
					<HexValue>0x0000034A</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>843 FPS</UserfriendlyName>
					<HexValue>0x0000034B</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>844 FPS</UserfriendlyName>
					<HexValue>0x0000034C</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>845 FPS</UserfriendlyName>
					<HexValue>0x0000034D</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>846 FPS</UserfriendlyName>
					<HexValue>0x0000034E</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>847 FPS</UserfriendlyName>
					<HexValue>0x0000034F</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>848 FPS</UserfriendlyName>
					<HexValue>0x00000350</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>849 FPS</UserfriendlyName>
					<HexValue>0x00000351</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>850 FPS</UserfriendlyName>
					<HexValue>0x00000352</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>851 FPS</UserfriendlyName>
					<HexValue>0x00000353</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>852 FPS</UserfriendlyName>
					<HexValue>0x00000354</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>853 FPS</UserfriendlyName>
					<HexValue>0x00000355</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>854 FPS</UserfriendlyName>
					<HexValue>0x00000356</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>855 FPS</UserfriendlyName>
					<HexValue>0x00000357</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>856 FPS</UserfriendlyName>
					<HexValue>0x00000358</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>857 FPS</UserfriendlyName>
					<HexValue>0x00000359</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>858 FPS</UserfriendlyName>
					<HexValue>0x0000035A</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>859 FPS</UserfriendlyName>
					<HexValue>0x0000035B</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>860 FPS</UserfriendlyName>
					<HexValue>0x0000035C</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>861 FPS</UserfriendlyName>
					<HexValue>0x0000035D</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>862 FPS</UserfriendlyName>
					<HexValue>0x0000035E</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>863 FPS</UserfriendlyName>
					<HexValue>0x0000035F</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>864 FPS</UserfriendlyName>
					<HexValue>0x00000360</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>865 FPS</UserfriendlyName>
					<HexValue>0x00000361</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>866 FPS</UserfriendlyName>
					<HexValue>0x00000362</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>867 FPS</UserfriendlyName>
					<HexValue>0x00000363</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>868 FPS</UserfriendlyName>
					<HexValue>0x00000364</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>869 FPS</UserfriendlyName>
					<HexValue>0x00000365</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>870 FPS</UserfriendlyName>
					<HexValue>0x00000366</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>871 FPS</UserfriendlyName>
					<HexValue>0x00000367</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>872 FPS</UserfriendlyName>
					<HexValue>0x00000368</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>873 FPS</UserfriendlyName>
					<HexValue>0x00000369</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>874 FPS</UserfriendlyName>
					<HexValue>0x0000036A</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>875 FPS</UserfriendlyName>
					<HexValue>0x0000036B</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>876 FPS</UserfriendlyName>
					<HexValue>0x0000036C</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>877 FPS</UserfriendlyName>
					<HexValue>0x0000036D</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>878 FPS</UserfriendlyName>
					<HexValue>0x0000036E</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>879 FPS</UserfriendlyName>
					<HexValue>0x0000036F</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>880 FPS</UserfriendlyName>
					<HexValue>0x00000370</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>881 FPS</UserfriendlyName>
					<HexValue>0x00000371</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>882 FPS</UserfriendlyName>
					<HexValue>0x00000372</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>883 FPS</UserfriendlyName>
					<HexValue>0x00000373</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>884 FPS</UserfriendlyName>
					<HexValue>0x00000374</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>885 FPS</UserfriendlyName>
					<HexValue>0x00000375</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>886 FPS</UserfriendlyName>
					<HexValue>0x00000376</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>887 FPS</UserfriendlyName>
					<HexValue>0x00000377</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>888 FPS</UserfriendlyName>
					<HexValue>0x00000378</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>889 FPS</UserfriendlyName>
					<HexValue>0x00000379</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>890 FPS</UserfriendlyName>
					<HexValue>0x0000037A</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>891 FPS</UserfriendlyName>
					<HexValue>0x0000037B</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>892 FPS</UserfriendlyName>
					<HexValue>0x0000037C</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>893 FPS</UserfriendlyName>
					<HexValue>0x0000037D</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>894 FPS</UserfriendlyName>
					<HexValue>0x0000037E</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>895 FPS</UserfriendlyName>
					<HexValue>0x0000037F</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>896 FPS</UserfriendlyName>
					<HexValue>0x00000380</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>897 FPS</UserfriendlyName>
					<HexValue>0x00000381</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>898 FPS</UserfriendlyName>
					<HexValue>0x00000382</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>899 FPS</UserfriendlyName>
					<HexValue>0x00000383</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>900 FPS</UserfriendlyName>
					<HexValue>0x00000384</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>901 FPS</UserfriendlyName>
					<HexValue>0x00000385</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>902 FPS</UserfriendlyName>
					<HexValue>0x00000386</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>903 FPS</UserfriendlyName>
					<HexValue>0x00000387</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>904 FPS</UserfriendlyName>
					<HexValue>0x00000388</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>905 FPS</UserfriendlyName>
					<HexValue>0x00000389</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>906 FPS</UserfriendlyName>
					<HexValue>0x0000038A</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>907 FPS</UserfriendlyName>
					<HexValue>0x0000038B</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>908 FPS</UserfriendlyName>
					<HexValue>0x0000038C</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>909 FPS</UserfriendlyName>
					<HexValue>0x0000038D</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>910 FPS</UserfriendlyName>
					<HexValue>0x0000038E</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>911 FPS</UserfriendlyName>
					<HexValue>0x0000038F</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>912 FPS</UserfriendlyName>
					<HexValue>0x00000390</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>913 FPS</UserfriendlyName>
					<HexValue>0x00000391</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>914 FPS</UserfriendlyName>
					<HexValue>0x00000392</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>915 FPS</UserfriendlyName>
					<HexValue>0x00000393</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>916 FPS</UserfriendlyName>
					<HexValue>0x00000394</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>917 FPS</UserfriendlyName>
					<HexValue>0x00000395</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>918 FPS</UserfriendlyName>
					<HexValue>0x00000396</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>919 FPS</UserfriendlyName>
					<HexValue>0x00000397</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>920 FPS</UserfriendlyName>
					<HexValue>0x00000398</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>921 FPS</UserfriendlyName>
					<HexValue>0x00000399</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>922 FPS</UserfriendlyName>
					<HexValue>0x0000039A</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>923 FPS</UserfriendlyName>
					<HexValue>0x0000039B</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>924 FPS</UserfriendlyName>
					<HexValue>0x0000039C</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>925 FPS</UserfriendlyName>
					<HexValue>0x0000039D</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>926 FPS</UserfriendlyName>
					<HexValue>0x0000039E</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>927 FPS</UserfriendlyName>
					<HexValue>0x0000039F</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>928 FPS</UserfriendlyName>
					<HexValue>0x000003A0</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>929 FPS</UserfriendlyName>
					<HexValue>0x000003A1</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>930 FPS</UserfriendlyName>
					<HexValue>0x000003A2</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>931 FPS</UserfriendlyName>
					<HexValue>0x000003A3</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>932 FPS</UserfriendlyName>
					<HexValue>0x000003A4</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>933 FPS</UserfriendlyName>
					<HexValue>0x000003A5</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>934 FPS</UserfriendlyName>
					<HexValue>0x000003A6</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>935 FPS</UserfriendlyName>
					<HexValue>0x000003A7</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>936 FPS</UserfriendlyName>
					<HexValue>0x000003A8</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>937 FPS</UserfriendlyName>
					<HexValue>0x000003A9</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>938 FPS</UserfriendlyName>
					<HexValue>0x000003AA</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>939 FPS</UserfriendlyName>
					<HexValue>0x000003AB</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>940 FPS</UserfriendlyName>
					<HexValue>0x000003AC</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>941 FPS</UserfriendlyName>
					<HexValue>0x000003AD</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>942 FPS</UserfriendlyName>
					<HexValue>0x000003AE</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>943 FPS</UserfriendlyName>
					<HexValue>0x000003AF</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>944 FPS</UserfriendlyName>
					<HexValue>0x000003B0</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>945 FPS</UserfriendlyName>
					<HexValue>0x000003B1</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>946 FPS</UserfriendlyName>
					<HexValue>0x000003B2</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>947 FPS</UserfriendlyName>
					<HexValue>0x000003B3</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>948 FPS</UserfriendlyName>
					<HexValue>0x000003B4</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>949 FPS</UserfriendlyName>
					<HexValue>0x000003B5</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>950 FPS</UserfriendlyName>
					<HexValue>0x000003B6</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>951 FPS</UserfriendlyName>
					<HexValue>0x000003B7</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>952 FPS</UserfriendlyName>
					<HexValue>0x000003B8</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>953 FPS</UserfriendlyName>
					<HexValue>0x000003B9</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>954 FPS</UserfriendlyName>
					<HexValue>0x000003BA</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>955 FPS</UserfriendlyName>
					<HexValue>0x000003BB</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>956 FPS</UserfriendlyName>
					<HexValue>0x000003BC</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>957 FPS</UserfriendlyName>
					<HexValue>0x000003BD</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>958 FPS</UserfriendlyName>
					<HexValue>0x000003BE</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>959 FPS</UserfriendlyName>
					<HexValue>0x000003BF</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>960 FPS</UserfriendlyName>
					<HexValue>0x000003C0</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>961 FPS</UserfriendlyName>
					<HexValue>0x000003C1</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>962 FPS</UserfriendlyName>
					<HexValue>0x000003C2</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>963 FPS</UserfriendlyName>
					<HexValue>0x000003C3</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>964 FPS</UserfriendlyName>
					<HexValue>0x000003C4</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>965 FPS</UserfriendlyName>
					<HexValue>0x000003C5</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>966 FPS</UserfriendlyName>
					<HexValue>0x000003C6</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>967 FPS</UserfriendlyName>
					<HexValue>0x000003C7</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>968 FPS</UserfriendlyName>
					<HexValue>0x000003C8</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>969 FPS</UserfriendlyName>
					<HexValue>0x000003C9</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>970 FPS</UserfriendlyName>
					<HexValue>0x000003CA</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>971 FPS</UserfriendlyName>
					<HexValue>0x000003CB</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>972 FPS</UserfriendlyName>
					<HexValue>0x000003CC</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>973 FPS</UserfriendlyName>
					<HexValue>0x000003CD</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>974 FPS</UserfriendlyName>
					<HexValue>0x000003CE</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>975 FPS</UserfriendlyName>
					<HexValue>0x000003CF</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>976 FPS</UserfriendlyName>
					<HexValue>0x000003D0</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>977 FPS</UserfriendlyName>
					<HexValue>0x000003D1</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>978 FPS</UserfriendlyName>
					<HexValue>0x000003D2</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>979 FPS</UserfriendlyName>
					<HexValue>0x000003D3</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>980 FPS</UserfriendlyName>
					<HexValue>0x000003D4</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>981 FPS</UserfriendlyName>
					<HexValue>0x000003D5</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>982 FPS</UserfriendlyName>
					<HexValue>0x000003D6</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>983 FPS</UserfriendlyName>
					<HexValue>0x000003D7</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>984 FPS</UserfriendlyName>
					<HexValue>0x000003D8</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>985 FPS</UserfriendlyName>
					<HexValue>0x000003D9</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>986 FPS</UserfriendlyName>
					<HexValue>0x000003DA</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>987 FPS</UserfriendlyName>
					<HexValue>0x000003DB</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>988 FPS</UserfriendlyName>
					<HexValue>0x000003DC</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>989 FPS</UserfriendlyName>
					<HexValue>0x000003DD</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>990 FPS</UserfriendlyName>
					<HexValue>0x000003DE</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>991 FPS</UserfriendlyName>
					<HexValue>0x000003DF</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>992 FPS</UserfriendlyName>
					<HexValue>0x000003E0</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>993 FPS</UserfriendlyName>
					<HexValue>0x000003E1</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>994 FPS</UserfriendlyName>
					<HexValue>0x000003E2</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>995 FPS</UserfriendlyName>
					<HexValue>0x000003E3</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>996 FPS</UserfriendlyName>
					<HexValue>0x000003E4</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>997 FPS</UserfriendlyName>
					<HexValue>0x000003E5</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>998 FPS</UserfriendlyName>
					<HexValue>0x000003E6</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>999 FPS</UserfriendlyName>
					<HexValue>0x000003E7</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>1000 FPS</UserfriendlyName>
					<HexValue>0x000003E8</HexValue>
				</CustomSettingValue>
			</SettingValues>
			<SettingMasks />
		</CustomSetting>
		<CustomSetting>
			<UserfriendlyName>Ultra Low Latency - CPL State</UserfriendlyName>
			<HexSettingID>0x0005F543</HexSettingID>
			<GroupName>2 - Sync and Refresh</GroupName>
			<MinRequiredDriverVersion>430.00</MinRequiredDriverVersion>
			<Description>This setting just keeps track of ULL setting for the nvidia control panel. No need to change it.</Description>
			<SettingValues>
				<CustomSettingValue>
					<UserfriendlyName>Off</UserfriendlyName>
					<HexValue>0x00000000</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>On</UserfriendlyName>
					<HexValue>0x00000001</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>Ultra</UserfriendlyName>
					<HexValue>0x00000002</HexValue>
				</CustomSettingValue>
			</SettingValues>
		</CustomSetting>
		<CustomSetting>
			<UserfriendlyName>Ultra Low Latency - Enabled</UserfriendlyName>
			<HexSettingID>0x10835000</HexSettingID>
			<GroupName>2 - Sync and Refresh</GroupName>
			<MinRequiredDriverVersion>430.00</MinRequiredDriverVersion>
			<SettingValues>
				<CustomSettingValue>
					<UserfriendlyName>Off</UserfriendlyName>
					<HexValue>0x00000000</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>On</UserfriendlyName>
					<HexValue>0x00000001</HexValue>
				</CustomSettingValue>
			</SettingValues>
		</CustomSetting>
		<CustomSetting>
			<UserfriendlyName>NVLINK - SLI Mode</UserfriendlyName>
			<HexSettingID>0x00A06948</HexSettingID>
			<GroupName>6 - SLI</GroupName>
			<MinRequiredDriverVersion>410.00</MinRequiredDriverVersion>
		</CustomSetting>
		<CustomSetting>
			<UserfriendlyName>Texture Filtering - Quality Substitution</UserfriendlyName>
			<HexSettingID>0x00CE2692</HexSettingID>
			<GroupName>4 - Texture Filtering</GroupName>
			<MinRequiredDriverVersion>418.00</MinRequiredDriverVersion>
			<SettingValues>
				<CustomSettingValue>
					<UserfriendlyName>No Substitution</UserfriendlyName>
					<HexValue>0x00000000</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>High quality becomes quality</UserfriendlyName>
					<HexValue>0x00000001</HexValue>
				</CustomSettingValue>
			</SettingValues>
			<SettingMasks />
		</CustomSetting>
		<CustomSetting>
			<UserfriendlyName>Antialiasing - MFAA Enabled</UserfriendlyName>
			<HexSettingID>0x0098C1AC</HexSettingID>
			<GroupName>3 - Antialiasing</GroupName>
			<MinRequiredDriverVersion>344.11</MinRequiredDriverVersion>
			<SettingValues>
				<CustomSettingValue>
					<UserfriendlyName>Off</UserfriendlyName>
					<HexValue>0x00000000</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>On</UserfriendlyName>
					<HexValue>0x00000001</HexValue>
				</CustomSettingValue>
			</SettingValues>
			<SettingMasks />
		</CustomSetting>
		<CustomSetting>
			<UserfriendlyName>Prefered Refreshrate</UserfriendlyName>
			<HexSettingID>0x0064B541</HexSettingID>
			<GroupName>2 - Sync and Refresh</GroupName>
			<SettingValues>
				<CustomSettingValue>
					<UserfriendlyName>Use the 3D application setting</UserfriendlyName>
					<HexValue>0x00000000</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>Highest available</UserfriendlyName>
					<HexValue>0x00000001</HexValue>
				</CustomSettingValue>
			</SettingValues>
			<SettingMasks />
		</CustomSetting>
		<CustomSetting>
			<UserfriendlyName>GSYNC - Indicator Overlay</UserfriendlyName>
			<HexSettingID>0x10029538</HexSettingID>
			<MinRequiredDriverVersion>331.00</MinRequiredDriverVersion>
			<GroupName>2 - Sync and Refresh</GroupName>
			<SettingValues>
				<CustomSettingValue>
					<UserfriendlyName>Off</UserfriendlyName>
					<HexValue>0x00000000</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>On</UserfriendlyName>
					<HexValue>0x00000001</HexValue>
				</CustomSettingValue>
			</SettingValues>
			<SettingMasks />
		</CustomSetting>
		<CustomSetting>
			<UserfriendlyName>GSYNC - Application Mode</UserfriendlyName>
			<HexSettingID>0x1194F158</HexSettingID>
			<MinRequiredDriverVersion>331.00</MinRequiredDriverVersion>
			<GroupName>2 - Sync and Refresh</GroupName>
			<SettingValues>
				<CustomSettingValue>
					<UserfriendlyName>Off</UserfriendlyName>
					<HexValue>0x00000000</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>Fullscreen only</UserfriendlyName>
					<HexValue>0x00000001</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>Fullscreen and Windowed</UserfriendlyName>
					<HexValue>0x00000002</HexValue>
				</CustomSettingValue>
			</SettingValues>
			<SettingMasks />
		</CustomSetting>
		<CustomSetting>
			<UserfriendlyName>GSYNC - Global Mode</UserfriendlyName>
			<HexSettingID>0x1094F1F7</HexSettingID>
			<MinRequiredDriverVersion>331.00</MinRequiredDriverVersion>
			<GroupName>2 - Sync and Refresh</GroupName>
			<SettingValues>
				<CustomSettingValue>
					<UserfriendlyName>Off</UserfriendlyName>
					<HexValue>0x00000000</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>Fullscreen only</UserfriendlyName>
					<HexValue>0x00000001</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>Fullscreen and Windowed</UserfriendlyName>
					<HexValue>0x00000002</HexValue>
				</CustomSettingValue>
			</SettingValues>
			<SettingMasks />
		</CustomSetting>
		<CustomSetting>
			<UserfriendlyName>GSYNC - Global Feature</UserfriendlyName>
			<HexSettingID>0x1094F157</HexSettingID>
			<MinRequiredDriverVersion>331.00</MinRequiredDriverVersion>
			<GroupName>2 - Sync and Refresh</GroupName>
			<SettingValues>
				<CustomSettingValue>
					<UserfriendlyName>Off</UserfriendlyName>
					<HexValue>0x00000000</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>On</UserfriendlyName>
					<HexValue>0x00000001</HexValue>
				</CustomSettingValue>
			</SettingValues>
			<SettingMasks />
		</CustomSetting>
		<CustomSetting>
			<UserfriendlyName>GSYNC - Application State</UserfriendlyName>
			<HexSettingID>0x10A879CF</HexSettingID>
			<MinRequiredDriverVersion>331.00</MinRequiredDriverVersion>
			<GroupName>2 - Sync and Refresh</GroupName>
			<SettingValues>
				<CustomSettingValue>
					<UserfriendlyName>Allow</UserfriendlyName>
					<HexValue>0x00000000</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>Force Off</UserfriendlyName>
					<HexValue>0x00000001</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>Disallow</UserfriendlyName>
					<HexValue>0x00000002</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>Utra Low Motion Blur</UserfriendlyName>
					<HexValue>0x00000003</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>Fixed Refresh Rate</UserfriendlyName>
					<HexValue>0x00000004</HexValue>
				</CustomSettingValue>
			</SettingValues>
			<SettingMasks />
		</CustomSetting>
		<CustomSetting>
			<UserfriendlyName>GSYNC - Application Requested State</UserfriendlyName>
			<HexSettingID>0x10A879AC</HexSettingID>
			<MinRequiredDriverVersion>331.00</MinRequiredDriverVersion>
			<GroupName>2 - Sync and Refresh</GroupName>
			<SettingValues>
				<CustomSettingValue>
					<UserfriendlyName>Allow</UserfriendlyName>
					<HexValue>0x00000000</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>Force Off</UserfriendlyName>
					<HexValue>0x00000001</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>Disallow</UserfriendlyName>
					<HexValue>0x00000002</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>Utra Low Motion Blur</UserfriendlyName>
					<HexValue>0x00000003</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>Fixed Refresh Rate</UserfriendlyName>
					<HexValue>0x00000004</HexValue>
				</CustomSettingValue>
			</SettingValues>
			<SettingMasks />
		</CustomSetting>
		<CustomSetting>
			<UserfriendlyName>Prevent Anisotropic Filtering</UserfriendlyName>
			<HexSettingID>0x103BCCB5</HexSettingID>
			<MinRequiredDriverVersion>331.00</MinRequiredDriverVersion>
			<GroupName>4 - Texture Filtering</GroupName>
			<SettingValues>
				<CustomSettingValue>
					<UserfriendlyName>Off</UserfriendlyName>
					<HexValue>0x00000000</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>On</UserfriendlyName>
					<HexValue>0x00000001</HexValue>
				</CustomSettingValue>
			</SettingValues>
			<SettingMasks />
		</CustomSetting>
		<CustomSetting>
			<UserfriendlyName>Shadercache - Enabled</UserfriendlyName>
			<HexSettingID>0x00198FFF</HexSettingID>
			<MinRequiredDriverVersion>337.50</MinRequiredDriverVersion>
			<GroupName>5 - Common</GroupName>
			<OverrideDefault>0x00000001</OverrideDefault>
			<SettingValues>
				<CustomSettingValue>
					<UserfriendlyName>Off</UserfriendlyName>
					<HexValue>0x00000000</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>On</UserfriendlyName>
					<HexValue>0x00000001</HexValue>
				</CustomSettingValue>
			</SettingValues>
			<SettingMasks />
		</CustomSetting>
		<CustomSetting>
			<UserfriendlyName>Antialiasing Fix</UserfriendlyName>
			<HexSettingID>0x000858F7</HexSettingID>
			<MinRequiredDriverVersion>320.14</MinRequiredDriverVersion>
			<GroupName>1 - Compatibility</GroupName>
			<OverrideDefault>0x00000001</OverrideDefault>
			<SettingValues>
				<CustomSettingValue>
					<UserfriendlyName>On</UserfriendlyName>
					<HexValue>0x00000000</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>Off</UserfriendlyName>
					<HexValue>0x00000001</HexValue>
				</CustomSettingValue>
			</SettingValues>
		</CustomSetting>
		<CustomSetting>
			<UserfriendlyName>Vertical Sync - Smooth AFR Behavior</UserfriendlyName>
			<HexSettingID>0x101AE763</HexSettingID>
			<MinRequiredDriverVersion>310.00</MinRequiredDriverVersion>
			<GroupName>2 - Sync and Refresh</GroupName>
			<SettingValues>
				<CustomSettingValue>
					<UserfriendlyName>Off</UserfriendlyName>
					<HexValue>0x00000000</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>On</UserfriendlyName>
					<HexValue>0x00000001</HexValue>
				</CustomSettingValue>
			</SettingValues>
			<SettingMasks />
		</CustomSetting>
		<CustomSetting>
			<UserfriendlyName>Texture Filtering - Driver Controlled LOD Bias</UserfriendlyName>
			<HexSettingID>0x00638E8F</HexSettingID>
			<MinRequiredDriverVersion>313.00</MinRequiredDriverVersion>
			<GroupName>4 - Texture Filtering</GroupName>
			<SettingValues>
				<CustomSettingValue>
					<UserfriendlyName>Off</UserfriendlyName>
					<HexValue>0x00000000</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>On</UserfriendlyName>
					<HexValue>0x00000001</HexValue>
				</CustomSettingValue>
			</SettingValues>
			<SettingMasks />
		</CustomSetting>
		<CustomSetting>
			<UserfriendlyName>Flip Indicator</UserfriendlyName>
			<HexSettingID>0x002CF156</HexSettingID>
			<GroupName>2 - Sync and Refresh</GroupName>
			<SettingValues>
				<CustomSettingValue>
					<UserfriendlyName>Disabled</UserfriendlyName>
					<HexValue>0x00000000</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>GRAPH_FLIP_FPS - FPS graph, measured on display hw flip</UserfriendlyName>
					<HexValue>0x00000001</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>GRAPH_PRESENT_FPS - FPS graph, measured when the user mode driver starts processing present</UserfriendlyName>
					<HexValue>0x00000002</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>GRAPH_APP_PRESENT_FPS - FPS graph, measured on app present</UserfriendlyName>
					<HexValue>0x00000004</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>DISPLAY_PAGING - Add red paging indicator bars to the GRAPH_PRESENT_FPS graph</UserfriendlyName>
					<HexValue>0x00000008</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>DISPLAY_APP_THREAD_WAIT - Add app thread wait time indiator bars to the GRAPH_APP_PRESENT_FPS graph</UserfriendlyName>
					<HexValue>0x00000010</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>Enabled - Enable everything</UserfriendlyName>
					<HexValue>0x000001FF</HexValue>
				</CustomSettingValue>
			</SettingValues>
			<SettingMasks />
		</CustomSetting>
		<CustomSetting>
			<UserfriendlyName>Antialiasing - FXAA Enabled</UserfriendlyName>
			<HexSettingID>0x1074C972</HexSettingID>
			<MinRequiredDriverVersion>300.00</MinRequiredDriverVersion>
			<GroupName>3 - Antialiasing</GroupName>
			<SettingValues>
				<CustomSettingValue>
					<UserfriendlyName>Off</UserfriendlyName>
					<HexValue>0x00000000</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>On</UserfriendlyName>
					<HexValue>0x00000001</HexValue>
				</CustomSettingValue>
			</SettingValues>
			<SettingMasks />
		</CustomSetting>
		<CustomSetting>
			<UserfriendlyName>Antialiasing - FXAA Indicator Overlay</UserfriendlyName>
			<HexSettingID>0x1068FB9C</HexSettingID>
			<MinRequiredDriverVersion>300.00</MinRequiredDriverVersion>
			<GroupName>3 - Antialiasing</GroupName>
			<SettingValues>
				<CustomSettingValue>
					<UserfriendlyName>Off</UserfriendlyName>
					<HexValue>0x00000000</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>On</UserfriendlyName>
					<HexValue>0x00000001</HexValue>
				</CustomSettingValue>
			</SettingValues>
			<SettingMasks />
		</CustomSetting>
		<CustomSetting>
			<UserfriendlyName>Antialiasing - FXAA Enabled (predefined by NVIDIA)</UserfriendlyName>
			<HexSettingID>0x1034CB89</HexSettingID>
			<MinRequiredDriverVersion>300.00</MinRequiredDriverVersion>
			<GroupName>3 - Antialiasing</GroupName>
			<SettingValues>
				<CustomSettingValue>
					<UserfriendlyName>Disallowed</UserfriendlyName>
					<HexValue>0x00000000</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>Allowed</UserfriendlyName>
					<HexValue>0x00000001</HexValue>
				</CustomSettingValue>
			</SettingValues>
			<SettingMasks />
		</CustomSetting>
		<CustomSetting>
			<UserfriendlyName>Antialiasing - Line Gamma</UserfriendlyName>
			<HexSettingID>0x2089BF6C</HexSettingID>
			<GroupName>3 - Antialiasing</GroupName>
			<SettingValues>
				<CustomSettingValue>
					<UserfriendlyName>Disabled</UserfriendlyName>
					<HexValue>0x00000000</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>Default</UserfriendlyName>
					<HexValue>0x00000010</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>Enabled</UserfriendlyName>
					<HexValue>0x00000023</HexValue>
				</CustomSettingValue>
			</SettingValues>
			<SettingMasks />
		</CustomSetting>
		<CustomSetting>
			<UserfriendlyName>Texture Filtering - LOD Bias (DX)</UserfriendlyName>
			<HexSettingID>0x00738E8F</HexSettingID>
			<GroupName>4 - Texture Filtering</GroupName>
			<SettingValues>
				<CustomSettingValue>
					<UserfriendlyName>-3.0000</UserfriendlyName>
					<HexValue>0xFFFFFFE8</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-2.8750</UserfriendlyName>
					<HexValue>0xFFFFFFE9</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-2.7500</UserfriendlyName>
					<HexValue>0xFFFFFFEA</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-2.6250</UserfriendlyName>
					<HexValue>0xFFFFFFEB</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-2.5000</UserfriendlyName>
					<HexValue>0xFFFFFFEC</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-2.3750</UserfriendlyName>
					<HexValue>0xFFFFFFED</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-2.2500</UserfriendlyName>
					<HexValue>0xFFFFFFEE</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-2.1250</UserfriendlyName>
					<HexValue>0xFFFFFFEF</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-2.0000</UserfriendlyName>
					<HexValue>0xFFFFFFF0</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-1.8750</UserfriendlyName>
					<HexValue>0xFFFFFFF1</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-1.7500</UserfriendlyName>
					<HexValue>0xFFFFFFF2</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-1.6250</UserfriendlyName>
					<HexValue>0xFFFFFFF3</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-1.5000</UserfriendlyName>
					<HexValue>0xFFFFFFF4</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-1.3750</UserfriendlyName>
					<HexValue>0xFFFFFFF5</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-1.2500</UserfriendlyName>
					<HexValue>0xFFFFFFF6</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-1.1250</UserfriendlyName>
					<HexValue>0xFFFFFFF7</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-1.0000</UserfriendlyName>
					<HexValue>0xFFFFFFF8</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-0.8750</UserfriendlyName>
					<HexValue>0xFFFFFFF9</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-0.7500</UserfriendlyName>
					<HexValue>0xFFFFFFFA</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-0.6250</UserfriendlyName>
					<HexValue>0xFFFFFFFB</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-0.5000</UserfriendlyName>
					<HexValue>0xFFFFFFFC</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-0.3750</UserfriendlyName>
					<HexValue>0xFFFFFFFD</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-0.2500</UserfriendlyName>
					<HexValue>0xFFFFFFFE</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-0.1250</UserfriendlyName>
					<HexValue>0xFFFFFFFF</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+0.0000</UserfriendlyName>
					<HexValue>0x00000000</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+0.1250</UserfriendlyName>
					<HexValue>0x00000001</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+0.2500</UserfriendlyName>
					<HexValue>0x00000002</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+0.3750</UserfriendlyName>
					<HexValue>0x00000003</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+0.5000</UserfriendlyName>
					<HexValue>0x00000004</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+0.6250</UserfriendlyName>
					<HexValue>0x00000005</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+0.7500</UserfriendlyName>
					<HexValue>0x00000006</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+0.8750</UserfriendlyName>
					<HexValue>0x00000007</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+1.0000</UserfriendlyName>
					<HexValue>0x00000008</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+1.1250</UserfriendlyName>
					<HexValue>0x00000009</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+1.2500</UserfriendlyName>
					<HexValue>0x0000000A</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+1.3750</UserfriendlyName>
					<HexValue>0x0000000B</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+1.5000</UserfriendlyName>
					<HexValue>0x0000000C</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+1.6250</UserfriendlyName>
					<HexValue>0x0000000D</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+1.7500</UserfriendlyName>
					<HexValue>0x0000000E</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+1.8750</UserfriendlyName>
					<HexValue>0x0000000F</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+2.0000</UserfriendlyName>
					<HexValue>0x00000010</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+2.1250</UserfriendlyName>
					<HexValue>0x00000011</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+2.2500</UserfriendlyName>
					<HexValue>0x00000012</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+2.3750</UserfriendlyName>
					<HexValue>0x00000013</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+2.5000</UserfriendlyName>
					<HexValue>0x00000014</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+2.6250</UserfriendlyName>
					<HexValue>0x00000015</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+2.7500</UserfriendlyName>
					<HexValue>0x00000016</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+2.8750</UserfriendlyName>
					<HexValue>0x00000017</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+3.0000</UserfriendlyName>
					<HexValue>0x00000018</HexValue>
				</CustomSettingValue>
			</SettingValues>
			<SettingMasks />
		</CustomSetting>
		<CustomSetting>
			<UserfriendlyName>Texture Filtering - LOD Bias (OGL)</UserfriendlyName>
			<HexSettingID>0x20403F79</HexSettingID>
			<GroupName>4 - Texture Filtering</GroupName>
			<SettingValues>
				<CustomSettingValue>
					<UserfriendlyName>-3.0000</UserfriendlyName>
					<HexValue>0xFFFFFFD0</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-2.9375</UserfriendlyName>
					<HexValue>0xFFFFFFD1</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-2.8750</UserfriendlyName>
					<HexValue>0xFFFFFFD2</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-2.8125</UserfriendlyName>
					<HexValue>0xFFFFFFD3</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-2.7500</UserfriendlyName>
					<HexValue>0xFFFFFFD4</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-2.6875</UserfriendlyName>
					<HexValue>0xFFFFFFD5</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-2.6250</UserfriendlyName>
					<HexValue>0xFFFFFFD6</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-2.5625</UserfriendlyName>
					<HexValue>0xFFFFFFD7</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-2.5000</UserfriendlyName>
					<HexValue>0xFFFFFFD8</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-2.4375</UserfriendlyName>
					<HexValue>0xFFFFFFD9</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-2.3750</UserfriendlyName>
					<HexValue>0xFFFFFFDA</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-2.3125</UserfriendlyName>
					<HexValue>0xFFFFFFDB</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-2.2500</UserfriendlyName>
					<HexValue>0xFFFFFFDC</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-2.1875</UserfriendlyName>
					<HexValue>0xFFFFFFDD</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-21250</UserfriendlyName>
					<HexValue>0xFFFFFFDE</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-2.0625</UserfriendlyName>
					<HexValue>0xFFFFFFDF</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-2.0000</UserfriendlyName>
					<HexValue>0xFFFFFFE0</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-1.9375</UserfriendlyName>
					<HexValue>0xFFFFFFE1</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-1.8750</UserfriendlyName>
					<HexValue>0xFFFFFFE2</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-1.8125</UserfriendlyName>
					<HexValue>0xFFFFFFE3</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-1.7500</UserfriendlyName>
					<HexValue>0xFFFFFFE4</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-1.6875</UserfriendlyName>
					<HexValue>0xFFFFFFE5</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-1.6250</UserfriendlyName>
					<HexValue>0xFFFFFFE6</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-1.5625</UserfriendlyName>
					<HexValue>0xFFFFFFE7</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-1.5000</UserfriendlyName>
					<HexValue>0xFFFFFFE8</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-1.4375</UserfriendlyName>
					<HexValue>0xFFFFFFE9</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-1.3750</UserfriendlyName>
					<HexValue>0xFFFFFFEA</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-1.3125</UserfriendlyName>
					<HexValue>0xFFFFFFEB</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-1.2500</UserfriendlyName>
					<HexValue>0xFFFFFFEC</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-1.1875</UserfriendlyName>
					<HexValue>0xFFFFFFED</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-1.1250</UserfriendlyName>
					<HexValue>0xFFFFFFEE</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-1.0625</UserfriendlyName>
					<HexValue>0xFFFFFFEF</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-1.0000</UserfriendlyName>
					<HexValue>0xFFFFFFF0</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-0.9375</UserfriendlyName>
					<HexValue>0xFFFFFFF1</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-0.8750</UserfriendlyName>
					<HexValue>0xFFFFFFF2</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-0.8125</UserfriendlyName>
					<HexValue>0xFFFFFFF3</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-0.7500</UserfriendlyName>
					<HexValue>0xFFFFFFF4</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-0.6875</UserfriendlyName>
					<HexValue>0xFFFFFFF5</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-0.6250</UserfriendlyName>
					<HexValue>0xFFFFFFF6</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-0.5625</UserfriendlyName>
					<HexValue>0xFFFFFFF7</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-0.5000</UserfriendlyName>
					<HexValue>0xFFFFFFF8</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-0.4375</UserfriendlyName>
					<HexValue>0xFFFFFFF9</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-0.3750</UserfriendlyName>
					<HexValue>0xFFFFFFFA</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-0.3125</UserfriendlyName>
					<HexValue>0xFFFFFFFB</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-0.2500</UserfriendlyName>
					<HexValue>0xFFFFFFFC</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-0.1875</UserfriendlyName>
					<HexValue>0xFFFFFFFD</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-0.1250</UserfriendlyName>
					<HexValue>0xFFFFFFFE</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>-0.0625</UserfriendlyName>
					<HexValue>0xFFFFFFFF</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+0.0000</UserfriendlyName>
					<HexValue>0x00000000</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+0.0625</UserfriendlyName>
					<HexValue>0x00000001</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+0.1250</UserfriendlyName>
					<HexValue>0x00000002</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+0.1875</UserfriendlyName>
					<HexValue>0x00000003</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+0.2500</UserfriendlyName>
					<HexValue>0x00000004</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+0.3125</UserfriendlyName>
					<HexValue>0x00000005</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+0.3750</UserfriendlyName>
					<HexValue>0x00000006</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+0.4375</UserfriendlyName>
					<HexValue>0x00000007</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+0.5000</UserfriendlyName>
					<HexValue>0x00000008</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+0.5625</UserfriendlyName>
					<HexValue>0x00000009</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+0.6250</UserfriendlyName>
					<HexValue>0x0000000A</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+0.6875</UserfriendlyName>
					<HexValue>0x0000000B</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+0.7500</UserfriendlyName>
					<HexValue>0x0000000C</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+0.8125</UserfriendlyName>
					<HexValue>0x0000000D</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+0.8750</UserfriendlyName>
					<HexValue>0x0000000E</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+0.9375</UserfriendlyName>
					<HexValue>0x0000000F</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+1.0000</UserfriendlyName>
					<HexValue>0x00000010</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+1.0625</UserfriendlyName>
					<HexValue>0x00000011</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+1.1250</UserfriendlyName>
					<HexValue>0x00000012</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+1.1875</UserfriendlyName>
					<HexValue>0x00000013</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+1.2500</UserfriendlyName>
					<HexValue>0x00000014</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+1.3125</UserfriendlyName>
					<HexValue>0x00000015</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+1.3750</UserfriendlyName>
					<HexValue>0x00000016</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+1.4375</UserfriendlyName>
					<HexValue>0x00000017</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+1.5000</UserfriendlyName>
					<HexValue>0x00000018</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+1.5625</UserfriendlyName>
					<HexValue>0x00000019</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+1.6250</UserfriendlyName>
					<HexValue>0x0000001A</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+1.6875</UserfriendlyName>
					<HexValue>0x0000001B</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+1.7500</UserfriendlyName>
					<HexValue>0x0000001C</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+1.8125</UserfriendlyName>
					<HexValue>0x0000001D</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+1.8750</UserfriendlyName>
					<HexValue>0x0000001E</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+1.9375</UserfriendlyName>
					<HexValue>0x0000001F</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+2.0000</UserfriendlyName>
					<HexValue>0x00000020</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+2.0625</UserfriendlyName>
					<HexValue>0x00000021</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+2.1250</UserfriendlyName>
					<HexValue>0x00000022</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+2.1875</UserfriendlyName>
					<HexValue>0x00000023</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+2.2500</UserfriendlyName>
					<HexValue>0x00000024</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+2.3125</UserfriendlyName>
					<HexValue>0x00000025</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+2.3750</UserfriendlyName>
					<HexValue>0x00000026</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+2.4375</UserfriendlyName>
					<HexValue>0x00000027</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+2.5000</UserfriendlyName>
					<HexValue>0x00000028</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+2.5625</UserfriendlyName>
					<HexValue>0x00000029</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+2.6250</UserfriendlyName>
					<HexValue>0x0000002A</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+2.6875</UserfriendlyName>
					<HexValue>0x0000002B</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+2.7500</UserfriendlyName>
					<HexValue>0x0000002C</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+2.8125</UserfriendlyName>
					<HexValue>0x0000002D</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+2.8750</UserfriendlyName>
					<HexValue>0x0000002E</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+2.9375</UserfriendlyName>
					<HexValue>0x0000002F</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>+3.0000</UserfriendlyName>
					<HexValue>0x00000030</HexValue>
				</CustomSettingValue>
			</SettingValues>
			<SettingMasks />
		</CustomSetting>
		<CustomSetting>
			<UserfriendlyName>SLI - Compatibility Bits (OGL)</UserfriendlyName>
			<HexSettingID>0x209746C1</HexSettingID>
			<GroupName>1 - Compatibility</GroupName>
			<SettingValues />
		</CustomSetting>
		<CustomSetting>
			<UserfriendlyName>SLI - Compatibility Bits (DX12)</UserfriendlyName>
			<HexSettingID>0x00A04746</HexSettingID>
			<GroupName>1 - Compatibility</GroupName>
			<SettingValues />
		</CustomSetting>
		<CustomSetting>
			<UserfriendlyName>SLI - Compatibility Bits (DX10 + DX11)</UserfriendlyName>
			<HexSettingID>0x00A06946</HexSettingID>
			<GroupName>1 - Compatibility</GroupName>
			<SettingValues />
			<SettingMasks>
				<CustomSettingMask>
					<UserfriendlyName>SLI - Mode</UserfriendlyName>
					<HexMask>0x0000000F</HexMask>
					<MaskValues>
						<CustomSettingValue>
							<UserfriendlyName>Auto</UserfriendlyName>
							<HexValue>0x00000000</HexValue>
						</CustomSettingValue>
						<CustomSettingValue>
							<UserfriendlyName>Single</UserfriendlyName>
							<HexValue>0x00000004</HexValue>
						</CustomSettingValue>
						<CustomSettingValue>
							<UserfriendlyName>AFR</UserfriendlyName>
							<HexValue>0x00000001</HexValue>
						</CustomSettingValue>
						<CustomSettingValue>
							<UserfriendlyName>SFR</UserfriendlyName>
							<HexValue>0x00000002</HexValue>
						</CustomSettingValue>
						<CustomSettingValue>
							<UserfriendlyName>AFR-SFR</UserfriendlyName>
							<HexValue>0x00000003</HexValue>
						</CustomSettingValue>
						<CustomSettingValue>
							<UserfriendlyName>3 Way SLI AFR</UserfriendlyName>
							<HexValue>0x00000006</HexValue>
						</CustomSettingValue>
						<CustomSettingValue>
							<UserfriendlyName>4 Way SLI AFR</UserfriendlyName>
							<HexValue>0x00000005</HexValue>
						</CustomSettingValue>
					</MaskValues>
				</CustomSettingMask>
			</SettingMasks>
		</CustomSetting>
		<CustomSetting>
			<UserfriendlyName>SLI - Compatibility Bits (DX9)</UserfriendlyName>
			<HexSettingID>0x1095DEF8</HexSettingID>
			<GroupName>1 - Compatibility</GroupName>
			<SettingValues />
			<SettingMasks>
				<CustomSettingMask>
					<UserfriendlyName>SLI - Mode</UserfriendlyName>
					<HexMask>0x00000007</HexMask>
					<MaskValues>
						<CustomSettingValue>
							<UserfriendlyName>Auto</UserfriendlyName>
							<HexValue>0x00000000</HexValue>
						</CustomSettingValue>
						<CustomSettingValue>
							<UserfriendlyName>Single</UserfriendlyName>
							<HexValue>0x00000004</HexValue>
						</CustomSettingValue>
						<CustomSettingValue>
							<UserfriendlyName>AFR</UserfriendlyName>
							<HexValue>0x00000001</HexValue>
						</CustomSettingValue>
						<CustomSettingValue>
							<UserfriendlyName>SFR</UserfriendlyName>
							<HexValue>0x00000002</HexValue>
						</CustomSettingValue>
						<CustomSettingValue>
							<UserfriendlyName>AFR-SFR</UserfriendlyName>
							<HexValue>0x00000003</HexValue>
						</CustomSettingValue>
						<CustomSettingValue>
							<UserfriendlyName>3 Way SLI AFR</UserfriendlyName>
							<HexValue>0x00000006</HexValue>
						</CustomSettingValue>
						<CustomSettingValue>
							<UserfriendlyName>4 Way SLI AFR</UserfriendlyName>
							<HexValue>0x00000005</HexValue>
						</CustomSettingValue>
					</MaskValues>
				</CustomSettingMask>
				<CustomSettingMask>
					<UserfriendlyName>SLI - AFR Mode</UserfriendlyName>
					<HexMask>0x02430000</HexMask>
					<MaskValues>
						<CustomSettingValue>
							<UserfriendlyName>AFR 1</UserfriendlyName>
							<HexValue>0x00000000</HexValue>
						</CustomSettingValue>
						<CustomSettingValue>
							<UserfriendlyName>AFR 2</UserfriendlyName>
							<HexValue>0x02430000</HexValue>
						</CustomSettingValue>
					</MaskValues>
				</CustomSettingMask>
			</SettingMasks>
		</CustomSetting>
		<CustomSetting>
			<UserfriendlyName>Antialiasing - Compatibility (DX9)</UserfriendlyName>
			<HexSettingID>0x00D55F7D</HexSettingID>
			<GroupName>1 - Compatibility</GroupName>
			<SettingValues />
			<SettingMasks />
		</CustomSetting>
		<CustomSetting>
			<UserfriendlyName>Antialiasing - Compatibility (DX1x)</UserfriendlyName>
			<HexSettingID>0x00E32F8A</HexSettingID>
			<GroupName>1 - Compatibility</GroupName>
			<SettingValues />
			<SettingMasks />
		</CustomSetting>
		<CustomSetting>
			<UserfriendlyName>Ambient Occlusion - Compatibility</UserfriendlyName>
			<HexSettingID>0x002C7F45</HexSettingID>
			<GroupName>1 - Compatibility</GroupName>
			<SettingValues />
			<SettingMasks />
		</CustomSetting>
		<CustomSetting>
			<UserfriendlyName>Antialiasing - Gamma Correction</UserfriendlyName>
			<HexSettingID>0x107D639D</HexSettingID>
			<OverrideDefault>0x00000002</OverrideDefault>
			<GroupName>3 - Antialiasing</GroupName>
			<SettingValues>
				<CustomSettingValue>
					<UserfriendlyName>Off</UserfriendlyName>
					<HexValue>0x00000000</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>On</UserfriendlyName>
					<HexValue>0x00000002</HexValue>
				</CustomSettingValue>
			</SettingValues>
			<SettingMasks />
		</CustomSetting>
		<CustomSetting>
			<UserfriendlyName>Antialiasing (MSAA) - Behavior Flags</UserfriendlyName>
			<HexSettingID>0x10ECDB82</HexSettingID>
			<GroupName>3 - Antialiasing</GroupName>
			<SettingValues>
				<CustomSettingValue>
					<UserfriendlyName>None</UserfriendlyName>
					<HexValue>0x00000000</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>Treat 'Override any application setting' as 'Application-controlled'</UserfriendlyName>
					<HexValue>0x00000001</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>Treat 'Override any application setting' as 'Enhance the application setting'</UserfriendlyName>
					<HexValue>0x00000002</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>Disable 'Override any application setting'</UserfriendlyName>
					<HexValue>0x00000003</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>Treat 'Enhance the application setting' as 'Application-controlled'</UserfriendlyName>
					<HexValue>0x00000004</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>Treat 'Enhance the application setting' as 'Override any application setting'</UserfriendlyName>
					<HexValue>0x00000008</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>Disable 'Enhance the application setting'</UserfriendlyName>
					<HexValue>0x0000000C</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>Disable Antialiasing at NVIDIA Control Panel</UserfriendlyName>
					<HexValue>0x00040000</HexValue>
				</CustomSettingValue>
			</SettingValues>
			<SettingMasks />
		</CustomSetting>
		<CustomSetting>
			<UserfriendlyName>Antialiasing (MSAA) - Mode</UserfriendlyName>
			<HexSettingID>0x107EFC5B</HexSettingID>
			<GroupName>3 - Antialiasing</GroupName>
			<SettingValues>
				<CustomSettingValue>
					<UserfriendlyName>Application-controlled</UserfriendlyName>
					<HexValue>0x00000000</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>Override any application setting</UserfriendlyName>
					<HexValue>0x00000001</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>Enhance the application setting</UserfriendlyName>
					<HexValue>0x00000002</HexValue>
				</CustomSettingValue>
			</SettingValues>
			<SettingMasks />
		</CustomSetting>
		<CustomSetting>
			<UserfriendlyName>Antialiasing (MSAA) - Setting</UserfriendlyName>
			<HexSettingID>0x10D773D2</HexSettingID>
			<GroupName>3 - Antialiasing</GroupName>
			<SettingValues>
				<CustomSettingValue>
					<UserfriendlyName>Application-controlled / Off</UserfriendlyName>
					<HexValue>0x00000000</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>2x [2x Multisampling]</UserfriendlyName>
					<HexValue>0x0000000E</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>2xQ [2x Quincunx (blurred)]</UserfriendlyName>
					<HexValue>0x0000000F</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>4x [4x Multisampling]</UserfriendlyName>
					<HexValue>0x00000010</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>8x [8x CSAA (4 color + 4 cv samples)]</UserfriendlyName>
					<HexValue>0x00000026</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>16x [16x CSAA (4 color + 12 cv samples)]</UserfriendlyName>
					<HexValue>0x00000027</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>8xQ [8x Multisampling]</UserfriendlyName>
					<HexValue>0x00000025</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>16xQ [16x CSAA (8 color + 8 cv samples)]</UserfriendlyName>
					<HexValue>0x00000028</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>32x [32x CSAA (8 color + 24 cv samples)]</UserfriendlyName>
					<HexValue>0x0000001D</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>2x1 [2x1 Supersampling (D3D only)]</UserfriendlyName>
					<HexValue>0x00000001</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>1x2 [1x2 Supersampling (D3D only)]</UserfriendlyName>
					<HexValue>0x00000002</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>2x2 [2x2 Supersampling (D3D only)]</UserfriendlyName>
					<HexValue>0x00000005</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>3x3 [3x3 Supersampling (D3D only)]</UserfriendlyName>
					<HexValue>0x0000000A</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>4x4 [4x4 Supersampling (D3D only)]</UserfriendlyName>
					<HexValue>0x0000000C</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>4xS [Combined: 1x2 SS + 2x MS (D3D only)]</UserfriendlyName>
					<HexValue>0x00000013</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>8xS [Combined: 1x2 SS + 4x MS]</UserfriendlyName>
					<HexValue>0x00000018</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>8xSQ [Combined: 2x2 SS + 2x MS]</UserfriendlyName>
					<HexValue>0x00000019</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>12xS [Combined: 2x2 SS + 4x OGMS (D3D only)]</UserfriendlyName>
					<HexValue>0x00000017</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>16xS [Combined: 2x2 SS + 4x MS]</UserfriendlyName>
					<HexValue>0x0000001A</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>32xS [Combined: 2x2 SS + 8x MS]</UserfriendlyName>
					<HexValue>0x00000029</HexValue>
				</CustomSettingValue>
			</SettingValues>
			<SettingMasks />
		</CustomSetting>
		<CustomSetting>
			<UserfriendlyName>Antialiasing - Transparency Multisampling</UserfriendlyName>
			<HexSettingID>0x10FC2D9C</HexSettingID>
			<GroupName>3 - Antialiasing</GroupName>
			<SettingValues>
				<CustomSettingValue>
					<UserfriendlyName>Disabled</UserfriendlyName>
					<HexValue>0x00000000</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>Enabled</UserfriendlyName>
					<HexValue>0x00000004</HexValue>
				</CustomSettingValue>
			</SettingValues>
			<SettingMasks />
		</CustomSetting>
		<CustomSetting>
			<UserfriendlyName>Antialiasing - Transparency Supersampling</UserfriendlyName>
			<HexSettingID>0x10D48A85</HexSettingID>
			<GroupName>3 - Antialiasing</GroupName>
			<SettingValues>
				<CustomSettingValue>
					<UserfriendlyName>Off / Multisampling</UserfriendlyName>
					<HexValue>0x00000000</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>Supersampling</UserfriendlyName>
					<HexValue>0x00000023</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>2x Supersampling</UserfriendlyName>
					<HexValue>0x00000014</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>4x Supersampling</UserfriendlyName>
					<HexValue>0x00000024</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>8x Supersampling</UserfriendlyName>
					<HexValue>0x00000034</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>2x Sparse Grid Supersampling</UserfriendlyName>
					<HexValue>0x00000018</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>4x Sparse Grid Supersampling</UserfriendlyName>
					<HexValue>0x00000028</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>8x Sparse Grid Supersampling</UserfriendlyName>
					<HexValue>0x00000038</HexValue>
				</CustomSettingValue>
			</SettingValues>
			<SettingMasks />
		</CustomSetting>
		<CustomSetting>
			<UserfriendlyName>Anisotropic Filtering - Mode</UserfriendlyName>
			<HexSettingID>0x10D2BB16</HexSettingID>
			<GroupName>4 - Texture Filtering</GroupName>
			<SettingValues>
				<CustomSettingValue>
					<UserfriendlyName>Application-controlled</UserfriendlyName>
					<HexValue>0x00000000</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>User-defined / Off</UserfriendlyName>
					<HexValue>0x00000001</HexValue>
				</CustomSettingValue>
			</SettingValues>
			<SettingMasks />
		</CustomSetting>
		<CustomSetting>
			<UserfriendlyName>Anisotropic Filtering - Setting</UserfriendlyName>
			<HexSettingID>0x101E61A9</HexSettingID>
			<GroupName>4 - Texture Filtering</GroupName>
			<SettingValues>
				<CustomSettingValue>
					<UserfriendlyName>Off [Point]</UserfriendlyName>
					<HexValue>0x00000000</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>Off [Linear]</UserfriendlyName>
					<HexValue>0x00000001</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>2x</UserfriendlyName>
					<HexValue>0x00000002</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>4x</UserfriendlyName>
					<HexValue>0x00000004</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>6x</UserfriendlyName>
					<HexValue>0x00000004</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>8x</UserfriendlyName>
					<HexValue>0x00000008</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>12x</UserfriendlyName>
					<HexValue>0x0000000C</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>16x</UserfriendlyName>
					<HexValue>0x00000010</HexValue>
				</CustomSettingValue>
			</SettingValues>
			<SettingMasks />
		</CustomSetting>
		<CustomSetting>
			<UserfriendlyName>Anisotropic Filter - Optimization</UserfriendlyName>
			<HexSettingID>0x0084CD70</HexSettingID>
			<GroupName>4 - Texture Filtering</GroupName>
			<SettingValues>
				<CustomSettingValue>
					<UserfriendlyName>Off</UserfriendlyName>
					<HexValue>0x00000000</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>On</UserfriendlyName>
					<HexValue>0x00000001</HexValue>
				</CustomSettingValue>
			</SettingValues>
			<SettingMasks />
		</CustomSetting>
		<CustomSetting>
			<UserfriendlyName>Anisotropic Filter - Sample Optimization</UserfriendlyName>
			<HexSettingID>0x00E73211</HexSettingID>
			<GroupName>4 - Texture Filtering</GroupName>
			<SettingValues>
				<CustomSettingValue>
					<UserfriendlyName>Off</UserfriendlyName>
					<HexValue>0x00000000</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>On</UserfriendlyName>
					<HexValue>0x00000001</HexValue>
				</CustomSettingValue>
			</SettingValues>
			<SettingMasks />
		</CustomSetting>
		<CustomSetting>
			<UserfriendlyName>Texture Filtering - Negative LOD bias</UserfriendlyName>
			<HexSettingID>0x0019BB68</HexSettingID>
			<GroupName>4 - Texture Filtering</GroupName>
			<SettingValues>
				<CustomSettingValue>
					<UserfriendlyName>Allow</UserfriendlyName>
					<HexValue>0x00000000</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>Clamp</UserfriendlyName>
					<HexValue>0x00000001</HexValue>
				</CustomSettingValue>
			</SettingValues>
			<SettingMasks />
		</CustomSetting>
		<CustomSetting>
			<UserfriendlyName>Texture Filtering - Quality</UserfriendlyName>
			<HexSettingID>0x00CE2691</HexSettingID>
			<GroupName>4 - Texture Filtering</GroupName>
			<SettingValues>
				<CustomSettingValue>
					<UserfriendlyName>Quality</UserfriendlyName>
					<HexValue>0x00000000</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>Performance</UserfriendlyName>
					<HexValue>0x0000000A</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>High performance</UserfriendlyName>
					<HexValue>0x00000014</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>High quality</UserfriendlyName>
					<HexValue>0xFFFFFFF6</HexValue>
				</CustomSettingValue>
			</SettingValues>
			<SettingMasks />
		</CustomSetting>
		<CustomSetting>
			<UserfriendlyName>Texture Filtering - Trilinear Optimization</UserfriendlyName>
			<HexSettingID>0x002ECAF2</HexSettingID>
			<GroupName>4 - Texture Filtering</GroupName>
			<SettingValues>
				<CustomSettingValue>
					<UserfriendlyName>On ( will be ignored if using high quality )</UserfriendlyName>
					<HexValue>0x00000000</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>Off</UserfriendlyName>
					<HexValue>0x00000001</HexValue>
				</CustomSettingValue>
			</SettingValues>
			<SettingMasks />
		</CustomSetting>
		<CustomSetting>
			<UserfriendlyName>Ambient Occlusion  - Usage</UserfriendlyName>
			<HexSettingID>0x00664339</HexSettingID>
			<GroupName>5 - Common</GroupName>
			<SettingValues>
				<CustomSettingValue>
					<UserfriendlyName>Disabled</UserfriendlyName>
					<HexValue>0x00000000</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>Enabled</UserfriendlyName>
					<HexValue>0x00000001</HexValue>
				</CustomSettingValue>
			</SettingValues>
			<SettingMasks />
		</CustomSetting>
		<CustomSetting>
			<UserfriendlyName>Ambient Occlusion - Setting</UserfriendlyName>
			<HexSettingID>0x00667329</HexSettingID>
			<GroupName>5 - Common</GroupName>
			<SettingValues>
				<CustomSettingValue>
					<UserfriendlyName>Off</UserfriendlyName>
					<HexValue>0x00000000</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>Performance</UserfriendlyName>
					<HexValue>0x00000001</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>Quality</UserfriendlyName>
					<HexValue>0x00000002</HexValue>
				</CustomSettingValue>
				<!--<CustomSettingValue>
          <UserfriendlyName>High quality</UserfriendlyName>
          <HexValue>0x00000003</HexValue>
        </CustomSettingValue>-->
			</SettingValues>
			<SettingMasks />
		</CustomSetting>
		<CustomSetting>
			<UserfriendlyName>Maximum Pre-Rendered Frames</UserfriendlyName>
			<HexSettingID>0x007BA09E</HexSettingID>
			<GroupName>2 - Sync and Refresh</GroupName>
			<SettingValues>
				<CustomSettingValue>
					<UserfriendlyName>Use the 3D application setting</UserfriendlyName>
					<HexValue>0x00000000</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>1</UserfriendlyName>
					<HexValue>0x00000001</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>2</UserfriendlyName>
					<HexValue>0x00000002</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>3</UserfriendlyName>
					<HexValue>0x00000003</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>4</UserfriendlyName>
					<HexValue>0x00000004</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>5</UserfriendlyName>
					<HexValue>0x00000005</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>6</UserfriendlyName>
					<HexValue>0x00000006</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>7</UserfriendlyName>
					<HexValue>0x00000007</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>8</UserfriendlyName>
					<HexValue>0x00000008</HexValue>
				</CustomSettingValue>
			</SettingValues>
			<SettingMasks />
		</CustomSetting>
		<CustomSetting>
			<UserfriendlyName>Threaded Optimization</UserfriendlyName>
			<HexSettingID>0x20C1221E</HexSettingID>
			<GroupName>5 - Common</GroupName>
			<SettingValues>
				<CustomSettingValue>
					<UserfriendlyName>Auto</UserfriendlyName>
					<HexValue>0x00000000</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>On</UserfriendlyName>
					<HexValue>0x00000001</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>Off</UserfriendlyName>
					<HexValue>0x00000002</HexValue>
				</CustomSettingValue>
			</SettingValues>
			<SettingMasks />
		</CustomSetting>
		<CustomSetting>
			<UserfriendlyName>Triple Buffering</UserfriendlyName>
			<HexSettingID>0x20FDD1F9</HexSettingID>
			<GroupName>2 - Sync and Refresh</GroupName>
			<SettingValues>
				<CustomSettingValue>
					<UserfriendlyName>Off</UserfriendlyName>
					<HexValue>0x00000000</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>On</UserfriendlyName>
					<HexValue>0x00000001</HexValue>
				</CustomSettingValue>
			</SettingValues>
			<SettingMasks />
		</CustomSetting>
		<CustomSetting>
			<UserfriendlyName>Vertical Sync</UserfriendlyName>
			<HexSettingID>0x00A879CF</HexSettingID>
			<GroupName>2 - Sync and Refresh</GroupName>
			<SettingValues>
				<CustomSettingValue>
					<UserfriendlyName>Force off</UserfriendlyName>
					<HexValue>0x08416747</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>Force on</UserfriendlyName>
					<HexValue>0x47814940</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>Fast Sync</UserfriendlyName>
					<HexValue>0x18888888</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>Use the 3D application setting</UserfriendlyName>
					<HexValue>0x60925292</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>1/2 Refresh Rate</UserfriendlyName>
					<HexValue>0x32610244</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>1/3 Refresh Rate</UserfriendlyName>
					<HexValue>0x71271021</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>1/4 Refresh Rate</UserfriendlyName>
					<HexValue>0x13245256</HexValue>
				</CustomSettingValue>
			</SettingValues>
			<SettingMasks />
		</CustomSetting>
		<CustomSetting>
			<UserfriendlyName>Vertical Sync - Tear Control</UserfriendlyName>
			<HexSettingID>0x005A375C</HexSettingID>
			<MinRequiredDriverVersion>300.00</MinRequiredDriverVersion>
			<GroupName>2 - Sync and Refresh</GroupName>
			<SettingValues>
				<CustomSettingValue>
					<UserfriendlyName>Standard</UserfriendlyName>
					<HexValue>0x96861077</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>Adaptive</UserfriendlyName>
					<HexValue>0x99941284</HexValue>
				</CustomSettingValue>
			</SettingValues>
			<SettingMasks />
		</CustomSetting>
		<CustomSetting>
			<UserfriendlyName>PhysX - Indicator Overlay</UserfriendlyName>
			<HexSettingID>0x1094F16F</HexSettingID>
			<GroupName>5 - Common</GroupName>
			<SettingValues>
				<CustomSettingValue>
					<UserfriendlyName>On</UserfriendlyName>
					<HexValue>0x24545582</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>Off</UserfriendlyName>
					<HexValue>0x34534064</HexValue>
				</CustomSettingValue>
			</SettingValues>
			<SettingMasks />
		</CustomSetting>
		<CustomSetting>
			<UserfriendlyName>Power Management - Mode</UserfriendlyName>
			<HexSettingID>0x1057EB71</HexSettingID>
			<GroupName>5 - Common</GroupName>
			<SettingValues>
				<CustomSettingValue>
					<UserfriendlyName>Adaptive</UserfriendlyName>
					<HexValue>0x00000000</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>Prefer maximum performance</UserfriendlyName>
					<HexValue>0x00000001</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>Optimal performance</UserfriendlyName>
					<HexValue>0x00000005</HexValue>
				</CustomSettingValue>
			</SettingValues>
			<SettingMasks />
		</CustomSetting>
		<CustomSetting>
			<UserfriendlyName>CUDA - Force P2 State</UserfriendlyName>
			<HexSettingID>0x50166C5E</HexSettingID>
			<GroupName>5 - Common</GroupName>
			<OverrideDefault>0x00000001</OverrideDefault>
			<SettingValues>
				<CustomSettingValue>
					<UserfriendlyName>Off</UserfriendlyName>
					<HexValue>0x00000000</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>On</UserfriendlyName>
					<HexValue>0x00000001</HexValue>
				</CustomSettingValue>
			</SettingValues>
			<SettingMasks />
		</CustomSetting>
		<CustomSetting>
			<UserfriendlyName>Extension Limit (OGL)</UserfriendlyName>
			<HexSettingID>0x20FF7493</HexSettingID>
			<GroupName>5 - Common</GroupName>
			<SettingValues>
				<CustomSettingValue>
					<UserfriendlyName>Off</UserfriendlyName>
					<HexValue>0x00000000</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>On</UserfriendlyName>
					<HexValue>0x00000001</HexValue>
				</CustomSettingValue>
			</SettingValues>
			<SettingMasks />
		</CustomSetting>
		<CustomSetting>
			<UserfriendlyName>Multi-Display / Mixed-GPU Acceleration</UserfriendlyName>
			<HexSettingID>0x200AEBFC</HexSettingID>
			<GroupName>5 - Common</GroupName>
			<SettingValues>
				<CustomSettingValue>
					<UserfriendlyName>Single display performance mode</UserfriendlyName>
					<HexValue>0x00000000</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>Compatibility performance mode</UserfriendlyName>
					<HexValue>0x00000001</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>Multi display performance mode</UserfriendlyName>
					<HexValue>0x00000003</HexValue>
				</CustomSettingValue>
			</SettingValues>
			<SettingMasks />
		</CustomSetting>
		<CustomSetting>
			<UserfriendlyName>Version Override (OGL)</UserfriendlyName>
			<HexSettingID>0x2046B3ED</HexSettingID>
			<GroupName>5 - Common</GroupName>
			<SettingValues>
				<CustomSettingValue>
					<UserfriendlyName>Disabled</UserfriendlyName>
					<HexValue>0x00000000</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>OpenGL Version 1.0</UserfriendlyName>
					<HexValue>0x00302e31</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>OpenGL Version 1.1</UserfriendlyName>
					<HexValue>0x00312e31</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>OpenGL Version 1.2</UserfriendlyName>
					<HexValue>0x00322e31</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>OpenGL Version 1.3</UserfriendlyName>
					<HexValue>0x00332e31</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>OpenGL Version 1.4</UserfriendlyName>
					<HexValue>0x00342e31</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>OpenGL Version 1.5</UserfriendlyName>
					<HexValue>0x00352e31</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>OpenGL Version 2.0</UserfriendlyName>
					<HexValue>0x00302e32</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>OpenGL Version 2.1</UserfriendlyName>
					<HexValue>0x00312e32</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>OpenGL Version 3.0</UserfriendlyName>
					<HexValue>0x00302e33</HexValue>
				</CustomSettingValue>
				<CustomSettingValue>
					<UserfriendlyName>OpenGL Version 3.1</UserfriendlyName>
					<HexValue>0x00312e33</HexValue>
				</CustomSettingValue>
			</SettingValues>
		</CustomSetting>

		<!--<CustomSetting>
      <UserfriendlyName>StereoProfile</UserfriendlyName>
      <HexSettingID>0x701EB457</HexSettingID>
      <GroupName>7 - Stereo</GroupName>
      <SettingValues>
        <CustomSettingValue>
          -->
		<!--
           Not exactly the same behaviour as removing the setting from the
           profile, e.g. 3D still kicks in for windowed DX9 apps.
          -->
		<!--
          <UserfriendlyName>No</UserfriendlyName>
          <HexValue>0x00000000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>Yes</UserfriendlyName>
          <HexValue>0x00000001</HexValue>
        </CustomSettingValue>
      </SettingValues>
    </CustomSetting>
    <CustomSetting>
      <UserfriendlyName>StereoConvergence</UserfriendlyName>
      <HexSettingID>0x708DB8C5</HexSettingID>
      -->
		<!-- There are two alternate IDs for StereoConvergence: 0x7077bace and 0x7084807e -->
		<!--
      <GroupName>7 - Stereo</GroupName>
      <OverrideDefault>0x40800000</OverrideDefault>
      -->
		<!--
           This is an arbitrary floating point value. The below table lists
           values among some of the more common ranges, but it would be better
           to just interpret the field as a float since the correct answer
           depends largely on the engine, game design and player preferences.
      -->
		<!--
      <SettingValues>
        <CustomSettingValue>
          <UserfriendlyName>0.01</UserfriendlyName>
          <HexValue>0x3c23d70a</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.05</UserfriendlyName>
          <HexValue>0x3d4ccccd</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.1</UserfriendlyName>
          <HexValue>0x3dcccccd</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.2</UserfriendlyName>
          <HexValue>0x3e4ccccd</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.3</UserfriendlyName>
          <HexValue>0x3e99999a</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.4</UserfriendlyName>
          <HexValue>0x3ecccccd</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.5</UserfriendlyName>
          <HexValue>0x3f000000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.6</UserfriendlyName>
          <HexValue>0x3f19999a</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.7</UserfriendlyName>
          <HexValue>0x3f333333</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.8</UserfriendlyName>
          <HexValue>0x3f4ccccd</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0.9</UserfriendlyName>
          <HexValue>0x3f666666</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>1</UserfriendlyName>
          <HexValue>0x3f800000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>2</UserfriendlyName>
          <HexValue>0x40000000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>3</UserfriendlyName>
          <HexValue>0x40400000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>4</UserfriendlyName>
          <HexValue>0x40800000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>5</UserfriendlyName>
          <HexValue>0x40a00000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>6</UserfriendlyName>
          <HexValue>0x40c00000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>7</UserfriendlyName>
          <HexValue>0x40e00000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>8</UserfriendlyName>
          <HexValue>0x41000000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>9</UserfriendlyName>
          <HexValue>0x41100000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>10</UserfriendlyName>
          <HexValue>0x41200000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>20</UserfriendlyName>
          <HexValue>0x41a00000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>30</UserfriendlyName>
          <HexValue>0x41f00000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>40</UserfriendlyName>
          <HexValue>0x42200000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>50</UserfriendlyName>
          <HexValue>0x42480000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>60</UserfriendlyName>
          <HexValue>0x42700000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>70</UserfriendlyName>
          <HexValue>0x428c0000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>80</UserfriendlyName>
          <HexValue>0x42a00000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>90</UserfriendlyName>
          <HexValue>0x42b40000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>100</UserfriendlyName>
          <HexValue>0x42c80000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>200</UserfriendlyName>
          <HexValue>0x43480000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>300</UserfriendlyName>
          <HexValue>0x43960000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>400</UserfriendlyName>
          <HexValue>0x43c80000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>500</UserfriendlyName>
          <HexValue>0x43fa0000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>600</UserfriendlyName>
          <HexValue>0x44160000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>700</UserfriendlyName>
          <HexValue>0x442f0000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>800</UserfriendlyName>
          <HexValue>0x44480000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>900</UserfriendlyName>
          <HexValue>0x44610000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>1000</UserfriendlyName>
          <HexValue>0x447a0000</HexValue>
        </CustomSettingValue>
      </SettingValues>
    </CustomSetting>
    <CustomSetting>
      <UserfriendlyName>LaserXAdjust</UserfriendlyName>
      <HexSettingID>0x7057e831</HexSettingID>
      <GroupName>7 - Stereo</GroupName>
      <OverrideDefault>0x3f800000</OverrideDefault>
      <SettingValues>
        <CustomSettingValue>
          <UserfriendlyName>100% Left</UserfriendlyName>
          <HexValue>0x00000000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>95% Left</UserfriendlyName>
          <HexValue>0x3d4ccccd</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>90% Left</UserfriendlyName>
          <HexValue>0x3dcccccd</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>85% Left</UserfriendlyName>
          <HexValue>0x3e19999a</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>80% Left</UserfriendlyName>
          <HexValue>0x3e4ccccd</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>75% Left</UserfriendlyName>
          <HexValue>0x3e800000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>70% Left</UserfriendlyName>
          <HexValue>0x3e99999a</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>65% Left</UserfriendlyName>
          <HexValue>0x3eb33333</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>60% Left</UserfriendlyName>
          <HexValue>0x3ecccccd</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>55% Left</UserfriendlyName>
          <HexValue>0x3ee66666</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>50% Left</UserfriendlyName>
          <HexValue>0x3f000000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>45% Left</UserfriendlyName>
          <HexValue>0x3f0ccccd</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>40% Left</UserfriendlyName>
          <HexValue>0x3f19999a</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>35% Left</UserfriendlyName>
          <HexValue>0x3f266666</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>30% Left</UserfriendlyName>
          <HexValue>0x3f333333</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>25% Left</UserfriendlyName>
          <HexValue>0x3f400000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>20% Left</UserfriendlyName>
          <HexValue>0x3f4ccccd</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>15% Left</UserfriendlyName>
          <HexValue>0x3f59999a</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>10% Left</UserfriendlyName>
          <HexValue>0x3f666666</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>5% Left</UserfriendlyName>
          <HexValue>0x3f733333</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>Center</UserfriendlyName>
          <HexValue>0x3f800000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>5% Right</UserfriendlyName>
          <HexValue>0x3f866666</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>10% Right</UserfriendlyName>
          <HexValue>0x3f8ccccd</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>15% Right</UserfriendlyName>
          <HexValue>0x3f933333</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>20% Right</UserfriendlyName>
          <HexValue>0x3f99999a</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>25% Right</UserfriendlyName>
          <HexValue>0x3fa00000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>30% Right</UserfriendlyName>
          <HexValue>0x3fa66666</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>35% Right</UserfriendlyName>
          <HexValue>0x3faccccd</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>40% Right</UserfriendlyName>
          <HexValue>0x3fb33333</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>45% Right</UserfriendlyName>
          <HexValue>0x3fb9999a</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>50% Right</UserfriendlyName>
          <HexValue>0x3fc00000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>55% Right</UserfriendlyName>
          <HexValue>0x3fc66666</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>60% Right</UserfriendlyName>
          <HexValue>0x3fcccccd</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>65% Right</UserfriendlyName>
          <HexValue>0x3fd33333</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>70% Right</UserfriendlyName>
          <HexValue>0x3fd9999a</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>75% Right</UserfriendlyName>
          <HexValue>0x3fe00000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>80% Right</UserfriendlyName>
          <HexValue>0x3fe66666</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>85% Right</UserfriendlyName>
          <HexValue>0x3feccccd</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>90% Right</UserfriendlyName>
          <HexValue>0x3ff33333</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>95% Right</UserfriendlyName>
          <HexValue>0x3ff9999a</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>100% Right</UserfriendlyName>
          <HexValue>0x40000000</HexValue>
        </CustomSettingValue>
      </SettingValues>
    </CustomSetting>
    <CustomSetting>
      <UserfriendlyName>LaserYAdjust</UserfriendlyName>
      <HexSettingID>0x70225308</HexSettingID>
      <GroupName>7 - Stereo</GroupName>
      <OverrideDefault>0x3f800000</OverrideDefault>
      <SettingValues>
        <CustomSettingValue>
          <UserfriendlyName>100% Up</UserfriendlyName>
          <HexValue>0x00000000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>95% Up</UserfriendlyName>
          <HexValue>0x3d4ccccd</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>90% Up</UserfriendlyName>
          <HexValue>0x3dcccccd</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>85% Up</UserfriendlyName>
          <HexValue>0x3e19999a</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>80% Up</UserfriendlyName>
          <HexValue>0x3e4ccccd</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>75% Up</UserfriendlyName>
          <HexValue>0x3e800000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>70% Up</UserfriendlyName>
          <HexValue>0x3e99999a</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>65% Up</UserfriendlyName>
          <HexValue>0x3eb33333</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>60% Up</UserfriendlyName>
          <HexValue>0x3ecccccd</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>55% Up</UserfriendlyName>
          <HexValue>0x3ee66666</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>50% Up</UserfriendlyName>
          <HexValue>0x3f000000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>45% Up</UserfriendlyName>
          <HexValue>0x3f0ccccd</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>40% Up</UserfriendlyName>
          <HexValue>0x3f19999a</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>35% Up</UserfriendlyName>
          <HexValue>0x3f266666</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>30% Up</UserfriendlyName>
          <HexValue>0x3f333333</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>25% Up</UserfriendlyName>
          <HexValue>0x3f400000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>20% Up</UserfriendlyName>
          <HexValue>0x3f4ccccd</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>15% Up</UserfriendlyName>
          <HexValue>0x3f59999a</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>10% Up</UserfriendlyName>
          <HexValue>0x3f666666</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>5% Up</UserfriendlyName>
          <HexValue>0x3f733333</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>Center</UserfriendlyName>
          <HexValue>0x3f800000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>5% Down</UserfriendlyName>
          <HexValue>0x3f866666</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>10% Down</UserfriendlyName>
          <HexValue>0x3f8ccccd</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>15% Down</UserfriendlyName>
          <HexValue>0x3f933333</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>20% Down</UserfriendlyName>
          <HexValue>0x3f99999a</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>25% Down</UserfriendlyName>
          <HexValue>0x3fa00000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>30% Down</UserfriendlyName>
          <HexValue>0x3fa66666</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>35% Down</UserfriendlyName>
          <HexValue>0x3faccccd</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>40% Down</UserfriendlyName>
          <HexValue>0x3fb33333</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>45% Down</UserfriendlyName>
          <HexValue>0x3fb9999a</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>50% Down</UserfriendlyName>
          <HexValue>0x3fc00000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>55% Down</UserfriendlyName>
          <HexValue>0x3fc66666</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>60% Down</UserfriendlyName>
          <HexValue>0x3fcccccd</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>65% Down</UserfriendlyName>
          <HexValue>0x3fd33333</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>70% Down</UserfriendlyName>
          <HexValue>0x3fd9999a</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>75% Down</UserfriendlyName>
          <HexValue>0x3fe00000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>80% Down</UserfriendlyName>
          <HexValue>0x3fe66666</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>85% Down</UserfriendlyName>
          <HexValue>0x3feccccd</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>90% Down</UserfriendlyName>
          <HexValue>0x3ff33333</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>95% Down</UserfriendlyName>
          <HexValue>0x3ff9999a</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>100% Down</UserfriendlyName>
          <HexValue>0x40000000</HexValue>
        </CustomSettingValue>
      </SettingValues>
    </CustomSetting>
    <CustomSetting>
      <UserfriendlyName>StereoTextureEnable</UserfriendlyName>
      <HexSettingID>0x70EDB381</HexSettingID>
      <GroupName>7 - Stereo</GroupName>
      <OverrideDefault>0x00000023</OverrideDefault>
      <SettingValues>
        <CustomSettingValue>
          <UserfriendlyName>0x00000001 COMMON_STEREO_TEXTURE_ENABLED</UserfriendlyName>
          <HexValue>0x00000001</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0x00000002 SMALL_STEREO_TEXTURE_ENABLED</UserfriendlyName>
          <HexValue>0x00000002</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0x00000004 SQUARE_STEREO_TEXTURE_ENABLED</UserfriendlyName>
          <HexValue>0x00000004</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0x00000008 DISABLE_BB_SEPARATION_IF_STEREO_TEX</UserfriendlyName>
          <HexValue>0x00000008</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0x00000010 DISABLE_BB_SEPARATION_COMPLETELY</UserfriendlyName>
          <HexValue>0x00000010</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0x00000020 COMMON_STEREO_PLANERT_ENABLED</UserfriendlyName>
          <HexValue>0x00000020</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0x00000040 ORTHO_PROJECTION_DISABLED</UserfriendlyName>
          <HexValue>0x00000040</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0x00000080 ENABLE_SEPARATION_IF_ZBNULL</UserfriendlyName>
          <HexValue>0x00000080</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0x00000100 RESERVED_BY_DX10</UserfriendlyName>
          <HexValue>0x00000100</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0x00000200 DISABLE_TEX_SEPARATION_IF_STEREO_TEX</UserfriendlyName>
          <HexValue>0x00000200</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0x00000400 ENABLE_SEPARATION_IF_MONORT</UserfriendlyName>
          <HexValue>0x00000400</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0x00000800 DISABLE_FULLSCREEN_A8R8G8B8_STEREO_TEXTURES</UserfriendlyName>
          <HexValue>0x00000800</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0x00001000 DISABLE_SMALL_SQUARE_STEREO_TEXTURES</UserfriendlyName>
          <HexValue>0x00001000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0x00002000 ENABLE_ALL_STEREO_ZB_SIZES</UserfriendlyName>
          <HexValue>0x00002000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0x00004000 ENABLE_NULLFORMAT_PRIMSIZE_RT</UserfriendlyName>
          <HexValue>0x00004000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0x00008000 DISABLE_ALL_NULLFORMAT_RT</UserfriendlyName>
          <HexValue>0x00008000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0x00040000 ENABLE_VSSTEREO_SHADERS_WITHOUT_CONST</UserfriendlyName>
          <HexValue>0x00040000</HexValue>
        </CustomSettingValue>
      </SettingValues>
    </CustomSetting>
    <CustomSetting>
      <UserfriendlyName>StereoCutoff</UserfriendlyName>
      <HexSettingID>0x709A1DDF</HexSettingID>
      <GroupName>7 - Stereo</GroupName>
      <OverrideDefault>0x00000001</OverrideDefault>
      <SettingValues>
        <CustomSettingValue>
          <UserfriendlyName>0x00000002 Use StereoCutoffDepthNear</UserfriendlyName>
          <HexValue>0x00000002</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0x00000004 Use StereoCutoffDepthFar</UserfriendlyName>
          <HexValue>0x00000004</HexValue>
        </CustomSettingValue>
      </SettingValues>
    </CustomSetting>
    <CustomSetting>
      <UserfriendlyName>StereoCutoffDepthNear</UserfriendlyName>
      <HexSettingID>0x7050E011</HexSettingID>
      <GroupName>7 - Stereo</GroupName>
      <OverrideDefault>0x3F800000</OverrideDefault>
      -->
		<!-- this is an arbitrary float -->
		<!--
    </CustomSetting>
    <CustomSetting>
      <UserfriendlyName>StereoCutoffDepthFar</UserfriendlyName>
      <HexSettingID>0x70ADD220</HexSettingID>
      <GroupName>7 - Stereo</GroupName>
      <OverrideDefault>0x461C4000</OverrideDefault>
      -->
		<!-- this is an arbitrary float -->
		<!--
    </CustomSetting>
    <CustomSetting>
      <UserfriendlyName>StereoMemoEnabled</UserfriendlyName>
      <HexSettingID>0x707F4B45</HexSettingID>
      <GroupName>7 - Stereo</GroupName>
      <OverrideDefault>0x00000001</OverrideDefault>
      <SettingValues>
        <CustomSettingValue>
          <UserfriendlyName>Off</UserfriendlyName>
          <HexValue>0x00000000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>On</UserfriendlyName>
          <HexValue>0x00000001</HexValue>
        </CustomSettingValue>
      </SettingValues>
    </CustomSetting>
    <CustomSetting>
      <UserfriendlyName>StereoFlagsDX10</UserfriendlyName>
      <HexSettingID>0x702442FC</HexSettingID>
      <GroupName>7 - Stereo</GroupName>
      <SettingValues>
        <CustomSettingValue>
          <UserfriendlyName>0x00004000 STEREO_COMPUTE_ENABLE</UserfriendlyName>
          <HexValue>0x00004000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>0x00008000 STEREO_COMPUTE_SAME_RESOURCES_AS_GRAPHICS</UserfriendlyName>
          <HexValue>0x00008000</HexValue>
        </CustomSettingValue>
      </SettingValues>
    </CustomSetting>
    <CustomSetting>
      <UserfriendlyName>StereoUseMatrix</UserfriendlyName>
      <HexSettingID>0x70E34A78</HexSettingID>
      <GroupName>7 - Stereo</GroupName>
      <SettingValues>
        <CustomSettingValue>
          <UserfriendlyName>Only adjust vertex position</UserfriendlyName>
          <HexValue>0x00000000</HexValue>
        </CustomSettingValue>
        <CustomSettingValue>
          <UserfriendlyName>Correct many "halo" type rendering issues</UserfriendlyName>
          <HexValue>0x00000001</HexValue>
        </CustomSettingValue>
      </SettingValues>
    </CustomSetting>-->
	</Settings>
</CustomSettingNames>
"@
Set-Content -Path "$env:TEMP\Inspector\CustomSettingNames.xml" -Value $MultilineComment -Force
} else {
# skip
}
Clear-Host

    function show-menu {
	Clear-Host
    Write-Host "1. Force DLAA"
	Write-Host "2. Default"
	Write-Host "3. Inspector"
	              }
	show-menu
    while ($true) {
    $choice = Read-Host " "
    if ($choice -match '^[1-3]$') {
    switch ($choice) {
    1 {

Clear-Host
Write-Host "Force DLAA"
# create config for inspector
$MultilineComment = @"
<?xml version="1.0" encoding="utf-16"?>
<ArrayOfProfile>
  <Profile>
    <ProfileName>Base Profile</ProfileName>
    <Executeables />
    <Settings>
      <ProfileSetting>
        <SettingNameInfo> </SettingNameInfo>
        <SettingID>390467</SettingID>
        <SettingValue>2</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo />
        <SettingID>983226</SettingID>
        <SettingValue>1</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo />
        <SettingID>983227</SettingID>
        <SettingValue>1</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo />
        <SettingID>983295</SettingID>
        <SettingValue>AAAAQAAAAAA=</SettingValue>
        <ValueType>Binary</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Texture filtering - Negative LOD bias</SettingNameInfo>
        <SettingID>1686376</SettingID>
        <SettingValue>0</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Texture filtering - Trilinear optimization</SettingNameInfo>
        <SettingID>3066610</SettingID>
        <SettingValue>0</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Vertical Sync Tear Control</SettingNameInfo>
        <SettingID>5912412</SettingID>
        <SettingValue>2525368439</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Preferred refresh rate</SettingNameInfo>
        <SettingID>6600001</SettingID>
        <SettingValue>1</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Maximum pre-rendered frames</SettingNameInfo>
        <SettingID>8102046</SettingID>
        <SettingValue>1</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Texture filtering - Anisotropic filter optimization</SettingNameInfo>
        <SettingID>8703344</SettingID>
        <SettingValue>0</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Vertical Sync</SettingNameInfo>
        <SettingID>11041231</SettingID>
        <SettingValue>138504007</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Shader disk cache maximum size</SettingNameInfo>
        <SettingID>11306135</SettingID>
        <SettingValue>4294967295</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Texture filtering - Quality</SettingNameInfo>
        <SettingID>13510289</SettingID>
        <SettingValue>20</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Texture filtering - Anisotropic sample optimization</SettingNameInfo>
        <SettingID>15151633</SettingID>
        <SettingValue>1</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Display the VRR Indicator</SettingNameInfo>
        <SettingID>268604728</SettingID>
        <SettingValue>0</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Flag to control smooth AFR behavior</SettingNameInfo>
        <SettingID>270198627</SettingID>
        <SettingValue>0</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Anisotropic filtering setting</SettingNameInfo>
        <SettingID>270426537</SettingID>
        <SettingValue>1</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Power management mode</SettingNameInfo>
        <SettingID>274197361</SettingID>
        <SettingValue>1</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Antialiasing - Gamma correction</SettingNameInfo>
        <SettingID>276652957</SettingID>
        <SettingValue>0</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Antialiasing - Mode</SettingNameInfo>
        <SettingID>276757595</SettingID>
        <SettingValue>1</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>FRL Low Latency</SettingNameInfo>
        <SettingID>277041152</SettingID>
        <SettingValue>1</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Frame Rate Limiter</SettingNameInfo>
        <SettingID>277041154</SettingID>
        <SettingValue>0</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Frame Rate Limiter for NVCPL</SettingNameInfo>
        <SettingID>277041162</SettingID>
        <SettingValue>357</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Toggle the VRR global feature</SettingNameInfo>
        <SettingID>278196567</SettingID>
        <SettingValue>0</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>VRR requested state</SettingNameInfo>
        <SettingID>278196727</SettingID>
        <SettingValue>0</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>G-SYNC</SettingNameInfo>
        <SettingID>279476687</SettingID>
        <SettingValue>4</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Anisotropic filtering mode</SettingNameInfo>
        <SettingID>282245910</SettingID>
        <SettingValue>1</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Antialiasing - Setting</SettingNameInfo>
        <SettingID>282555346</SettingID>
        <SettingValue>0</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo />
        <SettingID>283385331</SettingID>
        <SettingValue>3</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo />
        <SettingID>283385332</SettingID>
        <SettingValue>1</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo />
        <SettingID>283385333</SettingID>
        <SettingValue>1065353216</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>CUDA Sysmem Fallback Policy</SettingNameInfo>
        <SettingID>283962569</SettingID>
        <SettingValue>1</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Enable G-SYNC globally</SettingNameInfo>
        <SettingID>294973784</SettingID>
        <SettingValue>0</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>OpenGL GDI compatibility</SettingNameInfo>
        <SettingID>544392611</SettingID>
        <SettingValue>0</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Threaded optimization</SettingNameInfo>
        <SettingID>549528094</SettingID>
        <SettingValue>1</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Preferred OpenGL GPU</SettingNameInfo>
        <SettingID>550564838</SettingID>
        <SettingValue>id,2.0:268410DE,00000100,GF - (400,2,161,24564) @ (0)</SettingValue>
        <ValueType>String</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Vulkan/OpenGL present method</SettingNameInfo>
        <SettingID>550932728</SettingID>
        <SettingValue>0</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo />
        <SettingID>1343646814</SettingID>
        <SettingValue>0</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
    </Settings>
  </Profile>
</ArrayOfProfile>
"@
Set-Content -Path "$env:TEMP\Inspector\ForceDLAA.nip" -Value $MultilineComment -Force
# import config
Start-Process -wait "$env:TEMP\Inspector\nvidiaProfileInspector.exe" -ArgumentList "$env:TEMP\Inspector\ForceDLAA.nip"
show-menu

      }
    2 {	

Clear-Host
Write-Host "Default"
# create config for inspector
$MultilineComment = @"
<?xml version="1.0" encoding="utf-16"?>
<ArrayOfProfile>
  <Profile>
    <ProfileName>Base Profile</ProfileName>
    <Executeables />
    <Settings>
      <ProfileSetting>
        <SettingNameInfo> </SettingNameInfo>
        <SettingID>390467</SettingID>
        <SettingValue>2</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo />
        <SettingID>983226</SettingID>
        <SettingValue>1</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo />
        <SettingID>983227</SettingID>
        <SettingValue>1</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo />
        <SettingID>983295</SettingID>
        <SettingValue>AAAAQAAAAAA=</SettingValue>
        <ValueType>Binary</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Texture filtering - Negative LOD bias</SettingNameInfo>
        <SettingID>1686376</SettingID>
        <SettingValue>0</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Texture filtering - Trilinear optimization</SettingNameInfo>
        <SettingID>3066610</SettingID>
        <SettingValue>0</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Vertical Sync Tear Control</SettingNameInfo>
        <SettingID>5912412</SettingID>
        <SettingValue>2525368439</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Preferred refresh rate</SettingNameInfo>
        <SettingID>6600001</SettingID>
        <SettingValue>1</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Maximum pre-rendered frames</SettingNameInfo>
        <SettingID>8102046</SettingID>
        <SettingValue>1</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Texture filtering - Anisotropic filter optimization</SettingNameInfo>
        <SettingID>8703344</SettingID>
        <SettingValue>0</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Vertical Sync</SettingNameInfo>
        <SettingID>11041231</SettingID>
        <SettingValue>138504007</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Shader disk cache maximum size</SettingNameInfo>
        <SettingID>11306135</SettingID>
        <SettingValue>4294967295</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Texture filtering - Quality</SettingNameInfo>
        <SettingID>13510289</SettingID>
        <SettingValue>20</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Texture filtering - Anisotropic sample optimization</SettingNameInfo>
        <SettingID>15151633</SettingID>
        <SettingValue>1</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Display the VRR Indicator</SettingNameInfo>
        <SettingID>268604728</SettingID>
        <SettingValue>0</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Flag to control smooth AFR behavior</SettingNameInfo>
        <SettingID>270198627</SettingID>
        <SettingValue>0</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Anisotropic filtering setting</SettingNameInfo>
        <SettingID>270426537</SettingID>
        <SettingValue>1</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Power management mode</SettingNameInfo>
        <SettingID>274197361</SettingID>
        <SettingValue>1</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Antialiasing - Gamma correction</SettingNameInfo>
        <SettingID>276652957</SettingID>
        <SettingValue>0</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Antialiasing - Mode</SettingNameInfo>
        <SettingID>276757595</SettingID>
        <SettingValue>1</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>FRL Low Latency</SettingNameInfo>
        <SettingID>277041152</SettingID>
        <SettingValue>1</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Frame Rate Limiter</SettingNameInfo>
        <SettingID>277041154</SettingID>
        <SettingValue>0</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Frame Rate Limiter for NVCPL</SettingNameInfo>
        <SettingID>277041162</SettingID>
        <SettingValue>357</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Toggle the VRR global feature</SettingNameInfo>
        <SettingID>278196567</SettingID>
        <SettingValue>0</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>VRR requested state</SettingNameInfo>
        <SettingID>278196727</SettingID>
        <SettingValue>0</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>G-SYNC</SettingNameInfo>
        <SettingID>279476687</SettingID>
        <SettingValue>4</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Anisotropic filtering mode</SettingNameInfo>
        <SettingID>282245910</SettingID>
        <SettingValue>1</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Antialiasing - Setting</SettingNameInfo>
        <SettingID>282555346</SettingID>
        <SettingValue>0</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>CUDA Sysmem Fallback Policy</SettingNameInfo>
        <SettingID>283962569</SettingID>
        <SettingValue>1</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Enable G-SYNC globally</SettingNameInfo>
        <SettingID>294973784</SettingID>
        <SettingValue>0</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>OpenGL GDI compatibility</SettingNameInfo>
        <SettingID>544392611</SettingID>
        <SettingValue>0</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Threaded optimization</SettingNameInfo>
        <SettingID>549528094</SettingID>
        <SettingValue>1</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Preferred OpenGL GPU</SettingNameInfo>
        <SettingID>550564838</SettingID>
        <SettingValue>id,2.0:268410DE,00000100,GF - (400,2,161,24564) @ (0)</SettingValue>
        <ValueType>String</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Vulkan/OpenGL present method</SettingNameInfo>
        <SettingID>550932728</SettingID>
        <SettingValue>0</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo />
        <SettingID>1343646814</SettingID>
        <SettingValue>0</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
    </Settings>
  </Profile>
</ArrayOfProfile>
"@
Set-Content -Path "$env:TEMP\Inspector\Default.nip" -Value $MultilineComment -Force
# import config
Start-Process -wait "$env:TEMP\Inspector\nvidiaProfileInspector.exe" -ArgumentList "$env:TEMP\Inspector\Default.nip"
show-menu

      }
    3 {

Clear-Host
Write-Host "Inspector"
# open inspector
Start-Process -wait "$env:TEMP\Inspector\nvidiaProfileInspector.exe"
show-menu

      }
    } } else { Write-Host "Invalid input. Please select a valid option (1-3)." } }