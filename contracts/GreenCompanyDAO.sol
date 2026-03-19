// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// --- CONTRAT TOKEN ---
contract EcoCredit is ERC20, Ownable { //EcoCredit hérite de ERC20 et Ownable (qui sont gérés parr la libr OpenZeppelin) ça donne accès à la méthode OnlyOwner
    // Le constructeur demande l'adresse de l'owner initial
    constructor(address initialOwner) ERC20("EcoCredit", "ECO") Ownable(initialOwner) {}

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external onlyOwner {
        _burn(from, amount);
    }
}

// --- CONTRAT DAO ---
contract GreenCompanyDAO is Ownable {
    
    EcoCredit public token; 
    
    uint256 public quotaActuel;
    uint256 public pourcentageBaisse;
    uint256 public anneeActuelle;
    uint256 public actionCount;

    struct Action {
        uint256 id;
        address auteur;
        string preuveHash;
        uint256 votesPour;
        uint256 votesContre;
        bool estValidee;
    }

    mapping(address => bool) public isEmploye;
    mapping(uint256 => Action) public actions;
    mapping(uint256 => mapping(address => bool)) public aVote; 

    event EmployeAjoute(address employe);
    event ActionSoumise(uint256 id, address auteur);
    event A_Vote(uint256 idAction, address votant, bool choix);
    event ActionValidee(uint256 id, address auteur, uint256 recompense);
    event AnneeCloturee(uint256 nouvelleAnnee, uint256 nouveauQuota);
    event CompensationRealisee(uint256 creditsBrules);

    // Le constructeur de la DAO initialise aussi Ownable
    constructor(uint256 _quotaInitial, uint256 _pourcentageBaisse) Ownable(msg.sender) {
        token = new EcoCredit(address(this));
        
        quotaActuel = _quotaInitial;
        pourcentageBaisse = _pourcentageBaisse;
        anneeActuelle = 1;
        actionCount = 0;
    }

    modifier onlyEmploye() {
        require(isEmploye[msg.sender], "Access refused : You are not on the whitelist");
        _;
    }

    function ajouterEmploye(address _employe) external onlyOwner {
        require(_employe != address(0), "Error : Invalid address");
        require(!isEmploye[_employe], "Error : Employee already on the whitelist");
        isEmploye[_employe] = true;
        emit EmployeAjoute(_employe);
    }

    function cloturerAnnee() external onlyOwner {
        uint256 new_quota = (quotaActuel * pourcentageBaisse) / 100;
        quotaActuel -= new_quota;
        anneeActuelle++;
        emit AnneeCloturee(anneeActuelle, quotaActuel);
    }

    function soumettreAction(string calldata _preuveHash) external onlyEmploye {
        actionCount++;
        actions[actionCount] = Action({
            id: actionCount,
            auteur: msg.sender,
            preuveHash: _preuveHash,
            votesPour: 0,
            votesContre: 0,
            estValidee: false
        });
        emit ActionSoumise(actionCount, msg.sender);
    }

    function voter(uint256 _actionId, bool _choix) external onlyEmploye {
        Action storage actionCourante = actions[_actionId];

        require(_actionId > 0 && _actionId <= actionCount, "Action does not exists");
        require(!aVote[_actionId][msg.sender], "Action has already been voted");
        require(!actionCourante.estValidee, "Action has already been validated");
        
        aVote[_actionId][msg.sender] = true;

        if (_choix == true) {
            actionCourante.votesPour++;
        } else {
            actionCourante.votesContre++;
        }

        emit A_Vote(_actionId, msg.sender, _choix);

        if (actionCourante.votesPour >= 3) {
            actionCourante.estValidee = true;
            
            uint256 recompense = 10 * 10**18;
            token.mint(actionCourante.auteur, recompense);
            
            emit ActionValidee(_actionId, actionCourante.auteur, recompense);
        }
    }

    function compenserEmpreinte(address _employe, uint256 _montantCredits) external payable onlyOwner {
        uint256 prixParCreditEnWei = 0.5 ether; 
        uint256 coutTotalEnWei = (_montantCredits / 10**18) * prixParCreditEnWei;

        require(isEmploye[_employe], "Seller is not an employee");
        require(msg.value >= coutTotalEnWei, "ETH sold insuffisant");
        require(token.balanceOf(_employe) >= _montantCredits, "Employee has not enough CarbonCredit");

        // Destruction des jetons avant l'envoi des fonds (prévention de réentrance basique)
        token.burn(_employe, _montantCredits);

        // Paiement de l'employé
        (bool success, ) = payable(_employe).call{value: coutTotalEnWei}("");
        require(success, "Error : transaction has failed");

        uint256 reste = msg.value - coutTotalEnWei;
        if (reste > 0) {
            (bool refundSuccess, ) = payable(msg.sender).call{value: reste}("");
            require(refundSuccess, "Error : remboursement has failed");
        }

        emit CompensationRealisee(_montantCredits);
    }
}
