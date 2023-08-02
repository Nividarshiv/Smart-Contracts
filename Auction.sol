//SPDX-License-Identifier:MIT
pragma solidity >=0.5.0 <0.9.0;

contract Auction{
    struct Item{
        uint itemID;
        uint[] tokens;
    }
    struct Person{
        uint personID;
        uint remainingtoken;
        address personaddress;
    }

    mapping(address=>Person) public tokendetails;
    address owner;
    Person[4]  persons;
    Item[3]  items;
    address[3]  winners;
    uint bidcount;
    event WinnerAnonuncement(address indexed Item1winner,address indexed Item2winner,address indexed Item3winner);

    constructor(){
        owner=msg.sender;
        uint[] memory empty;
        items[0]=Item(0,empty);
        items[1]=Item(1,empty);
        items[2]=Item(2,empty);
    }

    function AuctioneerRegister() public payable{
        require(bidcount<persons.length,"Bid count exists");
        persons[bidcount].personID=bidcount;
        persons[bidcount].remainingtoken=5;
        persons[bidcount].personaddress=msg.sender;
        tokendetails[msg.sender]=persons[bidcount];
        bidcount++;
    }

    function ToAuction(uint _item,uint count) public{
        require(tokendetails[msg.sender]. remainingtoken>=count,"You have minimum tokens");
        require(tokendetails[msg.sender]. remainingtoken>0,"There is no remaining token");
        require(_item<items.length,"Specific item does not exist");
        uint balance=tokendetails[msg.sender]. remainingtoken-count;
        tokendetails[msg.sender]. remainingtoken=balance;
        persons[tokendetails[msg.sender].personID].remainingtoken=balance;
        Item storage item=items[_item];
        for(uint i=0;i<count;i++){
            item.tokens.push(tokendetails[msg.sender].personID);
        }
    }
    function Getitemsdetails(uint id) public view returns(Item memory){
        return items[id];
    }
    function GetPersonDetails(uint id) public view returns(Person memory){
        return persons[id];
    }

    function Auctionwinner() public {
        require(msg.sender==owner,"You are not authorized");
        for(uint id=0;id<items.length;id++){
             Item storage item=items[id];
             if(item.tokens.length!=0){
                  uint random=uint(keccak256(abi.encodePacked(block.difficulty,block.timestamp,item.tokens.length)));
             uint num=random%item.tokens.length;
             uint winnerid=item.tokens[num];
             winners[id]=persons[winnerid].personaddress;
            }
        }  
        emit WinnerAnonuncement(winners[0], winners[1], winners[2]);        
    }  

    function Getwinners() public view returns(address[3] memory){
        return winners;
    } 
}