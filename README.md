# GreenLedger

Plateforme de suivi d’actions écologiques en entreprise, avec gouvernance interne et système de crédits carbone (`ECO`) sur Ethereum.

![Logo GreenLedger](front/assets/Logo_baniere.png)

## Aperçu

<p align="center">
  <img src="https://cdn.discordapp.com/attachments/1473616005921116182/1484149072767090698/image.png?ex=69bd2d09&is=69bbdb89&hm=3809b8057449bd790b619ab653828e00242d0697e162ac683981ff011ff719e2" width="70%" alt="Interface" />
  <img src="https://cdn.discordapp.com/attachments/1473616005921116182/1484149090760523997/image1.png?ex=69bd2d0d&is=69bbdb8d&hm=8e90b2423c16a9cd97c6d6050292230dd25003787bf7888e956f461058ff3ade" width="25%" alt="Interface mobile" />
</p>



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

## Sécurité et Gestion des Risques

La sécurité de la plateforme repose sur une architecture de Smart Contracts conçue pour limiter les comportements malveillants tout en garantissant la transparence des actions écologiques. Le système actuel intègre plusieurs barrières de protection, mais présente également des limites inhérentes à son statut de Proof of Concept (PoC).

**Mesures de sécurité implémentées (Ce que propose notre système)**

* **Contrôle d'accès strict (OpenZeppelin) :** L'utilisation du standard `Ownable` garantit que seules les adresses autorisées peuvent exécuter des fonctions critiques. Le jeton `EcoCredit` est strictement possédé par le contrat `GreenCompanyDAO`. Personne, pas même l'administrateur, ne peut "minter" des jetons directement depuis son portefeuille ; seule la logique du contrat peut le faire suite à un vote légitime.
* **Système de Liste Blanche (Whitelist) :** Le modificateur `onlyEmploye` empêche toute adresse externe d'interagir avec la DAO. Seuls les employés préalablement enregistrés par l'entreprise peuvent soumettre des actions ou voter.
* **Protection contre la fraude au vote :** Le contrat utilise un mapping complexe (`aVote`) pour s'assurer qu'un employé ne peut voter qu'une seule fois par action. De plus, une fois le seuil de validation atteint, l'état de l'action est verrouillé (`estValidee = true`), empêchant toute distribution multiple de récompenses pour une même action (double-mint).
* **Sécurisation des flux financiers (ETH) :** Lors de la compensation monétaire, le contrat respecte nativement le design pattern "Checks-Effects-Interactions". Il vérifie les soldes, détruit les jetons (`burn`), puis seulement après, transfère les fonds. Le système intègre également un calcul exact de la monnaie (refund) pour éviter que des Ethers ne restent bloqués indéfiniment dans le contrat.

