# XII. Conclusion

## Ce que le projet a livré

HealthAI Coaching est une application complète, organisée en couches, qui va de l'import de fichiers hétérogènes jusqu'à des recommandations personnalisées, avec les outils pour l'exploiter : une base relationnelle de vingt tables documentée du conceptuel au physique, un pipeline d'import qui trace chaque ligne et chaque décision de qualité, une API sécurisée à trois rôles documentée par OpenAPI, trois espaces d'interface, un moteur de recommandations explicable enrichi par un modèle local, une persistance documentaire tolérante aux pannes, une intégration continue, une supervision et des sauvegardes. Trois jurys l'ont validée, bloc après bloc.

## Ce dont je suis satisfait

La séparation en couches a tenu à l'usage. Le remplacement de Hugging Face par Gemini, puis l'ajout d'Ollama, se sont faits dans `services/` sans toucher aux routes ni aux schémas ; c'est la preuve que l'architecture n'était pas un dessin de soutenance.

Le mode dégradé est démontrable en direct. Arrêter MongoDB pendant une démonstration et voir l'application continuer, `/health` le signaler, puis tout revenir au redémarrage, est l'argument le plus convaincant que j'ai présenté à un jury.

Le moteur de recommandations refuse de faire ce qu'il ne doit pas faire, et il le dit. Sur des données de santé, une exclusion expliquée vaut mieux qu'une suggestion brillante et opaque.

Enfin, le schéma de base de données de février a survécu à trois lots sans refonte : les index composés et les politiques d'intégrité prévus au départ sont ceux qu'utilisent encore les tableaux de bord et le moteur.

## Ce qui m'a coûté

La gestion du temps. Sans jalons intermédiaires, chaque lot s'est terminé dans des journées trop denses, et la réécriture NestJS du 26 avril est le prix visible de cette absence de cadrage. Le jeu d'essai de la section IX a révélé trois écarts qu'un plan de tests plus systématique aurait trouvés avant la soutenance.

Les sorties des modèles de langage. Obtenir du JSON valide, stable et pertinent d'un modèle d'un milliard de paramètres a demandé plus d'itérations que n'importe quelle autre partie du projet, et la solution finale (mode JSON, température basse, sélection dans un catalogue filtré, repli déterministe) est autant une contrainte d'architecture qu'une technique de prompt.

La coordination sur plusieurs dépôts. Deux lignées de code ont divergé en juin ; la version de référence n'est pas celle où mes commits sont les plus visibles, et une partie de mon travail (PyJWT, contrôle des secrets) revient dans ce dossier sous forme de maintenance plutôt que de livraison initiale.

## Ce que je ferais différemment

Un seul dépôt et des branches dès le premier jour. Un jalonnement daté par périmètre, même sommaire. Des maquettes avant les écrans, ne serait-ce que pour fixer le vocabulaire de l'interface. Un plan de tests écrit avant le code des règles métier, puisque ce sont elles qui portent le risque. Et le déploiement continu dès le lot 1, avec un serveur modeste : la marche manquante de la compétence C11 aurait été franchie sans effort si elle avait été prise au début plutôt qu'en fin de projet.

## Perspectives

À court terme, la branche `cda/security-hardening` : PyJWT, Argon2id ou 600 000 itérations, échec au démarrage sur secret faible, restriction de `/metrics`, seuil de pertinence nutritionnelle, durées de séance cohérentes. Puis la publication d'une image et un déploiement déclenché manuellement sur un serveur derrière un reverse proxy TLS.

À moyen terme : tests de bout en bout Playwright sur les trois parcours, table de correction du catalogue d'exercices, planification et externalisation des sauvegardes, analyse d'impact RGPD et hébergement HDS pour envisager un usage réel.

## Ce que le projet m'a appris

Qu'un concepteur développeur d'applications n'est pas jugé sur ce qu'il sait écrire mais sur ce qu'il sait expliquer, tester et maintenir. Que dire « nous n'avons pas entraîné de modèle » ou « le déploiement continu n'existe pas » devant un jury, avec les raisons, vaut mieux qu'une slide floue. Et que les données de santé imposent une discipline — minimiser, cloisonner, expliquer, garder en local — qui finit par améliorer toute la conception, pas seulement la sécurité.
