**Nome del Repository Git:** `SSL-Certificate-Generator`

---

### README.md

**Italiano:**

```markdown
# Generatore di Certificati SSL

Questo progetto include uno script bash interattivo per creare e configurare certificati SSL personalizzati per domini specifici. Lo script ti guiderà passo dopo passo, chiedendoti le informazioni necessarie e permettendoti di configurare automaticamente i server Apache o Nginx, se lo desideri.

## Funzionalità

- Generazione di una Certificate Authority (CA) locale
- Creazione di chiavi private e richieste di firma (CSR) per server
- Firma dei certificati con il CA locale
- Configurazione automatica del server web (Apache o Nginx)
- Aggiunta dei certificati alla store del sistema

## Requisiti

- Linux con privilegi `sudo`
- Server Apache o Nginx (opzionale)
- Pacchetti necessari: `openssl`, `ca-certificates`

## Utilizzo

1. **Clona il repository:**
   ```bash
   git clone https://github.com/tuo-username/SSL-Certificate-Generator.git
   cd SSL-Certificate-Generator
   ```

2. **Rendi eseguibile lo script:**
   ```bash
   chmod +x crea_certificato.sh
   ```

3. **Esegui lo script come root o con `sudo`:**
   ```bash
   sudo ./crea_certificato.sh
   ```

4. Segui le istruzioni sullo schermo per generare i certificati SSL e configurare il server.

## Contribuire

Siamo aperti ai contributi! Sentiti libero di fare una pull request o aprire issue per miglioramenti e suggerimenti.

---

**English:**

```markdown
# SSL Certificate Generator

This project provides an interactive bash script for creating and configuring custom SSL certificates for specific domains. The script guides you step-by-step, asking for necessary information and optionally setting up Apache or Nginx servers to use the generated SSL certificates.

## Features

- Generate a local Certificate Authority (CA)
- Create private keys and Certificate Signing Requests (CSR) for servers
- Sign server certificates with the local CA
- Automatically configure the web server (Apache or Nginx)
- Add certificates to the system's trusted store

## Requirements

- Linux with `sudo` privileges
- Apache or Nginx server (optional)
- Required packages: `openssl`, `ca-certificates`

## Usage

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/SSL-Certificate-Generator.git
   cd SSL-Certificate-Generator
   ```

2. **Make the script executable:**
   ```bash
   chmod +x crea_certificato.sh
   ```

3. **Run the script as root or with `sudo`:**
   ```bash
   sudo ./crea_certificato.sh
   ```

4. Follow the on-screen instructions to generate SSL certificates and configure your server.

## Contribute

We welcome contributions! Feel free to open a pull request or create issues for improvements and suggestions.
``` 

