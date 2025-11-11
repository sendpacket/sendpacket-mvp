<h1> SendPacket </h1>

<h2> Pour rouler le projets sur vos machines </h2>

1. Cloner le dépôt :
```
git clone https://github.com/sendpacket/sendpacket.git
```

2. Assurez vous d'avoir installé flutter, vous pouvez checker avec:
```
flutter doctor
```

3. Installer les dépendances :
```
flutter pub get
```
4. runner l'application :
```
flutter run
```
5. Pour mac vous pouvez directement faire:
```
open -a simulator
flutter devices
flutter run -d "iPhone 16e" (mettre dans les guillemets le nom de votre simulateur)
```


<h2>Explication des principaux dossiers</h2>

<h3> core/ </h3>

Contient tout ce qui est générique et réutilisable dans tout le projet:
constants/ → couleurs, typographie, tailles, etc.
utils/ → fonctions d’aide (validation email, formatage, etc.).
services/ → accès à Firebase, stockage, authentification, notifications.


<h3> data/ </h3>

C’est la couche logique métier :
models/ → définition des entités (User, Announcement, Boost, etc.).
repositories/ → interface entre les données (Firestore ou REST API) et la logique UI.


<h3> presentation/ </h3>
C’est la couche visuelle (UI/UX) :
screens/ → toutes les pages.
widgets/ → composants réutilisables.
providers/ → gestion d’état (via Provider ou Riverpod).
themes/ → couleurs et typographies de l’app.
routes/ → navigation entre pages.


<h3>config/ </h3>
Tout ce qui touche à la configuration globale :
Connexion à Firebase,
Gestion des environnements (prod/dev),
Initialisation de l’app.