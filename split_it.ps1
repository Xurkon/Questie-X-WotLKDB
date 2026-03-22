$inputPath = 'c:\Users\kance\Documents\GitHub\Questie-X-WotLKDB\Database\Wotlk\wotlkItemDB.lua'
$outputDir = 'c:\Users\kance\Documents\GitHub\Questie-X-WotLKDB\Database\Wotlk\Split\'

Write-Host "Reading $inputPath..."
$data = Get-Content -Path $inputPath -Encoding UTF8 | Where-Object { $_ -match '^\[\d+\] = \{' }
$total = $data.Count
Write-Host "Total items found: $total"

$numChunks = 5
$chunkSize = [Math]::Ceiling($total / $numChunks)

for ($i = 0; $i -lt $numChunks; $i++) {
    $startIdx = $i * $chunkSize
    $endIdx = ($i + 1) * $chunkSize - 1
    if ($endIdx -ge $total) { $endIdx = $total - 1 }
    
    if ($startIdx -ge $total) { break }
    
    $chunk = $data[$startIdx..$endIdx]
    $chunkNum = $i + 1
    $filePath = Join-Path $outputDir "wotlkItemDB_$chunkNum.lua"
    
    Write-Host "Creating $filePath (Items $startIdx to $endIdx)..."
    
    $header = @(
        '-- AUTO GENERATED FILE! DO NOT EDIT! (split chunk)',
        'local _, addonTable = ...',
        'addonTable.itemData = addonTable.itemData or {}',
        'local _d = addonTable.itemData'
    )
    
    $header | Out-File -FilePath $filePath -Encoding UTF8
    $chunk -replace '^\s*\[(\d+)\] = ', '_d[$1] = ' | Out-File -FilePath $filePath -Encoding UTF8 -Append
}

Write-Host "Done!"
