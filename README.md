# 🧰 StarterKit Debian 12 - Instalación Avanzada

Bienvenido al StarterKit para Debian 12. Este kit convierte tu sistema en un laboratorio profesional de programación, arquitectura de software, hacking y privacidad.

Este README está disponible en:

- 🇪🇸 Español
- 🇬🇧 English

---

# 🇪🇸 Español - Documentación Detallada

## Scripts incluidos

| Script | Descripción |
|:-------|:------------|
| `01-setup-base.sh` | Configura base del sistema, actualiza, instala sudo, Nerd Fonts, respalda configuraciones antiguas. |
| `02-setup-zsh.sh` | Instala ZSH, Oh-My-Zsh, plugins modernos, y Powerlevel10k minimalista. |
| `03-setup-terminal.sh` | Instala Alacritty como terminal principal, configura fuentes y tema Gruvbox Dark. |
| `04-setup-brave-browser.sh` | Instala el navegador Brave desde repositorio oficial. |
| `05-setup-tools.sh` | Instala herramientas modernas de terminal: btop, bat, lsd, exa, fzf, glances, etc. |
| `06-setup-dev-tools.sh` | Instala herramientas de desarrollo: git, docker, make, nodejs, build-essential, jq, yq. |
| `07-setup-hacking-pack.sh` | Instala herramientas de hacking: nmap, wireshark, sqlmap, hydra, aircrack-ng, etc. |

## Alias configurados

- `ll`: `lsd -l`
- `la`: `lsd -la`
- `cat`: `bat`
- `grep`: `rg`
- `top`: `btop`
- `g`: `lazygit`
- `term`: `alacritty`

## Elementos visuales

- Terminal: Alacritty.
- Shell: ZSH con Powerlevel10k minimalista.
- Tema de colores: Gruvbox Dark.
- Tipografía: Hack Nerd Font.
- Mensaje MOTD personalizado.

## Requerimientos

- Debian 12 actualizado.
- Usuario "xian" existente.
- Conexión a internet.

## Backup de configuraciones

Todos los archivos `.bashrc`, `.zshrc`, `.profile` originales son respaldados automáticamente en:

- `/home/xian/backups-starterkit/`
- `/root/backups-starterkit/`

## Ejecución recomendada

```bash
sudo bash 01-setup-base.sh
sudo bash 02-setup-zsh.sh
sudo bash 03-setup-terminal.sh
sudo bash 04-setup-brave-browser.sh
sudo bash 05-setup-tools.sh
sudo bash 06-setup-dev-tools.sh
sudo bash 07-setup-hacking-pack.sh
```

---

# 🇬🇧 English - Detailed Documentation

## Included Scripts

| Script | Description |
|:-------|:------------|
| `01-setup-base.sh` | Configures system base, updates, installs sudo, Nerd Fonts, and backs up old configurations. |
| `02-setup-zsh.sh` | Installs ZSH, Oh-My-Zsh, modern plugins, and minimalistic Powerlevel10k theme. |
| `03-setup-terminal.sh` | Installs Alacritty as main terminal, sets up fonts and Gruvbox Dark theme. |
| `04-setup-brave-browser.sh` | Installs Brave browser from official repository. |
| `05-setup-tools.sh` | Installs modern terminal tools: btop, bat, lsd, exa, fzf, glances, etc. |
| `06-setup-dev-tools.sh` | Installs development stack: git, docker, make, nodejs, build-essential, jq, yq. |
| `07-setup-hacking-pack.sh` | Installs hacking tools: nmap, wireshark, sqlmap, hydra, aircrack-ng, etc. |

## Configured Aliases

- `ll`: `lsd -l`
- `la`: `lsd -la`
- `cat`: `bat`
- `grep`: `rg`
- `top`: `btop`
- `g`: `lazygit`
- `term`: `alacritty`

## Visual Elements

- Terminal: Alacritty.
- Shell: ZSH with minimalistic Powerlevel10k.
- Color Theme: Gruvbox Dark.
- Font: Hack Nerd Font.
- Custom MOTD message.

## Requirements

- Updated Debian 12 system.
- "xian" user must exist.
- Active internet connection.

## Backup of configurations

All original `.bashrc`, `.zshrc`, `.profile` files are automatically backed up in:

- `/home/xian/backups-starterkit/`
- `/root/backups-starterkit/`

## Recommended Execution

```bash
sudo bash 01-setup-base.sh
sudo bash 02-setup-zsh.sh
sudo bash 03-setup-terminal.sh
sudo bash 04-setup-brave-browser.sh
sudo bash 05-setup-tools.sh
sudo bash 06-setup-dev-tools.sh
sudo bash 07-setup-hacking-pack.sh
```

---

# 🎉 Fin del README - StarterKit preparado para dominarlos todos 🌍

Listo para expandir con Tor, VPN, y laboratorio de servicios dockerizados en Fase 2. 🚀
