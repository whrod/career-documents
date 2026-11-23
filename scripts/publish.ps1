param([string]$ConfigPath, [switch]$Force)
$ErrorActionPreference='Stop'
$repoRoot=Split-Path $PSScriptRoot -Parent
if (!$ConfigPath) {$ConfigPath=Join-Path $repoRoot 'config.local.json'}
$work=Join-Path $repoRoot '.local'
New-Item -ItemType Directory -Path $work -Force | Out-Null
$mutex=New-Object Threading.Mutex($false,'Local\KyoungchanCareerPublish')
if (!$mutex.WaitOne(0)) {exit 0}
function Run([string]$Exe,[string[]]$Arguments) {
  & $Exe @Arguments
  if($LASTEXITCODE -ne 0) {throw "$Exe failed with exit code $LASTEXITCODE"}
}
function Read-SharedBytes([string]$Path) {
  $stream=[IO.File]::Open($Path,[IO.FileMode]::Open,[IO.FileAccess]::Read,([IO.FileShare]::ReadWrite -bor [IO.FileShare]::Delete))
  $buffer=New-Object IO.MemoryStream
  try {$stream.CopyTo($buffer);return ,$buffer.ToArray()} finally {$stream.Dispose();$buffer.Dispose()}
}
try {
  Set-Location $repoRoot
  $config=Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
  $statePath=Join-Path $work 'state.json'
  $state=if(Test-Path $statePath){Get-Content $statePath -Raw | ConvertFrom-Json -AsHashtable}else{@{}}
  $newState=@{}; $changed=@()
  foreach($item in $config.documents) {
    if($item.id -notin @('resume','career')) {throw 'Unexpected document ID'}
    $source=[IO.Path]::GetFullPath((Join-Path $repoRoot $item.source))
    if(!(Test-Path -LiteralPath $source)) {throw "Source missing: $($item.id)"}
    $sourceBytes=Read-SharedBytes $source
    $hash=[Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($sourceBytes))
    $newState[$item.id]=$hash
    if($Force -or $state[$item.id] -ne $hash -or !(Test-Path "docs/files/$($item.id).pdf")) {
      $inputCopy=Join-Path $work "$($item.id).docx"
      [IO.File]::WriteAllBytes($inputCopy,$sourceBytes)
      if((Get-FileHash -LiteralPath $inputCopy).Hash -ne $hash) {throw 'Source changed during copy; retry next run'}
      $changed+=@{item=$item;source=$source;input=$inputCopy;output=(Join-Path $work "$($item.id)-$hash.pdf")}
    }
  }
  if($changed.Count -gt 0) {
    # Only saved Word contents are published; copies keep the user's open document untouched.
    $word=New-Object -ComObject Word.Application
    $word.Visible=$false; $word.DisplayAlerts=0
    try {
      foreach($entry in $changed) {
        $document=$word.Documents.Open($entry.input,$false,$true)
        try {
          $entry.pages=$document.ComputeStatistics(2)
          if($entry.pages -lt 1 -or $entry.pages -gt 20) {throw 'Unexpected page count'}
          $document.ExportAsFixedFormat($entry.output,17)
        } finally {$document.Close(0)}
        $bytes=[IO.File]::ReadAllBytes($entry.output)
        if($bytes.Length -lt 1024 -or [Text.Encoding]::ASCII.GetString($bytes,0,5) -ne '%PDF-') {throw 'Invalid PDF export'}
      }
    } finally {$word.Quit()}
    $manifestPath=Join-Path $repoRoot 'docs/documents.json'
    $manifest=if(Test-Path $manifestPath){Get-Content $manifestPath -Raw | ConvertFrom-Json -AsHashtable}else{@{documents=@{}}}
    foreach($entry in $changed) {
      $id=$entry.item.id
      Copy-Item -LiteralPath $entry.output -Destination "docs/files/$id.pdf" -Force
      $manifest.documents[$id]=@{title=$entry.item.title;file="files/$id.pdf";sha256=(Get-FileHash "docs/files/$id.pdf").Hash.ToLower();pages=$entry.pages;updatedAt=([TimeZoneInfo]::ConvertTimeBySystemTimeZoneId([DateTime]::UtcNow,'Korea Standard Time').ToString('yyyy-MM-dd HH:mm'));version=[IO.Path]::GetFileNameWithoutExtension($entry.source)}
    }
    $manifest | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $manifestPath -Encoding utf8
  }
  # Stage only explicit public files. Never stage the career workspace or local state.
  Run 'git' @('add','--','docs','scripts','README.md','.gitignore','config.example.json')
  & git diff --cached --quiet
  if($LASTEXITCODE -eq 1) {Run 'git' @('commit','-m','Update public career documents')}
  elseif($LASTEXITCODE -ne 0) {throw 'Unable to inspect staged changes'}
  # Retry a previous push even when input hashes did not change.
  Run 'git' @('push','origin','main')
  $newState | ConvertTo-Json | Set-Content -LiteralPath $statePath -Encoding utf8
  $status=@{ok=$true;checkedAt=[DateTime]::UtcNow.ToString('o');changed=@($changed | ForEach-Object {$_.item.id});commit=(& git rev-parse HEAD)}
  $status | ConvertTo-Json -Depth 5 | Set-Content (Join-Path $work 'last-run.json') -Encoding utf8
  Write-Output ('Published documents: '+($status.changed -join ', '))
} catch {
  @{ok=$false;checkedAt=[DateTime]::UtcNow.ToString('o');error=$_.Exception.Message} | ConvertTo-Json | Set-Content (Join-Path $work 'last-run.json') -Encoding utf8
  throw
} finally {$mutex.ReleaseMutex();$mutex.Dispose()}
