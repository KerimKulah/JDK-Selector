<#
.SYNOPSIS
    JDK Selector - JDK sürümlerini indirme, kurma ve değiştirme işlevleri sunar.
.DESCRIPTION
    Bu script ile Eclipse Adoptium (Temurin) JDK sürümlerini kolayca indirip kurabilir
    ve farklı sürümler arasında geçiş yapabilirsiniz.
#>

$Global:JAVA_DIR = "$env:ProgramFiles\Java"
$Global:API_URL = "https://api.adoptium.net/v3/info/available_releases"

# Başlangıç fonksiyonu
function Initialize-JdkManager {

    if (-not (Test-Path $JAVA_DIR)) {
        try{
            New-Item -Path $JAVA_DIR -ItemType Directory -Force | Out-Null
            Write-Host "Java dizini oluşturuldu: $JAVA_DIR"
        } catch {
            Write-Error "Java dizini oluşturulamadı: $_"
        }
    }

    
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "               JDK Selector               " -ForegroundColor Green
    Write-Host "           Yapımcı: Kerim Külah           " -ForegroundColor Gray
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "Hoşgeldiniz!" -ForegroundColor Yellow
    Write-Host "JDK yönetimi için aşağıdaki komutları kullanabilirsiniz."
    Write-Host ""

    Show-Help

   while ($true) {
    $input = Read-Host "`nYapmak istediğiniz işlemi giriniz"
    $parts = $input.ToLower().Split(" ")

    switch ($parts[0]) {
        "help" {
            Show-Help
        }

        "jdk" {
            if ($parts.Length -ge 2 -and $parts[1] -eq "list") {
                List-Jdks
            } else {
                Write-Host "Kullanım: jdk list" -ForegroundColor Yellow
            }
        }

        "use" {
            if ($parts.Length -eq 3 -and $parts[1] -eq "jdk") {
                $version = $parts[2]
                Use-Jdk -version $version
            } else {
                Write-Host "Kullanım: use jdk <versiyon>" -ForegroundColor Yellow
            }
        }

        "install" {
            if ($parts.Length -eq 3 -and $parts[1] -eq "jdk") {
                $version = $parts[2]
                Install-Jdk -version $version
            } else {
                Write-Host "Kullanım: install jdk <versiyon>" -ForegroundColor Yellow
            }
        }

        "exit" {
            Write-Host "Çıkılıyor..." -ForegroundColor Red
            Start-Sleep -Seconds 1
            if ($Host.Name -eq 'ConsoleHost') {
                exit
            } else {
                return
            }
        }

        default {
            Write-Host "Geçersiz komut. 'help' yazarak geçerli komutları görebilirsiniz." -ForegroundColor Red
        }
    }
}
}


function Show-Help {
    Write-Host ""
    Write-Host "Kullanılabilir komutlar:" -ForegroundColor Cyan
    Write-Host "  help                   - Komutları gösterir"
    Write-Host "  jdk list               - JDK sürümlerini listeler"
    Write-Host "  install jdk <version>  - Yeni bir JDK sürümünü yükler"
    Write-Host "  use jdk <version>      - Belirli bir JDK sürümünü aktif eder"
    Write-Host "  exit                   - Uygulamadan çıkış yapar"
}


# JDK LİSTESİ
function List-Jdks {
    try {
        $response = Invoke-RestMethod -Uri $API_URL -ErrorAction Stop
        $available = $response.available_releases | Sort-Object -Descending
        
        # Mevcut kurulu JDK'ları tespit et
        $installedVersions = @()
        if (Test-Path $JAVA_DIR) {
            $installedVersions = Get-ChildItem -Path $JAVA_DIR -Directory | 
                                Where-Object { $_.Name -match "jdk-(\d+)" } |
                                ForEach-Object { 
                                    if ($_.Name -match "jdk-(\d+)") { 
                                        [int]$Matches[1] 
                                    } 
                                }
        }
        
        # Aktif JDK'yı tespit et
        $currentJavaHome = [Environment]::GetEnvironmentVariable("JAVA_HOME", "Machine")
        $activeVersion = $null
        if ($currentJavaHome -match "jdk-(\d+)") {
            $activeVersion = [int]$Matches[1]
        }
        
        Write-Host "`n📦 JDK Sürümleri:" -ForegroundColor Cyan
        Write-Host "===================" -ForegroundColor Cyan
        
        foreach ($version in $available) {
            $isInstalled = $installedVersions -contains $version
            $isActive = $activeVersion -eq $version
            
            if ($isActive) {
                Write-Host " ▶ $version" -ForegroundColor Green -NoNewline
                Write-Host " [✓ Kurulu ve Aktif]" -ForegroundColor Green
            }
            elseif ($isInstalled) {
                Write-Host " - $version" -NoNewline
                Write-Host " [✓ Kurulu]" -ForegroundColor Green
            }
            else {
                Write-Host " - $version" -NoNewline
                Write-Host " [x İndirilmeli]" -ForegroundColor Yellow
            }
        }
        
        Write-Host "`nGüncel JAVA_HOME: " -NoNewline
        if ($currentJavaHome) {
            Write-Host $currentJavaHome -ForegroundColor Cyan
        } else {
            Write-Host "Ayarlanmamış" -ForegroundColor Red
        }
    }
    catch {
        Write-Error "JDK sürümleri alınamadı: $_"
    }
}


