# ☕ JDK-Selector

**Sürüm: v1.0**

Windows üzerinde birden fazla Java JDK sürümünü kolayca indirip geçiş yapmanı sağlayan hafif ve pratik bir PowerShell aracı. Sürümler Adoptium (eski adıyla AdoptOpenJDK) üzerinden indirilir.<

## 🖼️ Ekran Görüntüsü
![JDK Switcher Kullanım Görseli](https://github.com/user-attachments/assets/c74dbc98-c637-40ee-96eb-1f8d69c667b7)
![JDK Switcher Kullanım Görseli 2](https://github.com/user-attachments/assets/ee29601a-651b-4a00-a803-12cb2cf04658)

## 🔧 Özellikler

- 🔍 `jdk list` – Yüklü JDK sürümlerini listeler
- ⬇️ `install jdk <sürüm>` – Yeni bir JDK sürümünü indirir ve yükler (örnek: 8, 11, 17, 21)
- 🔁 `use jdk <sürüm>` – Aktif JDK sürümünü değiştirir
- 📜 `help` – Tüm komutları listeler
- 🚪 `exit` – Uygulamadan çıkış yapar

## 💻 Gereksinimler

- Windows 10 veya 11
- PowerShell 5.1+ veya PowerShell Core 7+
- `curl` komutu (Windows 10+ sürümlerde yerleşik olarak gelir)

## 🚀 Kurulum

1. Bu repoyu klonlayın ya da sadece `JDKSelectorV1.ps1` dosyasını indirin.
2. Çalıştırmak için:
   - Dosyaya sağ tıklayıp **“Run with PowerShell”** seçeneğini kullanın, ya da
   - PowerShell terminalinden aşağıdaki komutu çalıştırın:
     ```powershell
     ./JDKSelectorV1.ps1
     ```

## 🧪 Örnek Kullanım

```powershell
> jdk list
> install jdk 17
> use jdk 17
