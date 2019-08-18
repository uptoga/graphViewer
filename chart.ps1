Add-Type -AssemblyName presentationframework, System.Windows.Forms, System.Windows.Forms.DataVisualization, WindowsFormsIntegration
[void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
[void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms.DataVisualization")

$Chart = New-object System.Windows.Forms.DataVisualization.Charting.Chart 

$x=1..10
$yc=$x|%{$_*2}
$item="test"
$Chart.Series.Add($item)|out-null
$chart.ChartAreas.Add("1")|out-null
$Chart.Series[$item].Points.DataBindXY($x, $yc)|out-null
$Chart.Series[$item].ChartType = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]::Line
$Chart.Series[$item].LegendText = $item
$Chart.Series[$item].BorderWidth = 12
            
$Chart.Series[$item]["DrawingStyle"] = "lighttodark"
$Chart.Series[$item]["pointwidth"] = "2"
$Chart.Width=1920
$Chart.Height=1080


#Build the GUI
[xml]$xaml = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    x:Name="Window" Title="Initial Window" WindowStartupLocation = "CenterScreen"
    xmlns:wfc="clr-namespace:System.Windows.Forms.DataVisualization.Charting;assembly=System.Windows.Forms.DataVisualization"
    Width = "800" Height = "600" ShowInTaskbar = "True">
    <DockPanel>
    <StackPanel x:Name="spControl" DockPanel.Dock="Right">
        <Label  Background="LightGray"
               Content="graph viewer"
                VerticalAlignment="Top"/>
        <Label Content="font info"/>
        <TextBox x:Name="tbFontSize" Text="35" VerticalAlignment="Top"/>
        <Label Content="axis info"/>
        <DataGrid x:Name="datagrid" AutoGenerateColumns="False" >
            <DataGrid.Columns>
                <DataGridTextColumn Header="axisName"         Binding="{Binding AxisName }" Width="Auto"/>
                <DataGridTextColumn Header="Title" Binding="{Binding Title, Mode=TwoWay, UpdateSourceTrigger=PropertyChanged,}" Width="Auto"/>
                <DataGridTextColumn Header="Interval" Binding="{Binding Interval, Mode=TwoWay, UpdateSourceTrigger=PropertyChanged,}" Width="Auto"/>
                <DataGridTextColumn Header="Min" Binding="{Binding Minimum, Mode=TwoWay, UpdateSourceTrigger=PropertyChanged,}" Width="Auto"/>
                <DataGridTextColumn Header="Max"     Binding="{Binding Maximum, Mode=TwoWay, UpdateSourceTrigger=PropertyChanged,}" Width="Auto"/>
            </DataGrid.Columns>
        </DataGrid>
    </StackPanel>
    <Viewbox Name = "vbImage" Stretch = "uniform"  HorizontalAlignment="Left" MinWidth="1000">
        <Canvas x:Name = "canvas1" Background="Black" Width="2000" Height="1000">
            <Image x:Name="image" HorizontalAlignment="Left" Height="{Binding Path=ActualHeight, ElementName=canvas1}" VerticalAlignment="Top" Width="auto"/>
        </Canvas>
    </Viewbox>
    </DockPanel>
</Window>
"@
 
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$Window = [Windows.Markup.XamlReader]::Load( $reader )

# For each name in <xxx x:Name="name">, new variable $name is created and set value  
$xaml.SelectNodes("//*") | ? {$_.Attributes["x:Name"] -ne $null} | % {
    New-Variable  -Name $_.Name -Value $Window.FindName($_.Name) -Force
}

$spControl.DataContext=$chart.ChartAreas[0]


#Save the chart to a memory stream, then to the hash table as a byte array
function setImage{
    param(
    )
$Stream = New-Object System.IO.MemoryStream
$Chart.SaveImage($Stream,"png")
$imStream = $Stream.GetBuffer()
$Stream.Dispose()
$image.Source=$imStream
}
$setImage={
    setImage
}
setImage|out-null

# Fill DataGrid
$axisInfo=@(
    $chart.ChartAreas[0].AxisX,
    $chart.ChartAreas[0].AxisY,
    $chart.ChartAreas[0].AxisX2,
    $chart.ChartAreas[0].AxisY2
    )
$datagrid.ItemsSource = @($axisInfo)

$setFont={
    $titlefont=new-object system.drawing.font("ARIAL",$tbFontSize.Text,[system.drawing.fontstyle]::bold)
    # $fontInfo|%{$_.value=$titlefont}
    # $chart.ChartAreas[0].AxisX.labelstyle.font=$titlefont
    $chart.Font=$titlefont
    $chart.ChartAreas[0].AxisX.TitleFont=$titlefont
    $chart.ChartAreas[0].AxisY.TitleFont=$titlefont
    $chart.ChartAreas[0].AxisX.labelstyle.font=$titlefont
    $chart.ChartAreas[0].AxisY.labelstyle.font=$titlefont
    setImage
    write-host "font changed"
}

$tbFontSize.Add_TextChanged($setFont)|out-null
$setFont.Invoke()

$datagrid.Add_CellEditEnding($setImage)|out-null
                        
$Window.ShowDialog() | Out-Null