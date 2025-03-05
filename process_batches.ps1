# Define variables
$filePath = "D:\apps\Informatica\Informatica_10.4.0\tomcat\bin\target\myparam_ali.xml"
$outputDir = "D:\apps\Informatica\Informatica_10.4.0\tomcat\bin\target\DP_OUTPUT"
$outputFileName = "OUTPUT_FILE.out"
$finalOutputFile = "D:\apps\Informatica\Informatica_10.4.0\tomcat\bin\target\DP_OUTPUT\Final_Out_DP.xml"
$numIterations = 4

# Step 1: Read the integer value from a file
$inputFile = "D:\apps\Informatica\Informatica_10.4.0\tomcat\bin\target\DP_OUTPUT\Total_Rows.txt"

if (Test-Path -Path $inputFile) {
    # Read the value from the file
    $fileContent = Get-Content -Path $inputFile
    [int]$inputValue = [int]$fileContent.Trim()  # Ensure it's an integer value
    Write-Host "Read input value: $inputValue from file $inputFile"

    # Step 2: Calculate increment value using Ceiling
    $incrementValue = [math]::Ceiling($inputValue / $numIterations)
    Write-Host "Calculated increment value: $incrementValue (Ceiling of $inputValue / $numIterations)"
} else {
    Write-Host "Error: Input file '$inputFile' does not exist."
    exit 1
}

# Initialize BTW values for the first iteration
$btw1Value = 1
$btw2Value = 0 + $incrementValue

# Loop for the specified number of iterations
for ($i = 1; $i -le $numIterations; $i++) {
    # Step 3: Create the XML file with updated values
    $xmlContent = @"
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<root xmlns="http://www.informatica.com/Parameterization/1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema" version="2.0">
    <project name="DP_Practice">
        <mapping name="MID_DP">
            <parameter name="BTW_1">$btw1Value</parameter>
            <parameter name="BTW_2">$btw2Value</parameter>
        </mapping>
    </project>
</root>
"@

    [xml]$xmlDoc = New-Object System.Xml.XmlDocument
    $xmlDoc.LoadXml($xmlContent)
    $xmlDoc.Save($filePath)

    Write-Host "Iteration ${i}: Created/Updated file with BTW_1=${btw1Value} and BTW_2=${btw2Value}"

    # Step 4: Execute the PowerShell command
    $command = "C:\Informatica\10.4.0\clients\DeveloperClient\infacmd\infacmd.bat ms RunMapping -dn INFA_DOM -sn Data_Integration_Service -un ali.sherif -pd ali.sherif123 -a APP_DP -m MID_DP -pf $filePath"
    Write-Host "Executing command: $command"
    Invoke-Expression $command

    # Step 5: Wait for the output file to appear
    Write-Host "Waiting for output file '${outputFileName}' to appear in directory '${outputDir}'..."
    while (-not (Test-Path -Path (Join-Path -Path $outputDir -ChildPath $outputFileName))) {
        Start-Sleep -Seconds 5
    }

    # Step 6: Rename the output file with the iteration number
    $oldFilePath = Join-Path -Path $outputDir -ChildPath $outputFileName
    $newFilePath = Join-Path -Path $outputDir -ChildPath "OUTPUT_FILE${i}.out"
    Rename-Item -Path $oldFilePath -NewName $newFilePath
    Write-Host "Renamed output file to 'OUTPUT_FILE${i}.out'"

    # Step 7: Increment the BTW values for the next iteration
    $btw1Value += $incrementValue
    $btw2Value += $incrementValue
}

# Step 8: Combine all output files into a single file
Write-Host "Combining all output files into a single file: ${finalOutputFile}"

# Remove the final output file if it already exists
if (Test-Path -Path $finalOutputFile) {
    Remove-Item -Path $finalOutputFile
}

# Add the XML declaration and root element at the beginning of the file
@"
<?xml version="1.0" encoding="UTF-8"?>
<Employees>
"@ | Set-Content -Path $finalOutputFile

# Append data from each output file
for ($i = 1; $i -le $numIterations; $i++) {
    $currentFilePath = Join-Path -Path $outputDir -ChildPath "OUTPUT_FILE${i}.out"

    if (Test-Path -Path $currentFilePath) {
        Get-Content -Path $currentFilePath | Add-Content -Path $finalOutputFile
        Write-Host "Appended content from 'OUTPUT_FILE${i}.out' to '${finalOutputFile}'"
    } else {
        Write-Host "Warning: File 'OUTPUT_FILE${i}.out' does not exist. Skipping..."
    }
}

# Add the closing root element at the end of the file
@"
</Employees>
"@ | Add-Content -Path $finalOutputFile

Write-Host "All files combined into '${finalOutputFile}'."

# Step 9: Cleanup all OUTPUT_FILE*.out files
Write-Host "Cleaning up all 'OUTPUT_FILE*.out' files in directory '${outputDir}'..."
Remove-Item -Path (Join-Path -Path $outputDir -ChildPath "OUTPUT_FILE*.out") -Force
Write-Host "Cleanup completed. All 'OUTPUT_FILE*.out' files have been removed."
