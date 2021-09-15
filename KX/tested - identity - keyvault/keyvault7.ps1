Import-Module Az.KeyVault

$KeyVault = "kv-kxu-01"

$secrets = Import-Csv '/home/vsts/work/1/a/keyvault.csv'

Function New-RandomPassword {
 
    [CmdletBinding()]
    param(
        [Parameter(
            Position = 0,
            Mandatory = $false
        )]
        [ValidateRange(5,79)]
        [int]    $Length = 16,
 
        [switch] $ExcludeSpecialCharacters
 
    )
 
    BEGIN {
        $SpecialCharacters = @((33,35) + (36..38) + (42..44) + (60..64) + (91..94))
    }
 
    PROCESS {
        try {
            if (-not $ExcludeSpecialCharacters) {
                    $Password = -join ((48..57) + (65..90) + (97..122) + $SpecialCharacters | Get-Random -Count $Length | foreach {[char]$_})
                } else {
                    $Password = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count $Length | foreach {[char]$_})
            }
 
        } catch {
            Write-Error $_.Exception.Message
        }
 
    }
 
    END {
        Write-Output $Password
    }
 
}

# Generate Random Passwords by calling the function above

foreach ($secret in $secrets) {
    If ($secret.secret -eq 'random') {
        $tmpSecret = ConvertTo-SecureString (New-RandomPassword) -AsPlainText -Force
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