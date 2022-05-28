pragma solidity ^0.8.10;

import "erc721a/contracts/ERC721A.sol";

contract ShadowsOfForgottenAncestors is ERC721A {
    string public constant NAME = "#SaveUkrainianToken: Save Ukranian Token";
    string public constant SYMBOL = "SUT";
    string public constant FOLK_URI = "ipfs://bafkreiaes7fbuuv7srwth6vge6al7u2lifa2bnc5frgjt2nwgiwdshdqmu";
    uint256 public constant MAX_FOLKS = 150;
    uint256 public constant MAX_FOLKS_PER_HOLDER = 5;
    uint256 public constant PRICE_PER_FOLK = 0.1 ether;
    address public constant UNCHAIN_FUND = 0x10E1439455BD2624878b243819E31CfEE9eb721C;  // https://unchain.fund/
    address public constant TEAM = 0xb1D7daD6baEF98df97bD2d3Fb7540c08886e0299;
    uint256 public constant TEAM_SHARE_PERCENTAGE = 20;  // 80/20 logica della donazione
    uint256 public constant AIRDROP_FOLKS = 3;

    event Donated(uint256 toUnchainFund, uint256 toTeam);

    constructor() ERC721A(NAME, SYMBOL) {}

    function mint(uint256 quantity) external payable {
        require(totalSupply() + quantity <= MAX_FOLKS, "Gente esaurita");
        require(balanceOf(msg.sender) + quantity <= MAX_FOLKS_PER_HOLDER, "Max FOLK per indirizzo raggiunto");
        require(msg.value == PRICE_PER_FOLK * quantity, "Prezzo sbagliato");

        _safeMint(msg.sender, quantity);
    }

    /**
    * airdrop conia AIRDROP_FOLKS numero di FOLK per scopi di marketing e di squadra
    */
    function airdrop() external {
        require(msg.sender == TEAM, "nave russa, vai a farti fottere!");

        _safeMint(msg.sender, AIRDROP_FOLKS);
    }

    /**
    * donare trasferimenti di ether dal contratto al fondo e alla squadra di beneficenza
    * 80% di trasferimenti direttamente all'indirizzo ETH di Unchain Fund (https://unchain.fund/).
    * teamSharePercentage (20%) sostiene il nostro team e continua a sviluppare il progetto #SaveUkrainianFolk
    */
    function donate() external {
        uint256 totalBalance = address(this).balance;
        require(totalBalance > 0 ether, "Il contratto non ha eteri");

        uint256 teamBalance = totalBalance * TEAM_SHARE_PERCENTAGE / 100;  // 20%
        uint256 unchainFundBalance = totalBalance - teamBalance;  // 80%

        (bool successUnchainFundDonate, ) = UNCHAIN_FUND.call{ value: unchainFundBalance }("");
        (bool successTeamDonate, ) = TEAM.call{ value: teamBalance }("");
        require(successUnchainFundDonate && successTeamDonate, "Errore sui trasferimenti");

        emit Donated(unchainFundBalance, teamBalance);
    }

    /**
    * tokenURI restituisce lo stesso URI per ogni tokenId, perché la raccolta contiene un solo tipo di NFT
    */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        return FOLK_URI;
    }
}
