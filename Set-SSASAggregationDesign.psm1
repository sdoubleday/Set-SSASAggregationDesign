
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


[CmdletBinding()]
 param(
 [Parameter(Position=0,mandatory=$true)]
 [string] $ssasInstance,
 
 [Parameter(Position=1,mandatory=$true)]
 [string] $ssasdb,
 
 [Parameter(Position=2)]
 [switch] $Fix)
 
 




}<#END Function Set-SSASAggregationDesign#>
