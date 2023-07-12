$directory = "C:\Path\to\site\directory"
$subdirectory = "topper" # this is the url path and subdirectory.
$appName = "Top name" # this is the name visable for the user

## the script, no edit zone

$outputFile = "$directory\sw.js"
# copy from execution path the main.js file and manifest.json and sw.js file to the directory
Copy-Item -Path "main.js" -Destination $directory
Copy-Item -Path "sw.js" -Destination $directory
Copy-Item -Path "manifest.json" -Destination $directory

# Get all filesToCache from directory filename only and replace directory with subdirectory name  only scan the data subdirectory and replace \ with /
$filesToCache = Get-ChildItem -Path $directory -Recurse -File | Select-Object -ExpandProperty FullName | ForEach-Object { $_.Replace($directory, $subdirectory).Replace("\", "/") }

# Create the jsContent variable with the cacheName and filesToCache variables in it displayed one per line
$jsContent = "var cacheName = '$($subdirectory)';
var filesToCache = [
    `"$(($filesToCache -join '", "'))`"
];
"

# Preprend the jsContent on the sw.js file
$contentToWrite = $jsContent + (Get-Content -Raw -Path $outputFile)
$contentToWrite | Set-Content -Path $outputFile -Encoding UTF8

Write-Host "JavaScript variable written to: $outputFile"

# Replace the "start_url": "/buzzer/index.html", with "start_url": "/$subdirectory/index/html", and the name and short_name with $name in the manifest.json file
(Get-Content -Path "$directory\manifest.json") -replace '("name": ")(.*)(")', "`$1$appName`$3" | Set-Content -Path "$directory\manifest.json"
(Get-Content -Path "$directory\manifest.json") -replace '("short_name": ")(.*)(")', "`$1$appName`$3" | Set-Content -Path "$directory\manifest.json"
(Get-Content -Path "$directory\manifest.json") -replace '("start_url": "/)(.*)(/index.html")', "`$1$subdirectory`$3" | Set-Content -Path "$directory\manifest.json"

$styleToAddContent = Get-Content -Path "styleToAdd.css" -Raw
$headersToAddContent = (Get-Content -Path "template.html" -Raw) -replace '{{NAME}}', $appName
# Replace <style> in the index.html in directory with the contents in the styleToAdd.css file append it to the current contents of the <style> tag

(Get-Content -Path "$directory\index.html") -replace '(<style>)(.*?)(</style>)', "`$1`$2$styleToAddContent`$3$headersToAddContent" | Set-Content -Path "$directory\index.html" -Encoding UTF8