[CmdletBinding()]
param (

    [Parameter(Mandatory = $true)]
    [string] $EventLogName,

    [Parameter(Mandatory = $false)]
    [string] $OutputFilePath
)

if (-not $PSBoundParameters.ContainsKey('OutputFilePath'))
{
    $OutputFilePath = Join-Path -Path $PSScriptRoot -ChildPath ('{0}_{1}.tsv' -f $env:ComputerName, ($eventLogName -replace '/', '_'))
}


 Get-WinEvent -LogName $EventLogName |
    ForEach-Object -Process {

        $properties = ''
        $_.Properties |
            ForEach-Object -Process {
                $properties += "`n" + $_.Value
            }

        $keywordsDisplayNames = ''
        $_.KeywordsDisplayNames |
            ForEach-Object -Process {
                $keywordsDisplayNames += "`n" + $_.Value
            }

        [PSCustomObject]@{
            RecordId = $_.RecordId

            TimeCreated = $_.TimeCreated
            Level = $_.Level
            LevelDisplayName = $_.LevelDisplayName
            Opcode = $_.Opcode
            OpcodeDisplayName = $_.OpcodeDisplayName
            EventId = $_.Id
            Task = $_.Task
            TaskDisplayName = $_.TaskDisplayName
            Message = $_.Message

            UserId = $_.UserId
            ProcessId = $_.ProcessId
            ThreadId = $_.ThreadId
            MachineName = $_.MachineName

            Properties = $properties

            LogName = $_.LogName
            ContainerLog = $_.ContainerLog
            ProviderId = $_.ProviderId
            ProviderName = $_.ProviderName

            Keywords = $_.Keywords
            Qualifiers = $_.Qualifiers
            Version = $_.Version

            ActivityId = $_.ActivityId
            RelatedActivityId = $_.RelatedActivityId

            MatchedQueryIds = $_.MatchedQueryIds -join ','
            KeywordsDisplayNames = $keywordsDisplayNames

            #Bookmark = $_.Bookmark
        }
    } |
    Export-Csv -NoTypeInformation -Delimiter "`t" -Encoding UTF8 -LiteralPath $OutputFilePath
