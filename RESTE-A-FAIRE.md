C'est bon, maintenant on peut vectoriser directement depuis la bdd en appelant l'API
ollama en suivant ce qui est décrit dans ce post: https://www.crunchydata.com/blog/accessing-large-language-models-from-postgresql

J'ai déjà créé un fichier generate_embeddings.sh pour remplcer le ficiher py de même nom

Découper le script prepare.sh :
- Créer un script "prepare_ollama" à exécuter après intiialisation du container Ollama
- Créer un script "prepare_db" à exécuter après initialisation de la bdd
