# NutriScan Mobile

Application mobile Flutter qui sert d’interface utilisateur à ton backend Django.

Le but de l’application est de permettre à l’utilisateur de :

- se connecter ou créer un compte,
- consulter et modifier son profil,
- voir ses produits enregistrés,
- prendre une photo ou importer une image depuis la galerie,
- lancer une segmentation quand plusieurs produits apparaissent sur la photo,
- sélectionner un ou plusieurs produits détectés,
- envoyer ces produits au backend Django pour l’analyse,
- afficher les ingrédients détectés dans l’écran de test,
- enregistrer un produit analysé dans la base si l’utilisateur le souhaite,
- personnaliser le profil avec des allergies et des informations libres.

La logique de risque et de recommandation n’est pas encore intégrée dans l’app mobile. Elle reste côté backend pour une phase ultérieure.

## Stack

- Flutter
- `http` pour les appels API
- `provider` pour l’état global
- `flutter_secure_storage` pour conserver le token de connexion
- `image_picker` pour la caméra et la galerie
- `google_fonts` pour l’identité visuelle

## Architecture

Le code source principal se trouve dans `lib/src/`.

- `app.dart` : point d’entrée applicatif et bootstrap
- `app_shell.dart` : navigation principale avec les 4 onglets
- `app_controller.dart` : état global, auth, profils, produits
- `services/api_client.dart` : client HTTP pour Django
- `services/auth_store.dart` : stockage sécurisé du token
- `screens/login_screen.dart` : connexion et inscription
- `screens/home_screen.dart` : tableau de bord d’accueil
- `screens/scan_screen.dart` : caméra, galerie et lancement du scan
- `screens/segmentation_screen.dart` : sélection des produits segmentés
- `screens/scan_result_screen.dart` : résultat simplifié avec les ingrédients
- `screens/products_screen.dart` : page "Mes produits"
- `screens/profile_screen.dart` : page profil utilisateur

## Communication avec Django

L’application mobile appelle les endpoints Django en local par défaut.

- Base URL Web/desktop/iOS simulator : `http://127.0.0.1:8000`
- Base URL Android emulator : `http://10.0.2.2:8000`
- Base URL configurable via `API_BASE_URL`

En développement local, le backend Django accepte aussi les requêtes depuis Flutter Web sur `localhost` et `127.0.0.1`.

Endpoints utilisés :

- `POST /api/users/auth/register/`
- `POST /api/users/auth/login/`
- `GET /api/users/me/`
- `PATCH /api/users/me/`
- `GET /api/users/allergies/`
- `GET /api/users/me/allergies/`
- `PATCH /api/users/me/allergies/`
- `POST /api/users/allergies/`
- `GET /api/products/`
- `POST /api/products/`
- `POST /api/scan/segment/`
- `POST /api/scan/selected/`
- `POST /api/scan/`

## Lancer le projet

### 1. Installer les dépendances Flutter

Depuis le dossier `app_mobile` :

```bash
flutter pub get
```

### 2. Vérifier le backend Django

L’API Django doit être lancée localement sur le port 8000.

```bash
cd ../App_Django
python manage.py runserver
```

### 3. Lancer l’application mobile

```bash
cd ../app_mobile
flutter run
```

Si tu testes sur Chrome ou sur un autre client desktop, l’app mobile parle au backend via `127.0.0.1:8000`.

Si tu testes sur un émulateur Android, l’app mobile parle au backend via `10.0.2.2:8000`.

### 4. Changer l’URL du backend si besoin

Pour pointer vers un autre backend, comme ngrok plus tard :

```bash
flutter run --dart-define=API_BASE_URL=https://ton-url.ngrok-free.app
```

Si tu veux forcer le backend local en web, tu peux aussi lancer :

```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

Si tu veux tester sur Android émulateur, garde la valeur par défaut ou force explicitement :

```bash
flutter run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

## Flux utilisateur

1. L’utilisateur ouvre l’app et se connecte ou crée un compte.
2. L’écran d’accueil affiche un résumé rapide et les accès aux zones principales.
3. L’onglet Scan permet de prendre une photo ou d’importer une image.
4. Si plusieurs produits sont détectés, l’écran de segmentation permet d’en sélectionner un ou plusieurs.
5. Le backend renvoie les résultats d’analyse.
6. L’écran de test affiche les ingrédients détectés et propose un bouton pour enregistrer le produit si l’utilisateur le souhaite.
7. Les onglets Profil et Mes produits permettent de gérer les informations utilisateur, les allergies, les notes libres et les produits associés.

## Commandes utiles

```bash
flutter analyze
flutter test
flutter run
```

## Remarques

- La page de test n’affiche pas le JSON complet, uniquement les ingrédients.
- Le backend supporte déjà le login, le profil courant, les allergies utilisateur et les produits rattachés à l’utilisateur.
- La base URL est centralisée pour faciliter le passage de local à ngrok plus tard.
