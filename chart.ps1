Add-Type -AssemblyName presentationframework, System.Windows.Forms, System.Windows.Forms.DataVisualization, WindowsFormsIntegration
[void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
[void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms.DataVisualization")

#Build the GUI
[xml]$xaml = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    x:Name="Window" Title="Initial Window" WindowStartupLocation = "CenterScreen"
    xmlns:wfc="clr-namespace:System.Windows.Forms.DataVisualization.Charting;assembly=System.Windows.Forms.DataVisualization"
    Width = "800" Height = "600" ShowInTaskbar = "True">
    <DockPanel>
    <StackPanel DockPanel.Dock="Right">
        <Label  Background="LightGray"
               Content="search image"
                VerticalAlignment="Top"/>
        <TextBox x:Name="searchText" VerticalAlignment="Top"/>
        <Button x:Name="button" Content="search" MinHeight = "20"/>
        <ListBox x:Name="history" MinHeight = "50" AllowDrop="True" SelectionMode="Extended"/>
        <Label Content="search image in image"/>
        <Button x:Name="button2" Content="search" MinHeight = "20"/>

        <ListBox x:Name="listbox" MinHeight = "50" AllowDrop="True" SelectionMode="Extended"/>
    </StackPanel>
    <Viewbox Name = "VB" Stretch = "uniform"  HorizontalAlignment="Left" MinWidth="1000">
        <Canvas x:Name = "canvas1" Background="Black" Width="2000" Height="1000">
            <WindowsFormsHost Name="WF" Height="{Binding Path=ActualHeight, ElementName=canvas1}" Width="{Binding Path=ActualWidth, ElementName=canvas1}">
                <wfc:Chart Name="Chart1" />
            </WindowsFormsHost>
        </Canvas>
    </Viewbox>
    </DockPanel>
</Window>
"@
 
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$Window = [Windows.Markup.XamlReader]::Load( $reader )

#Connect to Control
# $viewbox = $Window.FindName("VB")
$viewbox = $Window.Content.FindName("VB")
$windowsFormsHost = $viewbox.FindName("WF")
# $chart = $Window.FindName("Chart1")
$Chart= $windowsFormsHost.Child[0]

$x=1..10
$yc=$x|%{$_*2}
# $Chart = New-Object System.Windows.Forms.DataVisualization.Charting.Chart 
$item="test"
$Chart.Series.Add($item)
$chart.ChartAreas.Add("1")
$Chart.Series[$item].Points.DataBindXY($x, $yc)
$Chart.Series[$item].ChartType = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]::Line
# $Chart.Series[$item].Font = $labelfont
$Chart.Series[$item].LegendText = $item
$Chart.Series[$item].BorderWidth = 12
            
$Chart.Series[$item]["DrawingStyle"] = "lighttodark"
$Chart.Series[$item]["pointwidth"] = "2"
                        
# $windowsFormsHost.Child
$Window.ShowDialog() | Out-Null