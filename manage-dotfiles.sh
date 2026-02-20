#!/bin/bash

# Konfiguration
DOTFILES_DIR=$(pwd)
HOME_DIR=$HOME
# Basis-Name für Backups
BACKUP_PREFIX="dotfiles_backup_"

# Farben
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Liste der Root-Dateien (ohne .config)
ROOT_FILES=(".gitconfig" ".latexmkrc" ".tmux.conf" ".vimrc" ".zshrc")

# Funktion: Backup-Ordner finden (den neuesten)
find_latest_backup_item() {
    local item_name=$1
    # Suche in allen Backup-Ordnern, absteigend sortiert nach Zeit
    for bdir in $(ls -rd "$HOME_DIR"/${BACKUP_PREFIX}* 2>/dev/null); do
        if [ -e "$bdir/$item_name" ]; then
            echo "$bdir/$item_name"
            return 0
        fi
    done
    return 1
}

# --- INSTALLATION ---
install_dotfiles() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local current_backup_dir="$HOME_DIR/${BACKUP_PREFIX}${timestamp}"
    
    echo -e "${BLUE}Starte Installation...${NC}"

    # Hilfsfunktion für Install
    do_link() {
        local src=$1
        local dest=$2
        local name=$3

        if [ -L "$dest" ]; then
            if [ "$(readlink -f "$dest")" == "$src" ]; then
                echo -e "${GREEN}✓${NC} $name ist bereits korrekt verknüpft."
                return
            fi
        fi

        if [ -e "$dest" ] || [ -L "$dest" ]; then
            echo -e "${YELLOW}!${NC} Backup von $name erstellt."
            mkdir -p "$current_backup_dir"
            mv "$dest" "$current_backup_dir/"
        fi

        ln -s "$src" "$dest"
        echo -e "${GREEN}🔗 Link:${NC} $name verknüpft."
    }

    # Root Dateien verknüpfen
    for file in "${ROOT_FILES[@]}"; do
        [ -f "$DOTFILES_DIR/$file" ] && do_link "$DOTFILES_DIR/$file" "$HOME_DIR/$file" "$file"
    done

    # .config Unterordner verknüpfen
    if [ -d "$DOTFILES_DIR/.config" ]; then
        mkdir -p "$HOME_DIR/.config"
        for config_item in "$DOTFILES_DIR/.config"/*; do
            [ -e "$config_item" ] || continue
            name=$(basename "$config_item")
            do_link "$config_item" "$HOME_DIR/.config/$name" ".config/$name"
        done
    fi
}

# --- UNINSTALL ---
uninstall_dotfiles() {
    echo -e "${BLUE}Starte Deinstallation...${NC}"

    do_uninstall() {
        local repo_src=$1
        local target=$2
        local name=$3

        # Nur handeln, wenn es ein Symlink ist
        if [ -L "$target" ]; then
            # Prüfen, ob der Link wirklich in unser Repo zeigt
            local link_target=$(readlink -f "$target")
            if [[ "$link_target" == "$repo_src"* ]]; then
                echo -e "${YELLOW}Entferne Symlink:${NC} $name"
                rm "$target"

                # Wiederherstellung
                local backup_item=$(find_latest_backup_item "$name")
                if [ -n "$backup_item" ]; then
                    echo -e "${GREEN}Restauriere Backup:${NC} von $(basename $(dirname "$backup_item"))"
                    mv "$backup_item" "$target"
                else
                    echo -e "${BLUE}Kein Backup gefunden.${NC} Kopiere Datei aus Repo nach $target"
                    cp -r "$repo_src" "$target"
                fi
            else
                echo -e "${RED}Skipping:${NC} $name (Symlink zeigt woanders hin: $link_target)"
            fi
        else
            echo -e "${RED}Skipping:${NC} $name (Kein Symlink oder existiert nicht)"
        fi
    }

    # Root Dateien
    for file in "${ROOT_FILES[@]}"; do
        do_uninstall "$DOTFILES_DIR/$file" "$HOME_DIR/$file" "$file"
    done

    # .config Unterordner
    if [ -d "$DOTFILES_DIR/.config" ]; then
        for config_item in "$DOTFILES_DIR/.config"/*; do
            [ -e "$config_item" ] || continue
            name=$(basename "$config_item")
            # Wir müssen hier den relativen Pfad für die Backup-Suche korrekt übergeben
            do_uninstall "$config_item" "$HOME_DIR/.config/$name" "$name"
        done
    fi
}

# --- MAIN ---
case "$1" in
    install)
        install_dotfiles
        ;;
    uninstall)
        uninstall_dotfiles
        ;;
    *)
        echo "Verwendung: $0 {install|uninstall}"
        exit 1
        ;;
esac

echo -e "\n${GREEN}Operation abgeschlossen.${NC}"
