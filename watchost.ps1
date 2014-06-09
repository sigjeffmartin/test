<#

    .SYNOPSIS 
        Continuously pings a host and alert if the status changes.
  

                .DESCRIPTION
        Used to monitor the connectivity of a host, indicate whether its online or offline, and alert when there is a status change.  The specified host will be pinged every 60 seconds, or at a specified interval.  Alerts can be made via a spoken voice message or a console beep when a status changes from online to offline, or vice versa.  If the host status is off, the text output will be in red.


                .PARAMETER hostname
        Specifies the name or IP address of the host to watch.
  

                .PARAMETER sleepTime
        Specifies the number of seconds to sleep between pings.  "60" is the default.
  

                .PARAMETER offExpected
        Switches the color of the text output so that when the host status is on, the text output will be in red.

		.PARAMETER voice
        Enable a voice message when there is a host status change.

    

                .PARAMETER beep

        Enable a console beep when there is a host status change.

    

                .INPUTS

        None.

    

                .OUTPUTS

        Writes the host status to the console as a string, with a timestamp.

                                Audible console beep or spoken text.

#>

                

function Watch-HostConnectivity {

                param(

                                [string]$hostname=$(throw 'Host not specified.'),

                                [string]$sleepTime=60,

                                [switch]$offExpected,

                                [switch]$voice,

                                [switch]$beep

                )  

                $ping = new-object System.Net.NetworkInformation.Ping  

                $talker = new-object -com SAPI.SpVoice  

    

                if (!$offExpected) {

                                $lastResult = "Success"

                } else {

                                $lastResult = "Failure"

                }

                

                while (1 -eq 1) {

                                $now = Get-Date

                                $result = $ping.Send($hostname)

                

                                if($result.Status -eq "Success") {  

                                                if ($offExpected) {

                                                                Write-Host "$hostname is online.       " -nonewline -Foreground red;

                                                } else {

                                                                Write-Host "$hostname is online.       " -nonewline 

                                                }

                                                

                                                Write-Host $now

                                                

                                                if ($lastResult -ne "Success") {

                                                                if ($voice) { $talker.Speak("$hostname is now online.") }

                                                                if ($beep)  { $([char]7) }

                                                }

                                } else {

                                                if ($offExpected) {

                                                                Write-Host "$hostname is offline.       " -nonewline

                                                } else {

                                                                Write-Host "$hostname is offline.       " -nonewline -Foreground red;

                                                }

                                                

                                                Write-Host $now

                                                

                                                if ($lastResult -eq "Success") {

                                                                if ($voice) { $talker.Speak("$hostname is now offline.") }

                                                                if ($beep)  { $([char]7) }

                                                }

                                }

                                

                                $lastResult = $result.Status

                                Start-Sleep -s $sleepTime

                }

}
