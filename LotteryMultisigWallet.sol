// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

contract Lotterymultisigwallet{
    address[] public managers;
    address payable public winner;
    address payable[] public participants;
    uint numofownersagreed;
    uint owneragreedcount;
    mapping(address=>bool) ownersvote;

    event Winneraddress(address winner);
    event ownersvotecount(uint ownervotecount);

    constructor(address[] memory owner,uint _ownersagreedcount){
        for(uint i=0;i<owner.length;i++){
            managers.push(owner[i]);
        }
        owneragreedcount=_ownersagreedcount;
    }

    function Toparticipant() public payable{
        require(msg.value >= 1 ether,"Amount Insufficient");
        participants.push(payable(msg.sender));
    }
    
    function viewbalance() public view returns(uint){
        for(uint i=0;i<managers.length;i++){
            if(msg.sender==managers[i]){
                return address(this).balance;
            }
        }
        revert("Not Authorized");
    }

    function winning() public {
        if(ownersagreed()){
        uint num=uint(keccak256(abi.encodePacked(block.difficulty,block.timestamp,participants.length)));
        uint win=num%participants.length;
        winner=participants[win];
        winner.transfer(viewbalance());
        emit Winneraddress(winner);
        participants=new address payable[](0);
        numofownersagreed=0;
        }
        else{
            revert("owners count not reached");
        }      
    } 

    function ownersagreed() public returns(bool){
       for(uint i=0;i<managers.length;i++){
            if(msg.sender==managers[i]){
                if(!ownersvote[msg.sender]){
                    numofownersagreed++;
                    ownersvote[msg.sender]=true;
                }             
            }
       }
       emit ownersvotecount(numofownersagreed);
       return (numofownersagreed >= owneragreedcount);
    }    
}