# GreenLedger

Plateforme Web3 de suivi d’actions écologiques en entreprise, avec gouvernance interne et système de crédits carbone (`ECO`) sur Ethereum.

![Logo GreenLedger](front/assets/Logo_baniere.png)

## Aperçu

GreenLedger permet à une entreprise de :

- gérer une whitelist d’employés autorisés,
- soumettre des actions écologiques (avec preuve),
- voter entre employés pour valider les actions,
- récompenser automatiquement les actions validées en tokens `ECO`,
- compenser l’empreinte carbone via le rachat puis le burn des crédits.

Le projet inclut :

- un smart contract de gouvernance + token,
- un portail employé,
- un portail administrateur,
- une landing page de présentation.

## Concept et utilité

GreenLedger applique la blockchain à la transition écologique en entreprise : chaque action durable proposée par un employé est tracée, votée, puis récompensée en crédits `ECO` quand elle est validée. Le projet est utile car il crée un cadre transparent et motivant : les contributions environnementales sont vérifiables, la gouvernance est collective, et lorsque l’entreprise dépasse ses objectifs de consommation, elle achète des crédits `ECO` aux employés pour compenser son empreinte carbone, avant de les brûler.


## Structure du projet

```text
GreenLedger/
├── contracts/
│   ├── EcoContract.sol
│   └── GreenCompanyDAO.sol
├── front/
│   ├── index.html        # Landing
│   ├── portail.html      # Interface employé
│   ├── admin.html        # Interface propriétaire/admin
│   └── assets/
│       ├── Logo_baniere.png
│       └── CreditCarbone.png
└── README.md
```

## Fonctionnalités clés

### Côté smart contract

- `ajouterEmploye(address)` : ajoute un employé à la whitelist.
- `soumettreAction(string preuveHash)` : crée une action écologique.
- `voter(uint256 actionId, bool choix)` : vote pour/contre une action.
- Validation automatique d’une action à partir de 3 votes favorables.
- Récompense de l’auteur validé : `10 ECO`.
- `cloturerAnnee()` : applique la réduction du quota et incrémente l’année.
- `compenserEmpreinte(address employe, uint256 montantCredits)` : paie l’employé puis burn les crédits.

### Côté front

- `front/index.html` : page d’accueil du projet.
- `front/portail.html` : connexion MetaMask, soumission d’actions, votes, affichage des stats.
- `front/admin.html` : dashboard owner (whitelist, clôture annuelle, compensation carbone).

## Stack technique

- **Solidity** `^0.8.0`
- **OpenZeppelin** (`ERC20`, `Ownable`)
- **Ethers.js** (chargé via CDN)
- **HTML/CSS/JS** (front statique)
- **MetaMask** pour la signature des transactions

## Prérequis

- Node.js et npm (pour compiler/déployer les contrats)
- Un environnement EVM local ou testnet (Hardhat, Ganache, etc.)
- Extension MetaMask installée sur le navigateur

## Lancement rapide

1. **Déployer le contrat** (`GreenCompanyDAO`) sur votre réseau cible.
2. **Récupérer l’adresse déployée** du contrat.
3. **Mettre à jour l’adresse** dans :
	- `front/admin.html`
	- `front/portail.html`
4. **Servir le dossier `front/`** via un serveur local (éviter `file://`).
	Exemple :

	```bash
	cd front
	python3 -m http.server 5500
	```

5. Ouvrir :
	- `http://localhost:5500/index.html`
	- `http://localhost:5500/portail.html`
	- `http://localhost:5500/admin.html`

## Scénario d’utilisation type

1. L’owner se connecte sur `admin.html`.
2. L’owner ajoute des adresses employées à la whitelist.
3. Un employé soumet une action écologique via `portail.html`.
4. Les employés votent.
5. Si l’action atteint le seuil, l’auteur reçoit des `ECO`.
6. L’owner peut racheter et brûler des crédits pour compenser l’empreinte.

## Remarques

- Les montants de token sont exprimés en base `18 decimals` côté contrat.
- Le prix par crédit dans `compenserEmpreinte` est actuellement fixe dans le code.
- `EcoContract.sol` et `GreenCompanyDAO.sol` contiennent actuellement le même contrat dans ce dépôt.

## Auteur

<b>Jules GUILLAUME</b> <br>
(Projet académique pour un cours sur la blockchain — Institut Mines-Telecom)