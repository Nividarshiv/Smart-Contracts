//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0 < 0.9.0;

contract EventOraganizations{
    struct evnt{
        string name;
        string description;
        uint date;
        uint price;
        uint totalticket;
        uint remainingticket;
    }
    uint public time=block.timestamp;
    evnt[] public evnts;
    event TransferedTicket(address from,address to,uint numoftickets);
  
    mapping(address=>mapping(uint=>uint)) public holdticket;

    function createevent(string memory name,string memory description,uint date,uint price,uint toltic) public {
        require(date>block.timestamp,"event cant organize"); 
        evnts.push(evnt({name:name,description:description,date:date,price:price,totalticket:toltic,remainingticket:toltic}));
    }

    function Listofevents() public view returns(evnt[] memory){
        return evnts;
    }

    function Eventticketbook(uint id,uint quantity) public payable{
        require(evnts[id].date!=0,"event not ");
        require(evnts[id].date>block.timestamp,"event completed");
        evnt storage e=evnts[id];
        require(e.remainingticket>=quantity,"ticket booked");
        require(msg.value==(e.price * quantity));
        holdticket[msg.sender][id]+=quantity;
        e.remainingticket-=quantity;
    }
    function transferticket(uint id,uint quantity,address to) public {
        require(evnts[id].date>block.timestamp,"event completed");
        holdticket[msg.sender][id]-=quantity;
        holdticket[to][id]+=quantity;
        emit TransferedTicket(msg.sender,to,quantity);
    }
}