# JDK KURULUMU
function Install-Jdk {
    param(
        [Parameter(Mandatory=$true)]
        [string]$version
    )

    if (-not (Test-ValidVersion -version $version)) {
        return
    }

     
       $targetDir = "$JAVA_DIR\jdk-$version"
    if (Test-Path $targetDir) {
        $confirmation = Read-Host "JDK $version zaten kurulu görünüyor. Yeniden kurmak istiyor musunuz? (E/H)"
        if ($confirmation -ne "E" -and $confirmation -ne "e") {
            Write-Host "Kurulum iptal edildi." -ForegroundColor Yellow
            return
        }
    }
    
    Write-Host "`n--> JDK $version indiriliyor..." -ForegroundColor Cyan
    $apiUrl = "https://api.adoptium.net/v3/assets/feature_releases/$version/ga?architecture=x64&heap_size=normal&image_type=jdk&os=windows&page=0&page_size=1&project=jdk&sort_order=DESC&vendor=eclipse"
    
    try {
        $response = Invoke-RestMethod -Uri $apiUrl -ErrorAction Stop
        
        if ($response.Count -eq 0) {
            Write-Error "Bu sürüm için indirilebilir JDK bulunamadı."
            return
        }
        
        Write-Debug "API response: $($response | ConvertTo-Json -Depth 5)"
        
        if ($null -eq $response -or $response.Count -eq 0) {
            Write-Error "API yanıt vermedi veya sürüm bulunamadı."
            return
        }
        
        $zipUrl = $null
        $jdkName = ""
        $jdkVersion = ""
        
        if ($response[0].binary -ne $null -and $response[0].binary.package -ne $null) {
            $zipUrl = $response[0].binary.package.link
            $jdkName = $response[0].binary.package.name
            
            if ($response[0].version -ne $null -and $response[0].version.semver -ne $null) {
                $jdkVersion = $response[0].version.semver
            } elseif ($response[0].version_data -ne $null) {
                $jdkVersion = $response[0].version_data.semver
            }
        } elseif ($response[0].binaries -ne $null -and $response[0].binaries.Count -gt 0) {
            $zipUrl = $response[0].binaries[0].package.link
            $jdkName = $response[0].binaries[0].package.name
            $jdkVersion = $response[0].version.semver
        } elseif ($response.binaries -ne $null -and $response.binaries.Count -gt 0) {
            $zipUrl = $response.binaries[0].package.link
            $jdkName = $response.binaries[0].package.name
            $jdkVersion = $response.release_name
        }
        
        if ($null -eq $zipUrl) {
            Write-Error "İndirme bağlantısı bulunamadı. API yanıtı değişmiş olabilir."
            Write-Host "API yanıtı: $($response | ConvertTo-Json -Depth 2)" -ForegroundColor Yellow
            return
        }
        
        Write-Host "`nİndiriliyor: $jdkName (Sürüm: $jdkVersion)" -ForegroundColor Cyan
        
        $tempDir = "$env:TEMP\jdk-$version-temp"
        $zipPath = "$env:TEMP\jdk-$version.zip"
        
        # Geçiçi dosyaları sil
        if (Test-Path $tempDir) {
            Remove-Item -Path $tempDir -Recurse -Force
        }
        if (Test-Path $zipPath) {
            Remove-Item -Path $zipPath -Force
        }
        
        New-Item -Path $tempDir -ItemType Directory -Force | Out-Null
        
        Write-Host "JDK dosyası indiriliyor, lütfen bekleyin..." -ForegroundColor Cyan
        
        if ([string]::IsNullOrEmpty($zipUrl)) {
            Write-Error "İndirme URL'si boş veya null. İndirme başlatılamıyor."
            return
        }
        
        try {
            if (Get-Command Start-BitsTransfer -ErrorAction SilentlyContinue) {
                Start-BitsTransfer -Source $zipUrl -Destination $zipPath -DisplayName "JDK $version İndiriliyor"
            } else {
                $ProgressPreference = 'Continue'
                Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing
            }
            
            Write-Host "İndirme tamamlandı!" -ForegroundColor Green
            $global:downloadCompleted = $true
        }
        catch {
            Write-Error "İndirme sırasında hata oluştu: $_"
            $global:downloadCompleted = $false
            return
        }
        
        if (-not $global:downloadCompleted) {
            Write-Error "İndirme başarısız oldu."
            return
        }
        
        if (Test-Path $targetDir) {
            Write-Host "Önceki JDK $version kurulumu temizleniyor..." -ForegroundColor Yellow
            Remove-Item -Path $targetDir -Recurse -Force
        }
        
        Write-Host "JDK paketi çıkartılıyor..." -ForegroundColor Cyan

        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::ExtractToDirectory($zipPath, $tempDir)
        
        $extractedDir = Get-ChildItem -Path $tempDir | Where-Object { $_.PSIsContainer -and $_.Name -like "jdk*" } | Select-Object -First 1
        
        if ($null -eq $extractedDir) {
            Write-Error "Çıkartılan dosyalar içinde JDK dizini bulunamadı."
            return
        }
        
        Move-Item -Path $extractedDir.FullName -Destination $targetDir -Force
        

        Remove-Item -Path $zipPath -Force
        Remove-Item -Path $tempDir -Recurse -Force
        
        Write-Host "`n✅ JDK $version başarıyla kuruldu: $targetDir" -ForegroundColor Green
        
        $setActive = Read-Host "JDK $version sürümünü sistem varsayılanı olarak ayarlamak istiyor musunuz? (E/H)"
        if ($setActive -eq "E" -or $setActive -eq "e") {
            Use-Jdk -version $version
        }
    } catch {
        Write-Error "JDK kurulumu sırasında hata: $_"
    }
}


