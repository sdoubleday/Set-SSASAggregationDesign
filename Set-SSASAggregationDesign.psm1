



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
 
 
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.AnalysisServices")
$server = New-Object Microsoft.AnalysisServices.Server
$server.connect($ssasInstance)
$database=$server.databases
$dbase=$database[$ssasdb]
 
$Cubes=New-object Microsoft.AnalysisServices.Cube
$Cubes=$dbase.cubes
 
foreach ($cube in $cubes)
 {
 $Cube|select name,state,lastprocessed 
 foreach ($mg in $cube.MeasureGroups)
 {
 foreach ($partition in $mg.Partitions)
 {
 $totalAggCount = $partition.AggregationDesign.Aggregations.Count
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
 $processedAggCount = $DataExtract.Count
 $totalAggCount = $partition.AggregationDesign.Aggregations.Count
 if($partition.AggregationDesignID.Length -lt 1)
 {
 "$($partition.Name) does not have an aggregation design applied"
 if ($fix.IsPresent)
 {
 if ( $partition.Parent.AggregationDesigns.Count -gt 0)
 {
 "$($partition.Name) assigning aggregation design $($partition.Parent.AggregationDesigns[$partition.Parent.AggregationDesigns.Count-1].ID)"
 $partition.AggregationDesignID = $partition.Parent.AggregationDesigns[$partition.Parent.AggregationDesigns.Count-1].ID
 $partition.Update()
 $totalAggCount = $partition.AggregationDesign.Aggregations.Count
 }
 else
 {"$($partition.Name) does not have a aggregation design created for it. Ignoring..."}
  
 }
 if ($totalAggCount -ne $processedAggCount)
 {
  
 "$($partition.Name) aggregation design $($partition.AggregationDesignID) has $processedAggCount of $totalAggCount processed "
 if($Fix.IsPresent)
 {
 if ( $partition.Parent.AggregationDesigns.Count -gt 0)
 {
 $date1=get-date
 "$($partition.Name) processing..."
 $partition.Process("ProcessIndexes")
 $date2=get-date
 "$($partition.Name) done. Processing took " + ($date2-$date1).Hours + " Hours, " + ($date2-$date1).Minutes + " Mins, " + ($date2-$date1).Seconds + " Secs "
 }
 }
 }
 } 
 }
 }
 }





}<#END Function Set-SSASAggregationDesign#>
