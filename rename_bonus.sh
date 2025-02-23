
#!/bin/bash

dossier_principal="."

find "$dossier_principal" -type f \( -name "*.c" -o -name "*.h" \) | while read -r fichier; do
    chemin=$(dirname "$fichier")
    nom=$(basename "$fichier")
    nom_sans_extension="${nom%.*}"
    extension="${nom##*.}"

    nouveau_nom="${nom_sans_extension}_bonus.${extension}"
    nouveau_chemin="${chemin}/${nouveau_nom}"

    mv "$fichier" "$nouveau_chemin"
    echo "Renommé : $fichier -> $nouveau_chemin"
done
