Add-Type -AssemblyName presentationframework, System.Windows.Forms, System.Windows.Forms.DataVisualization, WindowsFormsIntegration
[void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
[void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms.DataVisualization")

$Chart = New-object System.Windows.Forms.DataVisualization.Charting.Chart 


function copy-ca {
    param(
        $chart,
        $chartarea,
        $data,
        $split,
        $offset,
        $max,
        $min,
        $color
    )

    function copy-chart {
        param(
            $name
        )
        $CAAxis = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
        $CAAxis.Name = "$($data.name)_$name"
        $series = New-Object System.Windows.Forms.DataVisualization.Charting.Series
        $series.Points.DataBindXY($data.data.x, $data.data.y)|Out-Null
        $series.ChartType = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]::Line
        $series.BorderWidth=$chart.series[0].BorderWidth
        $series.Name = "$($data.name)_$name"
        $series.ChartArea = $CAAxis.name

        $CAAxis
        $series
    }

    function set-invisible {
        param(
            $ca
        )
        $CA.value.AxisX.LineWidth = 0;
        # $CA.value.AxisY.MajorGrid.Enabled = $true;
        $CA.value.AxisX.MajorGrid.Enabled = $false;
        $CA.value.AxisX.MajorTickMark.Enabled = $false;
        $CA.value.AxisX.LabelStyle.Enabled = $false;
        $CA.value.AxisY.MajorGrid.Enabled = $false;
        $CA.value.Position.FromRectangleF($ChartArea.Position.ToRectangleF()) | Out-Null
        $CA.value.InnerPlotPosition.FromRectangleF($ChartArea.InnerPlotPosition.ToRectangleF()) | Out-Null
        $CA.value.BackColor = [System.Drawing.Color]::Transparent

        # $CA.value.AxisY.Maximum = $max

        
        $max_0 = $chart.ChartAreas[0].AxisY.Maximum
        $min_0 = $chart.ChartAreas[0].AxisY.Minimum
        
        $min2max = $max_0 - $min_0
        # $interval_0 = $chart.ChartAreas[0].AxisY.Interval
        $interval_0 = $min2max / 10
        $chart.ChartAreas[0].AxisY.Interval = $interval_0
        $num = [int](($max_0 - $min_0) / $interval_0)
        # $min2max = $max - $min
        # $CA.value.AxisY.Interval = [math]::round($min2max / ($split), 1)
        # $CA.value.AxisY.Interval = $min2max / ($split)
        
        $CA.value.AxisY.Minimum = $min
        $l=.01,.02,.05,.1,.2,.5,1,2,5,10,20,50,100
        $tinterval = ($max -$min) / $num
        $interval = ($l|?{($_ - $tinterval) -ge 0})[0] 

        $CA.value.axisY.Maximum = $ca.value.axisY.Minimum + $num * $interval
        $CA.value.axisY.Interval = $interval

        # $CA.value.AxisY.Interval = 0.1
    }

    $CA_ax = copy-chart "axis"    
    $CAAxis = $ca_ax[0]
    $series = $ca_ax[1]

    set-invisible ([ref]$CAAxis)

    $CA_ar = copy-chart "area"
    $CAArea = $ca_ar[0]
    $series_area = $ca_ar[1]
    set-invisible ([ref]$CAArea)

    $CAAxis.Position.X -= $offset
    $CAAxis.AxisY.LineColor = [System.Drawing.Color]::$color
    $CAAxis.AxisY.MajorTickMark.LineColor =  [System.Drawing.Color]::$color
    # $CAAxis.AxisY.titleForecolor = [System.Drawing.Color]::$color
    # $CAAxis.AxisY.TitleAlignment  = [System.Drawing.StringAlignment]::Near

    $an = New-Object System.Windows.Forms.DataVisualization.Charting.TextAnnotation
    $an.Text = $data.name
    $an.X = $CAAxis.Position.X
    $an.Y = 0
    $an.ForeColor = [System.Drawing.Color]::$color

    $chart.Annotations.Add($an)

    $series.Color = [System.Drawing.Color]::Transparent

    $CAArea.AxisY.MajorGrid.Enabled = $false;
    $CAArea.AxisY.MajorTickMark.Enabled = $false;
    $CAArea.AxisY.LabelStyle.Enabled = $false;
    $series_area.Color = [System.Drawing.Color]::$color
    $itv = [math]::floor($series_area.Points.count/10)
    $i=0
    foreach($p in $series_area.Points){
        if($i%$itv -eq 0){
            $p.MarkerStyle = 1
            $p.MarkerSize = 10
            $p.MarkerColor = [system.drawing.color]::White
            $p.markerBorderColor = [system.drawing.color]::$color
        }
        $i++
    }
    # $series_area.BorderWidth = 10


    $chart.ChartAreas.Add($CAAxis)|out-null
    $chart.ChartAreas.Add($CAArea)|out-null
    
    $chart.Series.Add($series)|out-null
    $chart.Series.Add($series_area)|out-null
}
function make-chart{
    param(
        $data,
        $linecolor
    )
    $Chart = New-object System.Windows.Forms.DataVisualization.Charting.Chart 
    $item = "first"
    $Chart.Series.Add($item) | out-null
    $chart.ChartAreas.Add("first") | out-null
    $Chart.Series[$item].Points.DataBindXY($data[0].data.x, $data[0].data.y) | out-null
    $Chart.Series[$item].ChartType = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]::Line
    $Chart.Series[$item].LegendText = $data[0].name
    $Chart.Series[$item].BorderWidth = 1
                
    $Chart.Width = 1920
    $Chart.Height = 1080

    $offset=3.5
    $chart.ChartAreas[0].Position.x = 3+$data.length *$offset
    $chart.ChartAreas[0].Position.y = 0
    $chart.ChartAreas[0].Position.width = 100-$chart.ChartAreas[0].Position.x
    $chart.ChartAreas[0].Position.Height = 100
    $an = New-Object System.Windows.Forms.DataVisualization.Charting.TextAnnotation
    $an.Text = "Pin[MPa]"
    $an.X = $chart.ChartAreas[0].Position.X
    $an.Y = 0
    $chart.Annotations.Add($an)
    
    $Chart.ChartAreas[0].InnerPlotPosition.X = 3
    $Chart.ChartAreas[0].InnerPlotPosition.Y = 3
    $Chart.ChartAreas[0].InnerPlotPosition.Width = 90
    $Chart.ChartAreas[0].InnerPlotPosition.Height = 90
    
    $chart.ChartAreas[0].AxisY.Maximum = 3
    $chart.ChartAreas[0].AxisY.Minimum = 0
    $chart.ChartAreas[0].AxisY.TitleAlignment = [System.Drawing.StringAlignment]::Far
    # $chart.ChartAreas[0].AxisY.IsInterlaced = $true
    # $Chart.ChartAreas[0].AxisY.InterlacedColor = [System.Drawing.Color]::LightGray
    $min2max = $chart.ChartAreas[0].AxisY.Maximum - $chart.ChartAreas[0].AxisY.Minimum
    # $split = 15
    # $chart.ChartAreas[0].AxisY.Interval = [math]::round($min2max / ($split), 1)
    # $chart.ChartAreas[0].AxisY.Interval = $min2max / ($split)
    $ivl = $Chart.ChartAreas[0].AxisY.Interval
    $max = $Chart.ChartAreas[0].AxisY.Maximum
    $min = $Chart.ChartAreas[0].AxisY.Minimum
    $split = ($max-$min)/$ivl
    
    $off=$offset
    # $l="red","gray","blue"
    $i=0
    $data=$data[1..($data.length-1)]
    foreach($d in $data){
        copy-ca $Chart $Chart.ChartAreas[0] $d $split $off $d.max $d.min $linecolor[$i]
        $off += $offset
        $i++
    }
    $chart
}

