// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IFakeNFTMarketplace} from "./Interfaces/IFakeNFTMarketPlace.sol";
import {ICryptoDevsNFT} from "./Interfaces/ICryptoDevsNFT.sol";

contract CryptoDevsDAO is Ownable {
    error CryptoDevsDAO__NotADAOMember(uint256 usersBalance);
    error CryptoDevsDAO__DeadlineExceeded();
    error CryptoDevsDAO__DeadlineNotExceeded();
    error CryptoDevsDAO__ProposalAlreadyExecuted();
    error CryptoDevsDAO__NFTNotForSale();
    error CryptoDevsDAO__AlreadyVoted();

    IFakeNFTMarketplace nftMarketplace;
    ICryptoDevsNFT cryptoDevsNFT;

    constructor(address _nftMarketplace, address _cryptoDevsNFT) payable {
        nftMarketplace = IFakeNFTMarketplace(_nftMarketplace);
        cryptoDevsNFT = ICryptoDevsNFT(_cryptoDevsNFT);
    }

    modifier nftHolderOnly() {
        if (cryptoDevsNFT.balanceOf(msg.sender) < 1)
            revert CryptoDevsDAO__NotADAOMember(
                cryptoDevsNFT.balanceOf(msg.sender)
            );
        _;
    }

    modifier activeProposalOnly(uint256 proposalIndex) {
        if (proposals[proposalIndex].deadline < block.timestamp)
            revert CryptoDevsDAO__DeadlineExceeded();

        _;
    }

    modifier inactiveProposalOnly(uint256 proposalIndex) {
        if (proposals[proposalIndex].deadline > block.timestamp)
            revert CryptoDevsDAO__DeadlineNotExceeded();
        if (proposals[proposalIndex].executed == true)
            revert CryptoDevsDAO__ProposalAlreadyExecuted();

        _;
    }

    enum Vote {
        YAY, // YAY = 0
        NAY // NAY = 1
    }

    /**
     * @notice nftTokenId - the tokenID of the NFT to purchase from FakeNFTMarketplace if the proposal passes
     * @notice deadline - the UNIX timestamp until which this proposal is active. Proposal can be executed after the deadline has been exceeded.
     * @notice   yayVotes - number of yay votes for this proposal
     * @notice nayVotes - number of nay votes for this proposal
     * @notice executed - whether or not this proposal has been executed yet. Cannot be executed before the deadline has been exceeded.
     * @notice voters - a mapping of CryptoDevsNFT tokenIDs to booleans indicating whether that NFT has already been used to cast a vote or not
     */
    struct Proposal {
        uint256 nftTokenId;
        uint256 deadline;
        uint256 yayVotes;
        uint256 nayVotes;
        bool executed;
        mapping(uint256 => bool) voters;
    }

    // Create a mapping of ID to Proposal
    mapping(uint256 => Proposal) public proposals;
    // Number of proposals that have been created
    uint256 public numProposals;

    /**
     * @dev createProposal allows a CryptoDevsNFT holder to create a new proposal in the DAO
     * @param _nftTokenId - the tokenID of the NFT to be purchased from FakeNFTMarketplace if this proposal passes
     * @return Returns the proposal index for the newly created proposal
     */
    function createProposal(
        uint256 _nftTokenId
    ) external nftHolderOnly returns (uint256) {
        if (!nftMarketplace.available(_nftTokenId))
            revert CryptoDevsDAO__NFTNotForSale();
        Proposal storage proposal = proposals[numProposals];
        proposal.nftTokenId = _nftTokenId;
        proposal.deadline = block.timestamp + 5 minutes;

        numProposals++;

        return numProposals - 1;
    }

    /**
     *
     *  @dev voteOnProposal allows a CryptoDevsNFT holder to cast their vote on an active proposal
     *  @param proposalIndex - the index of the proposal to vote on in the proposals array
     *  @param vote - the type of vote they want to cast
     */

    function voteOnProposal(
        uint256 proposalIndex,
        Vote vote
    ) external nftHolderOnly activeProposalOnly(proposalIndex) {
        Proposal storage proposal = proposals[proposalIndex];

        uint256 voterNFTBalance = cryptoDevsNFT.balanceOf(msg.sender);
        uint256 numVotes = 0;

        for (uint256 i = 0; i < voterNFTBalance; i++) {
            uint256 tokenId = cryptoDevsNFT.tokenOfOwnerByIndex(msg.sender, i);
            if (proposal.voters[tokenId] == false) {
                numVotes++;
                proposal.voters[tokenId] = true;
            }
        }

        if (numVotes < 1) revert CryptoDevsDAO__AlreadyVoted();

        if (vote == Vote.YAY) {
            proposal.yayVotes += numVotes;
        } else {
            proposal.nayVotes += numVotes;
        }
    }

    /**
     * @dev executeProposal allows any CryptoDevsNFT holder to execute a proposal after it's deadline has been exceeded
     * @param proposalIndex - the index of the proposal to execute in the proposals array
     */
    function executeProposal(
        uint256 proposalIndex
    ) external nftHolderOnly inactiveProposalOnly(proposalIndex) {
        Proposal storage proposal = proposals[proposalIndex];

        if (proposal.yayVotes > proposal.nayVotes) {
            uint256 nftPrice = nftMarketplace.getPrice();
            require(address(this).balance >= nftPrice, "NOT_ENOUGH_FUNDS");
            nftMarketplace.purchase{value: nftPrice}(proposal.nftTokenId);
        }
        proposal.executed = true;
    }

    /**
     * @dev withdrawEther allows the contract owner (deployer) to withdraw the ETH from the contract
     */
    function withdrawEther() external onlyOwner {
        uint256 amount = address(this).balance;
        require(amount > 0, "Nothing to withdraw, contract balance empty");
        (bool sent, ) = payable(owner()).call{value: amount}("");
        require(sent, "FAILED_TO_WITHDRAW_ETHER");
    }

    /**
     * @notice The following two functions allow the contract to accept ETH deposits
     * directly from a wallet without calling a function
     */
    receive() external payable {}

    fallback() external payable {}
}
