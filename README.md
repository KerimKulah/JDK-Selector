# ☕ JDK-Selector

Windows üzerinde birden fazla Java JDK sürümünü kolayca indirip geçiş yapmanı sağlayan hafif ve pratik bir PowerShell aracı. Sürümler Adoptium (eski adıyla AdoptOpenJDK) üzerinden indirilir.

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

## ⚠️ Yönetici Olarak Çalıştırma Gereksinimi

Uygulamanın düzgün çalışabilmesi için PowerShell'i **Yönetici olarak** çalıştırmanız gerekmektedir.

## 🛠️ PowerShell Script Çalıştırma İzni Verme

Windows PowerShell script'lerinin çalışabilmesi için, `Unrestricted` Execution Policy ayarını yapmanız gerekmektedir. Bunu aşağıdaki komutu PowerShell'e ile yapabilirsiniz:

```powershell
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser
```

## 🚀 Kurulum

1. `JDKSelectorV1.ps1` dosyasını indirin.
2. Çalıştırmak için:
   - PowerShell'i **Yönetici olarak** çalıştırdıktan sonra, dosyanın olduğu dizine gidip aşağıdaki komutları sırasıyla çalıştırın:

     ```powershell
     cd "dosyanın/olduğu/dizin"
       ```
     ```powershell
     ./JDKSelectorV1.ps1
     ```

## ⚡ Alternatif Yöntem: JDKSelectorWrapper.bat
Eğer PowerShell script'inin Set-ExecutionPolicy ayarlarıyla uğraşmak istemiyorsanız ve yönetici olarak çalıştırma ile ilgili bir sorun yaşamak istemiyorsanız, JDKSelectorWrapper.bat dosyasını indirip aynı klasörde bulundurabilirsiniz. Bu .bat dosyasını Yönetici olarak çalıştırarak PowerShell script'inizi kolayca başlatabilirsiniz.


