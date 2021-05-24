Import-Module Az.KeyVault

$KeyVault = "kv-kxu-01"

$secrets = Import-Csv '_DEVTestKXU - Identity/Drop/keyvault.csv'

function New-RandomPassword() {
    param (
        [int]$size
    )
    $minLength = 8 ## characters
    $maxLength = $size ## characters
    $lengh = Get-Random -Minimum $minLength -Maximum $maxLength
    $nonAlphaChars = $minLength
    $password = [system.web.security.membership]::GeneratePassword($lengh, $nonAlphaChars)
    return $password
}

foreach ($secret in $secrets) {
    If ($secret.secret -eq 'random') {
        $tmpSecret = ConvertTo-SecureString (New-RandomPassword -size 14) -AsPlainText -Force
    }
    Else {
        $tmpSecret = ConvertTo-SecureString $secret.secret -AsPlainText -Force
    }
    if (!(Get-AzKeyVaultSecret -VaultName $KeyVault -name $secret.name)) {
        $tmpsecret = Set-AzKeyVaultSecret -VaultName $KeyVault -Name $secret.name -SecretValue $tmpSecret
    }
    Else {
        Write-Host "Secret is alrady in tne Key Vault. No change is required."
    }
}