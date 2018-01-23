
CLASS FakePartition {
    [PSCustomObject]$Parent
    [String]$ID
    [String]$Name
    [String]$AggregationDesignID
    [PSCustomObject]$AggregationDesign
    
    FakePartition([String]$ID,[String]$Name,[String]$AggregationDesignID,[Int]$AggregationDesignAggregationsCount){
        $PartitionParentAggregationDesigns = @()
        $PartitionParentAggregationDesigns += [PSCustomObject]@{Name='FakeAggregationDesignName1';ID='7'}
        $PartitionParentAggregationDesigns += [PSCustomObject]@{Name='FakeAggregationDesignName2';ID='8'}

        $Aggregations = [PSCustomObject]@{Count=$AggregationDesignAggregationsCount}

        $this.AggregationDesign = [PSCustomObject]@{Aggregations=$Aggregations}

        $this.Parent = [PSCustomObject]@{AggregationDesigns=$PartitionParentAggregationDesigns}

        $this.ID = $ID
        $this.Name = $Name
        $this.AggregationDesignID = $AggregationDesignID
    }<#End Constructor#>

    <#Process is a reserved word. Maybe there's a way to add it as a method, but just wrapping it using Add-member in the calling code works for my Pester Testing purposes.#>
    [Void] ProcessBob($ProcessType) {
        Start-sleep -Seconds 1 
        Write-Verbose -Verbose "Running Fake .Process($ProcessType)" } <#End Method Process($ProcessType)#>

    [Void] Update() {$this.AggregationDesign.Aggregations.Count += 1}

}<#End Class FakePartition#>

FUNCTION Fake-SSASServer {
    [CmdletBinding()]
    PARAM(
        [Parameter(Position=0,mandatory=$true)]
        [string] $ssasInstance
    )

    'Ginning up something that pretends to be a SSAS Server for testing purposes...' | Write-Verbose -Verbose

    $Partitions = @()
    $Partitions += Add-Member -PassThru -InputObject $( [FakePartition]::New(1,'PartitionName1','ADID1',1) ) -MemberType ScriptMethod -Name 'Process' -Value {Param([String]$ProcessType) $this.ProcessBob($ProcessType)}
    $Partitions += Add-Member -PassThru -InputObject $( [FakePartition]::New(2,'PartitionName2','ADID1',1) ) -MemberType ScriptMethod -Name 'Process' -Value {Param([String]$ProcessType) $this.ProcessBob($ProcessType)}
    $Partitions += Add-Member -PassThru -InputObject $( [FakePartition]::New(3,'PartitionName3','',0) ) -MemberType ScriptMethod -Name 'Process' -Value {Param([String]$ProcessType) $this.ProcessBob($ProcessType)}
    $Partitions += Add-Member -PassThru -InputObject $( [FakePartition]::New(4,'PartitionName4','',0) ) -MemberType ScriptMethod -Name 'Process' -Value {Param([String]$ProcessType) $this.ProcessBob($ProcessType)}
    
    
    $MeasureGroups = @()
    $MeasureGroups += [PSCustomObject]@{Name='MG1';Partitions=$Partitions}
    $MeasureGroups += [PSCustomObject]@{Name='MG2';Partitions=$Partitions}
    $MeasureGroups += [PSCustomObject]@{Name='MG3';Partitions=$Partitions}

    $Cubes = @()
    $Cubes += [PSCustomObject]@{Name='Cube1';MeasureGroups=$MeasureGroups}
    $Cubes += [PSCustomObject]@{Name='Cube2';MeasureGroups=$MeasureGroups}
    $Cubes += [PSCustomObject]@{Name='Cube3';MeasureGroups=$MeasureGroups}

    $Databases = @()
    $Databases += [PSCustomObject]@{Name='Db1';Cubes=$Cubes}
    $Databases += [PSCustomObject]@{Name='Db2';Cubes=$Cubes}
    $Databases += [PSCustomObject]@{Name='Db3';Cubes=$Cubes}

    $SSASServer = [PSCustomObject]@{Name='ImAServerISwear';Databases=$Databases}

    Return $SSASServer

}<#End FUNCTION Fake-SSASServer#>


<#These are easier to mock than having them in the main function.#>