function Use-Jdk {
    param(
        [Parameter(Mandatory=$true)]
        [string]$version
    )
    
    $javaHome = "$JAVA_DIR\jdk-$version"
    
    if (-not (Test-Path $javaHome)) {
        Write-Error "Belirtilen JDK bulunamadı: $javaHome. Önce Install-Jdk -version $version komutunu çalıştırın."
        return
    }
    
    try {
        # Mevcut PATH'i al
        $currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
        
        # Mevcut JAVA_HOME'u PATH'ten temizle
        $currentJavaHome = [Environment]::GetEnvironmentVariable("JAVA_HOME", "Machine")
        if ($currentJavaHome) {
            $currentPath = $currentPath -replace [regex]::Escape("$currentJavaHome\bin;"), ""
        }
        
        # Yeni JAVA_HOME'u PATH'e ekle
        $newPath = "$javaHome\bin;$currentPath"
        
        # Ortam değişkenlerini ayarla
        [Environment]::SetEnvironmentVariable("JAVA_HOME", $javaHome, "Machine")
        [Environment]::SetEnvironmentVariable("Path", $newPath, "Machine")
        
        # Mevcut PowerShell oturumu için de ortam değişkenlerini güncelle
        $env:JAVA_HOME = $javaHome
        $env:Path = "$javaHome\bin;" + $env:Path
        
        Write-Host "`n✅ JAVA_HOME ve PATH ortam değişkenleri ayarlandı:" -ForegroundColor Green
        Write-Host "JAVA_HOME = $javaHome" -ForegroundColor Cyan
        
        # Java sürümünü kontrol et
        $javaVersion = & "$javaHome\bin\java" -version 2>&1
        Write-Host "`nAktif Java Sürümü:" -ForegroundColor Cyan
        $javaVersion | ForEach-Object { Write-Host $_ -ForegroundColor Gray }
        
        Write-Host "JDK $version aktif olarak ayarlandı"
    }
    catch {
        Write-Error "Ortam değişkenleri ayarlanırken hata oluştu: $_"
    }
}

# Verilen sürüm numarasını doğrular
function Test-ValidVersion {
    param(
        [Parameter(Mandatory=$true)]
        [string]$version
    )
    
    try {
        $response = Invoke-RestMethod -Uri $API_URL -ErrorAction Stop
        $available = $response.available_releases
        
        if ($available -contains [int]$version) {
            return $true
        } else {
            Write-Error "Geçersiz JDK sürümü: $version. Kullanılabilir sürümler için List-Jdks komutunu kullanın."
            return $false
        }
    } catch {
        Write-Error "Sürüm doğrulaması yapılamadı: $_"
        return $false
    }
}

# CLI'i başlat
Initialize-JdkManager