**Limites actuelles et failles potentielles (Axes d'amélioration)**

Bien que le flux principal soit sécurisé, un déploiement sur le réseau principal (Mainnet) nécessiterait de pallier les vulnérabilités suivantes :

* **Centralisation (Risque du point de défaillance unique) :** Actuellement, le compte administrateur possède les pleins pouvoirs. Si la clé privée de l'admin est compromise, un attaquant pourrait ajouter de faux employés pour manipuler les votes, ou vider les fonds destinés à la compensation. *Solution prévue : Remplacer l'admin unique par un portefeuille multisignature (ex: Gnosis Safe) nécessitant l'accord de plusieurs directeurs.*
* **Risque de collusion (Seuils codés en dur) :** Le seuil de validation est fixé à 3 votes. Si l'entreprise grandit et compte 500 employés, un groupe de 3 personnes malveillantes pourrait s'entendre pour valider de fausses preuves et générer des jetons à l'infini. *Solution prévue : Remplacer le seuil fixe par un quorum dynamique (ex: nécessiter le vote favorable de 10 % des employés inscrits).*
* **Risque théorique de Réentrance :** Bien que l'ordre des instructions dans la fonction `compenserEmpreinte` protège globalement contre les attaques par réentrance, l'utilisation de `.call{value: ...}("")` sans garde explicite reste une pratique auditable. *Solution prévue : Implémenter le modificateur `nonReentrant` (ReentrancyGuard d'OpenZeppelin) sur toutes les fonctions manipulant de l'Ether.*

### Perspectives d'évolution et Déploiement Public

Ce projet constitue une solide preuve de concept (PoC) démontrant la viabilité d'un système de quota carbone interne basé sur la blockchain. Cependant, pour passer d'un environnement local à une application prête pour la production, plusieurs évolutions techniques et fonctionnelles sont envisageables.

**Améliorations fonctionnelles et techniques**

* **Quorum de vote dynamique :** Le système actuel valide une action après 3 votes favorables. Pour une mise à l'échelle, ce seuil fixe devrait être remplacé par un pourcentage dynamique (par exemple, 10 % du nombre total d'employés inscrits dans le contrat) afin de s'adapter à la taille de l'entreprise.
* **Stockage natif IPFS :** Actuellement, l'utilisateur doit fournir un lien ou un hash de preuve. L'intégration d'un SDK Web3 (comme Pinata ou nft.storage) directement dans le frontend permettrait le téléchargement de fichiers (photos, documents PDF) depuis l'interface, avec une génération automatique du hash IPFS stocké ensuite sur la blockchain.
* **Indexation et lecture des événements :** Le frontend boucle actuellement sur les identifiants d'actions pour générer le fil d'actualité. Pour des raisons de performance et de coûts de requêtes (RPC calls), il est recommandé de migrer vers une écoute active des événements du contrat (via Ethers.js) ou d'utiliser un protocole d'indexation décentralisé comme The Graph.
* **Gouvernance décentralisée de l'administration :** Le remplacement du compte administrateur unique par un portefeuille multisignature (MultiSig) sécuriserait les actions critiques, telles que l'ajout de nouveaux employés ou le déclenchement des compensations financières.

**Feuille de route pour un déploiement sur une Blockchain Publique**

Passer de l'environnement de développement local (Ganache) à un réseau public de test (Testnet comme Sepolia) ou principal (Mainnet comme Ethereum ou Base) nécessite les étapes suivantes :

1.  **Configuration d'un nœud RPC :** La blockchain locale n'existant plus, il faut s'appuyer sur un fournisseur d'infrastructure Web3 (comme Alchemy ou Infura) pour obtenir une URL de point de terminaison (endpoint) permettant au frontend et aux scripts de déploiement de communiquer avec le réseau public.
2.  **Configuration des outils de déploiement :** Les frameworks de développement (Hardhat, Foundry ou Truffle) doivent être reconfigurés avec l'URL du nœud RPC et la clé privée du portefeuille administrateur chargé du déploiement.
3.  **Approvisionnement en frais de gaz :** Le déploiement de contrats sur un réseau public a un coût. Pour un Testnet, il faut réclamer des jetons gratuits via un "Faucet". Pour un Mainnet, il faut approvisionner le portefeuille de déploiement avec la cryptomonnaie native du réseau (ex: ETH).
4.  **Vérification du code source :** Une fois les contrats déployés, leur code source doit être publié et vérifié sur l'explorateur de blocs correspondant (comme Etherscan). Cela permet à quiconque de lire le code publiquement et d'interagir avec lui depuis l'explorateur, garantissant ainsi une transparence totale.
5.  **Mise à jour du Frontend :** Les adresses de contrats codées en dur dans les fichiers `admin.html` et `portail.html` doivent être remplacées par les nouvelles adresses publiques. Le frontend devra également vérifier que le réseau détecté dans MetaMask (le Chain ID) correspond bien au réseau de production choisi.

## Remarques

- Les montants de token sont exprimés en base `18 decimals` côté contrat.
- Le prix par crédit dans `compenserEmpreinte` est actuellement fixe dans le code.
- `EcoContract.sol` et `GreenCompanyDAO.sol` contiennent actuellement le même contrat dans ce dépôt.

## Auteur

<b>Jules GUILLAUME</b> <br>
(Projet académique pour un cours sur la blockchain — Institut Mines-Telecom)