FUNCTION Get-SSASServer {
    [CmdletBinding()]
    PARAM(
        [Parameter(Position=0,mandatory=$true)]
        [string] $ssasInstance
    )
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.AnalysisServices")
$server = New-Object Microsoft.AnalysisServices.Server
$server.connect($ssasInstance)
} <#End FUNCTION Get-SSASServer#>

FUNCTION Get-SSASPartitionAggregationsProcessedCount {
PARAM($ssasInstance,$dbase,$cube,$mg,$partition)

[void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.AnalysisServices.AdomdClient")
 $con = new-object Microsoft.AnalysisServices.AdomdClient.AdomdConnection("datasource=$ssasInstance")
 $con.Open()
 $MDX="SELECT * FROM SystemRestrictSchema(`$system.discover_partition_stat, DATABASE_NAME = '$dbase',CUBE_NAME = '$cube', MEASURE_GROUP_NAME = '$mg', PARTITION_NAME = '$partition')"
 $command = new-object Microsoft.AnalysisServices.AdomdClient.AdomdCommand($MDX, $con) 
 $dataAdapter = new-object Microsoft.AnalysisServices.AdomdClient.AdomdDataAdapter($command)
 $ds = new-object System.Data.DataSet
 $dataAdapter.Fill($ds) > $null
 $con.Close();
 $dataExtract = $ds.tables[0].select("AGGREGATION_NAME IS NOT NULL")
 
 Return $DataExtract.Count
 } <#END Get-SSASPartitionAggregationsProcessedCount#>

FUNCTION Set-SSASPartitionAggregationDesignAndProcessIndex {
PARAM([Parameter(Mandatory=$true)]$partition,[Parameter(Mandatory=$true)][INT]$processedAggCount)

 $partition.AggregationDesignID = $partition.Parent.AggregationDesigns[$partition.Parent.AggregationDesigns.Count-1].ID
 $partition.Update()
 $totalAggCount = $partition.AggregationDesign.Aggregations.Count

    <#sdoubleday moved this into if ( $partition.Parent.AggregationDesigns.Count -gt 0) for easier use of whatif#>
     if ($totalAggCount -ne $processedAggCount)
     {
  
         "$($partition.Name) aggregation design $($partition.AggregationDesignID) has $processedAggCount of $totalAggCount processed "
            if ( $partition.Parent.AggregationDesigns.Count -gt 0)
            {
                $date1=get-date
                "$($partition.Name) processing..."
                $partition.Process("ProcessIndexes")
                $date2=get-date
                "$($partition.Name) done. Processing took " + ($date2-$date1).Hours + " Hours, " + ($date2-$date1).Minutes + " Mins, " + ($date2-$date1).Seconds + " Secs "
            }<#End if ( $partition.Parent.AggregationDesigns.Count -gt 0)#>
     }<#END IF ($totalAggCount -ne $processedAggCount)#>
 
 }<#END FUNCTION Set-SSASPartitionAggregationDesignAndProcessIndex#>


function Set-SSASAggregationDesign {
<#
.SYNOPSIS
Script to review SSAS partitions' assigned aggregations and optionally 
assign aggregations to partitions that have none.

.DESCRIPTION
Initial version an exact copy of Richie Lee's script (see links, below).

.LINK
https://redphoenix.me/2014/11/11/setting-aggregation-designs-on-ssas-partitions-part-two/
#>


[CmdletBinding(DefaultParameterSetName ="Default",SupportsShouldProcess=$true <#Enables -Confirm and -Whatif#>)]
                 
 param(
 [Parameter(Position=0,mandatory=$true)]
 [string] $ssasInstance,
 
 [Parameter(Position=1,mandatory=$true)]
 [string] $ssasdb,
 
 [Parameter(Position=2)]
 [switch] $Fix,
 
 [Parameter(mandatory=$true,ParameterSetName='MeasureGroup')]
 [Parameter(mandatory=$true,ParameterSetName='Partition')]
 [Parameter(mandatory=$true,ParameterSetName='Cube')]
 [String]$CubeName,
 
 [Parameter(mandatory=$true,ParameterSetName='MeasureGroup')]
 [Parameter(mandatory=$true,ParameterSetName='Partition')]
 [Parameter(mandatory=$true)]
 [String]$MeasureGroupName,
 
 [Parameter(mandatory=$true,ParameterSetName='Partition')]
 [Parameter(mandatory=$true)]
 [String]$PartitionName

 )
 
 
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.AnalysisServices")
$server = Get-SSASServer -ssasInstance $ssasInstance
$database=$server.databases
$dbase=$database[$ssasdb]
 
$Cubes=New-object Microsoft.AnalysisServices.Cube

IF ( $PSCmdlet.ParameterSetName -in 'Cube','MeasureGroup','Partition' ) {
    $Cubes=$dbase.cubes | Where-Object {$_.Name -like $CubeName}
}<#END IF ( $PSCmdlet.ParameterSetName -in 'Cube','MeasureGroup','Partition' )#>
ELSE {
    $Cubes=$dbase.cubes
}<#END ELSE ( $PSCmdlet.ParameterSetName -in 'Cube','MeasureGroup','Partition' )#>

foreach ($cube in $cubes)
 {
     $Cube|select name,state,lastprocessed 

     IF ( $PSCmdlet.ParameterSetName -in 'MeasureGroup','Partition' ) {
        $MeasureGroups = $Cubes.MeasureGroups | Where-Object {$_.Name -like $MeasureGroupName}
     }<#END IF ( $PSCmdlet.ParameterSetName -in 'MeasureGroup','Partition' )#>
     ELSE {
        $MeasureGroups = $Cubes.MeasureGroups
     }<#END ELSE ( $PSCmdlet.ParameterSetName -in 'MeasureGroup','Partition' )#>
  

     foreach ($mg in $MeasureGroups)
     {

         IF ( $PSCmdlet.ParameterSetName -in 'Partition' ) {
            $Partitions = $MeasureGroups.Partitions | Where-Object {$_.Name -like $PartitionName}
         }<#END IF ( $PSCmdlet.ParameterSetName -in 'Partition' )#>
         ELSE {
            $Partitions = $MeasureGroups.Partitions
         }<#END ELSE ( $PSCmdlet.ParameterSetName -in 'Partition' )#>
 

         foreach ($partition in $Partitions)
         {
             Write-Verbose -Verbose "Partition Name: $($partition.Name), Partition Object Type: $($partition.GetType().Name)"
             Write-Debug "Partition Name: $($partition.Name), Partition Object Type: $($partition.GetType().Name)"
 
             $processedAggCount = Get-SSASPartitionAggregationsProcessedCount -ssasInstance $ssasInstance -dbase $dbase -cube $cube -mg $mg -partition $partition
 
             $totalAggCount = $partition.AggregationDesign.Aggregations.Count
             if($partition.AggregationDesignID.Length -lt 1)
             {
                "$($partition.Name) does not have an aggregation design applied"
                 if ($fix.IsPresent)
                 {
                     if ( $partition.Parent.AggregationDesigns.Count -gt 0)
                     {
                         <#sdoubleday More Information in the agg assignment message#>
                         $message = "$($partition.Name) assigning and ProcessIndex aggregation design ID $($partition.Parent.AggregationDesigns[$partition.Parent.AggregationDesigns.Count-1].ID), Name $($partition.Parent.AggregationDesigns[$partition.Parent.AggregationDesigns.Count-1].Name)"
                         If ($PSCmdlet.ShouldProcess($message)) { 
    
                            Set-SSASPartitionAggregationDesignAndProcessIndex -partition $partition -processedAggCount $processedAggCount

                         } <#End ShouldProcess#>
                     } <#END if ( $partition.Parent.AggregationDesigns.Count -gt 0)#>

                     else {"$($partition.Name) does not have a aggregation design created for it. Ignoring..."} <#End Else ( $partition.Parent.AggregationDesigns.Count -gt 0) #>

                 } <#END if ($fix.IsPresent)#>

             } <#END if($partition.AggregationDesignID.Length -lt 1)#>
         } <#END foreach ($partition in $mg.Partitions) #>
     } <#END foreach ($mg in $cube.MeasureGroups)#>
 } <#END foreach ($cube in $cubes)#>

}<#END Function Set-SSASAggregationDesign#>
