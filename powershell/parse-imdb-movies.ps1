$_SCRIPT_PATH = split-path -parent $MyInvocation.MyCommand.Definition;

$fileStream = [System.IO.File]::OpenRead("$_SCRIPT_PATH\movies.list");

$reader = New-Object System.IO.StreamReader($fileStream, [System.Text.Encoding]::GetEncoding('iso-8859-1'));
$writer = New-Object IO.StreamWriter "$_SCRIPT_PATH\movies.txt";
$movies = @{};
$lineNo = 0;
while ($reader.Peek() -ge 0) {
  $line = $reader.ReadLine();
  if ($lineNo++ -and $lineNo % 10000 -eq 0) {Write-Host "Processed [$lineNo] lines";}
  if ($line -match '(.*\d{4}\))?') {
    $p = $Matches[0] -replace '["#]', '';
    if ($p -and -not $movies.containskey($p)) { 
        $p -match '(.*)\((\d{4})' | Out-Null;
        $writer.WriteLine("$($matches[1].trim())`t$($matches[2])"); 
    }
    ++$movies[$p];
  }

}
$reader.Dispose();
$fileStream.Dispose();
$writer.Dispose();