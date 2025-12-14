#!/bin/bash
# Script pour nettoyer les métadonnées Finder du framework Flutter
# Ce script est exécuté avant la signature de code

FLUTTER_FRAMEWORK_PATH="${BUILT_PRODUCTS_DIR}/Flutter.framework/Flutter"

if [ -f "$FLUTTER_FRAMEWORK_PATH" ]; then
    echo "Nettoyage des métadonnées Finder du framework Flutter..."
    xattr -cr "$FLUTTER_FRAMEWORK_PATH" 2>/dev/null || true
    echo "Métadonnées nettoyées"
fi

