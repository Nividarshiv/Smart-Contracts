//SPDX-License-Identifier:MIT
pragma solidity >=0.5.0 <0.9.0;

contract Crowdfund{
    address manager;
    uint public deadline;
    uint target;

    struct Request{
        address payable recepient;
        string description;
        uint value;
        uint noofvoters;
        bool statusofcompletion;
        mapping(address=>bool) voterresult;
    }

    mapping(uint=>Request) public requests;
    mapping(address=>uint) doners;
    uint Requestcount;
    uint noofcontributors;
    constructor(uint _target,uint _deadline){
        manager=msg.sender;
        target=_target;
        deadline=block.timestamp+_deadline;
    }

    modifier ManagerOnly(){
        require(manager==msg.sender,"Only the manager can access");
        _;
    }

    function createRequest(address payable recepientaddress,string memory _description,uint amount) public ManagerOnly{
        Request storage request=requests[Requestcount];
        Requestcount++;
        request.recepient=recepientaddress;
        request.description=_description;
        request.value=amount;
        request.noofvoters=0;
        request.statusofcompletion=false;
    }

    function Tocontribute() public payable{
        require(block.timestamp<deadline,"Time period overed");
        require(msg.value>1000 wei,"Amount is too low");
        if(doners[msg.sender]==0){
            noofcontributors++;
        }
        doners[msg.sender]+=msg.value;
    }

    function GetBalance() public view returns(uint){
        return address(this).balance;
    }

    function Tovote(uint id) public {
        require(doners[msg.sender]>0,"Only contributor can vote");
        Request storage req=requests[id];
        require(req.voterresult[msg.sender]==false,"Already voted for this requester");
        req.noofvoters++;
        req.voterresult[msg.sender]==true;
    }

    function SendAmount(uint id) public ManagerOnly{
        require(GetBalance()>target,"Insufficient Amount");
        Request storage req=requests[id];
        require(req.statusofcompletion==false,"Fund has sent");
        require(req.noofvoters>=noofcontributors/2,"Majority not supported");
        req.statusofcompletion=true;
        req.recepient.transfer(req.value);
    }

    function refund() public{
        require(block.timestamp>deadline && GetBalance()<target,"No refund rightnow");
        payable(msg.sender).transfer(doners[msg.sender]);
        doners[msg.sender]=0;
    }
}