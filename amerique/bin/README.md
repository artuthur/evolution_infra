### `bin/`, `ext/`, `lib/`

Les programmes directement exécutables (scripts shell, perl, binaire, etc.) éventuellement crée doivent être stockés dans `bin/`. Ils doivent éviter d'avoir des dépendances externes. Si c'est inévitable le programme doit utiliser une copie locale (placée dans `lib/` par exemple) et sa disponibilité accessibilité doit être vérifiable par le script check-tools.

Les archives récupérées contenant des programmes ou librairies extérieurs doivent être stockés dans `ext/`.

Pour chaque fichier du répertoire `ext/` il doit correspondre une ligne dans le fichier `ext/SOURCES`. Cette ligne doit comporter l'URL ayant permis la récupération du fichier.