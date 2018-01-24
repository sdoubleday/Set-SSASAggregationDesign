<#SDS Modified Pester Test file header to handle modules.#>
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = ( (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.' ) -replace '.ps1', '.psd1'
$scriptBody = "using module $here\$sut"
$script = [ScriptBlock]::Create($scriptBody)
. $script


Describe "CLASS FakePartition" {
    
    IT "[FakePartition]::New(1,'PartitionName1','ADID1',1).GetType().Name | Should Be 'FakePartition'" {
        [FakePartition]::New(1,'PartitionName1','ADID1',1).GetType().Name | Should Be 'FakePartition' }

    IT "[FakePartition]::New(1,'PartitionName1','ADID1',1).ID | SHOULD BE '1'" {
        [FakePartition]::New(1,'PartitionName1','ADID1',1).ID | SHOULD BE '1' }

    IT "[FakePartition]::New(1,'PartitionName1','ADID1',1).Name | SHOULD BE 'PartitionName1'" {
        [FakePartition]::New(1,'PartitionName1','ADID1',1).Name | SHOULD BE 'PartitionName1' }

    IT "[FakePartition]::New(1,'PartitionName1','ADID1',1).AggregationDesignID | Should Be 'ADID1'" {
        [FakePartition]::New(1,'PartitionName1','ADID1',1).AggregationDesignID | Should Be 'ADID1' }

    IT "[FakePartition]::New(1,'PartitionName1','ADID1',1).AggregationDesign.Aggregations.Count | Should Be '1'" {
        [FakePartition]::New(1,'PartitionName1','ADID1',1).AggregationDesign.Aggregations.Count | Should Be '1' }

    IT "[FakePartition]::New(3,'PartitionName3','',0).GetType().Name | Should Be 'FakePartition'" {
        [FakePartition]::New(3,'PartitionName3','',0).GetType().Name | Should Be 'FakePartition' }

    IT "[FakePartition]::New(3,'PartitionName3','',0).ID | SHOULD BE '3'" {
        [FakePartition]::New(3,'PartitionName3','',0).ID | SHOULD BE '3' }

    IT "[FakePartition]::New(3,'PartitionName3','',0).Name | SHOULD BE 'PartitionName3'" {
        [FakePartition]::New(3,'PartitionName3','',0).Name | SHOULD BE 'PartitionName3' }

    IT "[FakePartition]::New(3,'PartitionName3','',0).AggregationDesignID | Should Be ''" {
        [FakePartition]::New(3,'PartitionName3','',0).AggregationDesignID | Should Be '' }

    IT "[FakePartition]::New(3,'PartitionName3','',0).AggregationDesign.Aggregations.Count | Should Be '0'" {
        [FakePartition]::New(3,'PartitionName3','',0).AggregationDesign.Aggregations.Count | Should Be '0' }

    IT "Adding a ScriptMethod named Process to a FakePartition that just calls ProcessBob does not produce an error." {
        $result = TRY { ( Add-Member -PassThru -InputObject $( [FakePartition]::New(3,'PartitionName3','',0) ) -MemberType ScriptMethod -Name 'Process' -Value {Param([String]$ProcessType) $this.ProcessBob($ProcessType)} ).Process('ProcessIndex') } catch {$error[0].Exception.GetBaseException().Message.ToString()}
        $result | SHOULD BE $NULL }

    IT "`$n =[FakePartition]::New(3,'PartitionName1','',0); `$n.Update(); `$n.AggregationDesign.Aggregations.Count | SHOULD BE '1'" {
        $n =[FakePartition]::New(3,'PartitionName1','',0); $n.Update(); $n.AggregationDesign.Aggregations.Count | SHOULD BE '1' }

    IT "[FakePartition]::New(1,'PartitionName1','ADID1',1).Parent.AggregationDesigns.Count | SHOULD BE '2'" {
        [FakePartition]::New(1,'PartitionName1','ADID1',1).Parent.AggregationDesigns.Count | SHOULD BE '2' }

    IT "[FakePartition]::New(1,'PartitionName1','ADID1',1).Parent.AggregationDesigns[0].Name | SHOULD BE 'FakeAggregationDesignName1'" {
        [FakePartition]::New(1,'PartitionName1','ADID1',1).Parent.AggregationDesigns[0].Name | SHOULD BE 'FakeAggregationDesignName1' }

    IT "[FakePartition]::New(1,'PartitionName1','ADID1',1).Parent.AggregationDesigns[0].ID | SHOULD BE '7'" {
        [FakePartition]::New(1,'PartitionName1','ADID1',1).Parent.AggregationDesigns[0].ID | SHOULD BE '7' }

    IT "[FakePartition]::New(1,'PartitionName1','ADID1',1).Parent.AggregationDesigns[1].Name | SHOULD BE 'FakeAggregationDesignName2'" {
        [FakePartition]::New(1,'PartitionName1','ADID1',1).Parent.AggregationDesigns[1].Name | SHOULD BE 'FakeAggregationDesignName2' }

    IT "[FakePartition]::New(1,'PartitionName1','ADID1',1).Parent.AggregationDesigns[1].ID | SHOULD BE '8'" {
        [FakePartition]::New(1,'PartitionName1','ADID1',1).Parent.AggregationDesigns[1].ID | SHOULD BE '8' }


} <#END Describe "CLASS FakePartition"#>

DESCRIBE "Fake-SSASServer" {
    IT "(Fake-SSASServer -SSASInstance 'Whatever').Name | SHOULD BE 'ImAServerISwear'" {
        (Fake-SSASServer -SSASInstance 'Whatever').Name | SHOULD BE 'ImAServerISwear' }

    IT "(Fake-SSASServer -SSASInstance 'Whatever').Databases.Count | SHOULD BE '3'" {
        (Fake-SSASServer -SSASInstance 'Whatever').Databases.Count | SHOULD BE '3' }

    IT "(Fake-SSASServer -SSASInstance 'Whatever').Databases[0].Name | SHOULD BE 'Db1'" {
        (Fake-SSASServer -SSASInstance 'Whatever').Databases[0].Name | SHOULD BE 'Db1' }

    IT "(Fake-SSASServer -SSASInstance 'Whatever').Databases[1].Name | SHOULD BE 'Db2'" {
        (Fake-SSASServer -SSASInstance 'Whatever').Databases[1].Name | SHOULD BE 'Db2' }

    IT "(Fake-SSASServer -SSASInstance 'Whatever').Databases[1].Cubes[0].Name | SHOULD BE 'Cube1'" {
        (Fake-SSASServer -SSASInstance 'Whatever').Databases[1].Cubes[0].Name | SHOULD BE 'Cube1' }

    IT "(Fake-SSASServer -SSASInstance 'Whatever').Databases[1].Cubes.Count | SHOULD BE '3'" {
        (Fake-SSASServer -SSASInstance 'Whatever').Databases[1].Cubes.Count | SHOULD BE '3' }

    IT "(Fake-SSASServer -SSASInstance 'Whatever').Databases[1].Cubes[2].Name | SHOULD BE 'Cube3'" {
        (Fake-SSASServer -SSASInstance 'Whatever').Databases[1].Cubes[2].Name | SHOULD BE 'Cube3' }

    IT "(Fake-SSASServer -SSASInstance 'Whatever').Databases[1].Cubes[2].MeasureGroups.Count | SHOULD BE '3'" {
        (Fake-SSASServer -SSASInstance 'Whatever').Databases[1].Cubes[2].MeasureGroups.Count | SHOULD BE '3' }

    IT "(Fake-SSASServer -SSASInstance 'Whatever').Databases[1].Cubes[2].MeasureGroups[1].Name | SHOULD BE 'Mg2'" {
        (Fake-SSASServer -SSASInstance 'Whatever').Databases[1].Cubes[2].MeasureGroups[1].Name | SHOULD BE 'Mg2' }

    IT "(Fake-SSASServer -SSASInstance 'Whatever').Databases[1].Cubes[2].MeasureGroups[1].Partitions.Count | SHOULD BE '4'" {
        (Fake-SSASServer -SSASInstance 'Whatever').Databases[1].Cubes[2].MeasureGroups[1].Partitions.Count | SHOULD BE '4' }

    IT "(Fake-SSASServer -SSASInstance 'Whatever').Databases[1].Cubes[2].MeasureGroups[1].Partitions[0].GetType().Name | SHOULD BE 'FakePartition'" {
        (Fake-SSASServer -SSASInstance 'Whatever').Databases[1].Cubes[2].MeasureGroups[1].Partitions[0].GetType().Name | SHOULD BE 'FakePartition' }

} <#END DESCRIBE "Fake-SSASServer"#>

Describe "Set-SSASAggregationDesign" {
    BEFOREALL{
        MOCK -CommandName Get-SSASServer -ModuleName Set-SSASAggregationDesign -MockWith {Fake-SSASServer -SSASInstance 'Whatever'} -Verifiable
        MOCK -CommandName Get-SSASPartitionAggregationsProcessedCount -ModuleName Set-SSASAggregationDesign -MockWith {1} -Verifiable
        MOCK -CommandName Set-SSASPartitionAggregationDesignAndProcessIndex -ModuleName Set-SSASAggregationDesign -MockWith {} -Verifiable
    }

    It "Set-SSASAggregationDesign on one partition WITH aggregations: Assert-MockCalled -CommandName Get-SSASServer -ModuleName Set-SSASAggregationDesign -Scope It -Times 1 -Exactly" { 
        Set-SSASAggregationDesign -SSASInstance 'ImNotAServer' -ssasDb 'Db3' -CubeName 'Cube2' -MeasureGroupName 'Mg1' -PartitionName 'PartitionName2' 
        Assert-MockCalled -CommandName Get-SSASServer -ModuleName Set-SSASAggregationDesign -Scope It -Times 1 -Exactly
    }

    It "Set-SSASAggregationDesign on one partition WITHOUT aggregations: Assert-MockCalled -CommandName Get-SSASServer -ModuleName Set-SSASAggregationDesign -Scope It -Times 1 -Exactly" { 
        Set-SSASAggregationDesign -SSASInstance 'ImNotAServer' -ssasDb 'Db3' -CubeName 'Cube2' -MeasureGroupName 'Mg1' -PartitionName 'PartitionName2' 
        Assert-MockCalled -CommandName Get-SSASServer -ModuleName Set-SSASAggregationDesign -Scope It -Times 1 -Exactly
    }

    It "Set-SSASAggregationDesign on one partition WITH aggregations: Assert-MockCalled -CommandName Get-SSASPartitionAggregationsProcessedCount -ModuleName Set-SSASAggregationDesign -Scope It -Times 1 -Exactly" { 
        $result = Try {Set-SSASAggregationDesign -Verbose -SSASInstance 'ImNotAServer' -ssasDb 'Db3' -CubeName 'Cube2' -MeasureGroupName 'Mg1' -PartitionName 'PartitionName3' } catch {$error[0].Exception.GetBaseException().Message.ToString()}
        $result | Write-Verbose -Verbose
        Assert-MockCalled -CommandName Get-SSASPartitionAggregationsProcessedCount -ModuleName Set-SSASAggregationDesign -Scope It -Times 1 -Exactly
    }

    It "Set-SSASAggregationDesign on one partition WITHOUT aggregations: Assert-MockCalled -CommandName Get-SSASPartitionAggregationsProcessedCount -ModuleName Set-SSASAggregationDesign -Scope It -Times 1 -Exactly" { 
        Set-SSASAggregationDesign -SSASInstance 'ImNotAServer' -ssasDb 'Db3' -CubeName 'Cube2' -MeasureGroupName 'Mg1' -PartitionName 'PartitionName3' 
        Assert-MockCalled -CommandName Get-SSASPartitionAggregationsProcessedCount -ModuleName Set-SSASAggregationDesign -Scope It -Times 1 -Exactly
    }

    It "Set-SSASAggregationDesign on a MeasureGroup of 4 partitions, half WITHOUT aggregations: Assert-MockCalled -CommandName Get-SSASPartitionAggregationsProcessedCount -ModuleName Set-SSASAggregationDesign -Scope It -Times 4 -Exactly" { 
        Set-SSASAggregationDesign -SSASInstance 'ImNotAServer' -ssasDb 'Db3' -CubeName 'Cube2' -MeasureGroupName 'Mg1'
        Assert-MockCalled -CommandName Get-SSASPartitionAggregationsProcessedCount -ModuleName Set-SSASAggregationDesign -Scope It -Times 4 -Exactly
    }

    It "Set-SSASAggregationDesign on a MeasureGroup of 4 partitions, half WITHOUT aggregations WITHOUT -Fix: Assert-MockCalled -CommandName Set-SSASPartitionAggregationDesignAndProcessIndex -ModuleName Set-SSASAggregationDesign -Scope It -Times 0 -Exactly" { 
        Set-SSASAggregationDesign -SSASInstance 'ImNotAServer' -ssasDb 'Db3' -CubeName 'Cube2' -MeasureGroupName 'Mg1'
        Assert-MockCalled -CommandName Set-SSASPartitionAggregationDesignAndProcessIndex -ModuleName Set-SSASAggregationDesign -Scope It -Times 0 -Exactly
    }
    
    It "Set-SSASAggregationDesign on a MeasureGroup of 4 partitions, half WITHOUT aggregations WITH -Fix: Assert-MockCalled -CommandName Set-SSASPartitionAggregationDesignAndProcessIndex -ModuleName Set-SSASAggregationDesign -Scope It -Times 2 -Exactly" { 
        Set-SSASAggregationDesign -SSASInstance 'ImNotAServer' -ssasDb 'Db3' -CubeName 'Cube2' -MeasureGroupName 'Mg1' -Fix
        Assert-MockCalled -CommandName Set-SSASPartitionAggregationDesignAndProcessIndex -ModuleName Set-SSASAggregationDesign -Scope It -Times 2 -Exactly
    }

}<#End Describe "Set-SSASAggregationDesign" #>


Describe "Set-SSASAggregationDesign - testing -DoNotProcess" {
    BEFOREALL{
        MOCK -CommandName Get-SSASServer -ModuleName Set-SSASAggregationDesign -MockWith {Fake-SSASServer -SSASInstance 'Whatever'} -Verifiable
        MOCK -CommandName Get-SSASPartitionAggregationsProcessedCount -ModuleName Set-SSASAggregationDesign -MockWith {0} -Verifiable
        MOCK -CommandName Process-SSASIndex -ModuleName Set-SSASAggregationDesign -MockWith {} -Verifiable
    }

    It "Set-SSASAggregationDesign on a MeasureGroup of 4 partitions, half WITHOUT aggregations WITH -Fix -DoNotProcessIndex: Assert-MockCalled -CommandName Process-SSASIndex -ModuleName Set-SSASAggregationDesign -Scope It -Times 0 -Exactly" { 
        Set-SSASAggregationDesign -SSASInstance 'ImNotAServer' -ssasDb 'Db3' -CubeName 'Cube2' -MeasureGroupName 'Mg1' -Fix -DoNotProcessIndex
        Assert-MockCalled -CommandName Process-SSASIndex -ModuleName Set-SSASAggregationDesign -Scope It -Times 0 -Exactly
    }

    It "Set-SSASAggregationDesign on a MeasureGroup of 4 partitions, half WITHOUT aggregations WITH -Fix (and not -DoNotProcessIndex): Assert-MockCalled -CommandName Process-SSASIndex -ModuleName Set-SSASAggregationDesign -Scope It -Times 2 -Exactly" { 
        Set-SSASAggregationDesign -SSASInstance 'ImNotAServer' -ssasDb 'Db3' -CubeName 'Cube2' -MeasureGroupName 'Mg1' -Fix
        Assert-MockCalled -CommandName Process-SSASIndex -ModuleName Set-SSASAggregationDesign -Scope It -Times 2 -Exactly
    }



}<#END Describe "Set-SSASAggregationDesign - testing -DoNotProcess" #>



Describe "Set-SSASAggregationDesign - without core mocked out - for observation" {
    BEFOREALL{
        MOCK -CommandName Get-SSASServer -ModuleName Set-SSASAggregationDesign -MockWith {Fake-SSASServer -SSASInstance 'Whatever'} -Verifiable
        MOCK -CommandName Get-SSASPartitionAggregationsProcessedCount -ModuleName Set-SSASAggregationDesign -MockWith {0} -Verifiable
        $skip = $false
    }

    It -Skip:$skip "Set-SSASAggregationDesign on a MeasureGroup of 4 partitions, half WITHOUT aggregations WITH -Fix: Should return no errors" {
        $result = $null 
        TRY {Set-SSASAggregationDesign -Verbose -SSASInstance 'ImNotAServer' -ssasDb 'Db3' -CubeName 'Cube2' -MeasureGroupName 'Mg1' -Fix } CATCH {$result = $error[0].Exception.GetBaseException().Message.ToString()}
        $result | SHOULD BE $null
    }


}<#End Describe "Set-SSASAggregationDesign - without core mocked out - for observation"#>




