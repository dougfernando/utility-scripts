param (
    [string]$source = $(Throw "You have to specify a source path."))

$extensionSize = 3
if ($source.EndsWith("docx")) {
  $extensionSize = 4
}

$destiny = $source.Substring(0, $source.Length - $extensionSize) + "pdf"
$saveaspath = [ref] $destiny 
$formatPDF = [ref] 17

$word = new-object -ComObject "word.application"
$doc = $word.documents.open($source)
$doc.SaveAs($saveaspath, $formatPDF)
$doc.Close()

echo "Converted file: $source"

ps winword | kill



