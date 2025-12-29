#!/bin/bash
# ============================================================
# Script de déploiement automatique GitHub + SSH
# Projet  : cloud-pme
# Auteur  : Khalid Pro
# ============================================================

set -e

# === Variables ===
GIT_USER="khalidPro2025"
REPO_NAME="cloud-PME"
SSH_KEY_PATH="$HOME/.ssh/id_ed25519"
SSH_PUB_KEY="$HOME/.ssh/id_ed25519.pub"
SSH_EMAIL="${GIT_USER}@github.com"
REMOTE_URL="git@github.com:${GIT_USER}/${REPO_NAME}.git"
BRANCH="main"

echo ""
echo "[INIT] Déploiement automatique de $REPO_NAME vers GitHub..."
echo "================================================================"

# === Étape 1 : Génération de clé SSH si absente ===
if [ ! -f "$SSH_KEY_PATH" ]; then
    echo "[SSH] Aucune clé trouvée — création d'une nouvelle..."
    ssh-keygen -t ed25519 -C "$SSH_EMAIL" -f "$SSH_KEY_PATH" -N ""
else
    echo "[SSH] Clé SSH existante détectée ($SSH_KEY_PATH)"
fi

# === Étape 2 : Démarrage de l'agent SSH ===
echo "[SSH] Chargement de la clé dans l'agent..."
eval "$(ssh-agent -s)" >/dev/null
ssh-add "$SSH_KEY_PATH"

# === Étape 3 : Test connexion SSH → GitHub ===
echo "[TEST] Vérification de la connexion SSH à GitHub..."
if ssh -T git@github.com 2>&1 | grep -qi "successfully authenticated"; then
    echo "[SSH] Authentification GitHub OK."
else
    echo "[SSH] Connexion échouée !"
    echo "👉 Copie cette clé publique dans GitHub (SSH Keys) :"
    echo "-------------------------------------------------"
    cat "$SSH_PUB_KEY"
    echo "-------------------------------------------------"
    echo "Lien : https://github.com/settings/keys"
    exit 1
fi

# === Étape 4 : Initialisation du dépôt si nécessaire ===
if [ ! -d ".git" ]; then
    echo "[GIT] Initialisation du dépôt Git..."
    git init
    git branch -M "$BRANCH"
fi

# === Étape 5 : Configuration du remote ===
echo "[GIT] Configuration du remote origin..."
if git remote -v | grep -q "$REMOTE_URL"; then
    echo "[GIT] Remote déjà configuré."
else
    git remote remove origin 2>/dev/null || true
    git remote add origin "$REMOTE_URL"
    echo "[GIT] Remote associé : $REMOTE_URL"
fi

# === Étape 6 : Ajout & Commit ===
echo "[GIT] Ajout des fichiers..."
git add .

if git diff-index --quiet HEAD --; then
    echo "[GIT] Aucun changement à commit."
else
    COMMIT_MSG="Deploy cloud-pme - $(date '+%Y-%m-%d %H:%M:%S')"
    echo "[GIT] Commit : $COMMIT_MSG"
    git commit -m "$COMMIT_MSG"
fi

# === Étape 7 : Push ===
echo "[GIT] Push vers GitHub..."
git push -u origin "$BRANCH"

echo ""
echo "================================================================"
echo "Déploiement $REPO_NAME terminé avec succès."
echo "URL GitHub : https://github.com/${GIT_USER}/${REPO_NAME}"
echo "Clé SSH utilisée : $(basename "$SSH_KEY_PATH")"
echo "Date : $(date)"
echo "================================================================"
