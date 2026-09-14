# Searching User Files
$TargetPaths = @(
    "$env:USERPROFILE\Desktop",
    "$env:USERPROFILE\Downloads",
    "$env:USERPROFILE\Documents",
    "$env:USERPROFILE\AppData\Local",
    "$env:USERPROFILE\AppData\Roaming",
    "C:\Users\Public"
)

Write-Host "[*] Scanning for .exe and .dll files with Unicode anywhere in their path & verifying signatures..." -ForegroundColor Cyan
$FoundCount = 0

foreach ($Path in $TargetPaths) {
    if (-not (Test-Path $Path)) { continue }

    # Find the Exes and Dlls
    $Files = Get-ChildItem -Path $Path -Recurse -File -Include *.exe, *.dll -ErrorAction SilentlyContinue

    foreach ($File in $Files) {
        # Check the files for Unicode
        if ($File.FullName -match '[^\x20-\x7E]') {
            $FoundCount++
            
            # Check the signature of the file
            $Signature = Get-AuthenticodeSignature -FilePath $File.FullName -ErrorAction SilentlyContinue
            $SigStatus = $Signature.Status
            
            # Make it pretty
            if ($SigStatus -eq "Valid") {
                $SigColor = "Green"
                $SigText = "SIGNED (Valid) - Publisher: $($Signature.SignerCertificate.Subject)"
            } else {
                $SigColor = "Red"
                # Will display NotSigned, Unknown, HashMismatch, etc.
                $SigText = "UNSIGNED ($SigStatus)" 
            }

            # Make the output pretty
            Write-Host "[!] Found Unicode in Path!" -ForegroundColor Yellow
            Write-Host "    File Name: $($File.Name)" -ForegroundColor White
            Write-Host "    Full Path: $($File.FullName)" -ForegroundColor Gray
            Write-Host "    Signature: $SigText" -ForegroundColor $SigColor
            Write-Host ""
        }
    }
}

# Credits (Cause I am the best)
Write-Host "[*] Scan complete." -ForegroundColor Cyan
Write-Host "Made with love by kastris_`n" -ForegroundColor Magenta

if ($FoundCount -eq 0) {
    Write-Host "[+] Clean! No .exe or .dll file paths contain Unicode characters." -ForegroundColor Green
} else {
    Write-Host "[!] Found $FoundCount file(s) with Unicode in their paths." -ForegroundColor Red
}