$l=0..1000
$mult=5..12
$ys = foreach($m in $mult){
    [PSCustomObject]@{
        name = "test_$m"
        max=$m
        min=0
        data = $l | % {
            [PSCustomObject]@{
                x = [double]$_
                y = [double](1 - ([math]::Exp(-$_ / 200) * [math]::Cos($_ / (5*$m)))) + (Get-Random -Minimum -0.05 -Maximum 0.05)
            }
        }
    }
}
$lc="red","orange","blue","maroon","green","pink","purple"
$chart = make-chart $ys $lc

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
                <DataGridTextColumn Header="offset"     Binding="{Binding offset, Mode=TwoWay, UpdateSourceTrigger=PropertyChanged,}" Width="Auto"/>
            </DataGrid.Columns>
        </DataGrid>
    </StackPanel>
    <Viewbox Name = "vbImage" Stretch = "uniform"  HorizontalAlignment="Left" MinWidth="1000">
        <Canvas x:Name = "canvas1" Background="Black" Width="2000" Height="1100">
            <Image x:Name="image" RenderOptions.BitmapScalingMode="HighQuality" HorizontalAlignment="Left" Height="{Binding Path=ActualHeight, ElementName=canvas1}" VerticalAlignment="Top" Width="auto"/>
        </Canvas>
    </Viewbox>
    </DockPanel>
</Window>
"@
 
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$Window = [Windows.Markup.XamlReader]::Load( $reader )

# For each name in <xxx x:Name="name">, new variable $name is created and set value  
$xaml.SelectNodes("//*") | ? { $_.Attributes["x:Name"] -ne $null } | % {
    New-Variable  -Name $_.Name -Value $Window.FindName($_.Name) -Force
}

function setImage {
    param(
    )
    $Stream = New-Object System.IO.MemoryStream
    $Chart.SaveImage($Stream, "png")
    $imStream = $Stream.GetBuffer()
    $Stream.Dispose()
    $image.Source = $imStream
}

$setImage={
    setImage
}

$setScale={
    for ($i = 1; $i -lt $chart.ChartAreas.Count; $i+=2) {
        $chart.ChartAreas[$i].AxisY.Interval=$chart.ChartAreas[$i+1].AxisY.Interval
        $chart.ChartAreas[$i].AxisY.Minimum=$chart.ChartAreas[$i+1].AxisY.Minimum
        $chart.ChartAreas[$i].AxisY.Maximum=$chart.ChartAreas[$i+1].AxisY.Maximum
        $chart.ChartAreas[$i].AxisY.TitleAlignment=$chart.ChartAreas[$i+1].AxisY.TitleAlignment
        $chart.ChartAreas[$i].AxisY.Title=$chart.ChartAreas[$i+1].AxisY.Title
    }
    setImage
}

$setFont={
    $titlefont=new-object system.drawing.font("ARIAL",$tbFontSize.Text,[system.drawing.fontstyle]::bold)
    for ($i = 0; $i -lt $chart.ChartAreas.Count; $i++) {
        $chart.ChartAreas[$i].AxisY.LabelStyle.font = $titlefont
        $chart.ChartAreas[$i].AxisX.LabelStyle.font = $titlefont
    }
    $chart.font = $titlefont
    setImage
}

# Fill DataGrid
# $axisInfo=@(
#     $chart.ChartAreas[0].AxisY,
#     $chart.ChartAreas[2].AxisY,
#     $chart.ChartAreas[4].AxisY,
#     $chart.ChartAreas[6].AxisY,
#     $chart.ChartAreas[8].AxisY,
#     $chart.ChartAreas[10].AxisY
#     )
$chart.ChartAreas|%{$_.AxisY|Add-Member -NotePropertyName "offset" -NotePropertyValue 2|out-null}
$l_ca = $chart.ChartAreas.count
$axisInfo = 0..($l_ca-1)|?{$_%2 -eq 0}|%{$chart.ChartAreas[$_].axisY}
# $axisInfo|%{$_|Add-Member -NotePropertyName "Offset" -NotePropertyValue $(Get-Random -Maximum 3 -Minimum 0)}|Out-Null
# $datagrid.ItemsSource = @($axisInfo)
$datagrid.ItemsSource = $axisInfo

$datagrid.Add_CellEditEnding($setScale)|out-null
$tbFontSize.Add_TextChanged($setFont)|out-null

# $datagrid.Add_CellEditEnding($setImage)|out-null
                        


setImage | out-null
$Window.ShowDialog() | Out-Null