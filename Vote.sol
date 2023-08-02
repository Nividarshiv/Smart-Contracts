//SPDX-License-Identifier:MIT
pragma solidity >=0.5.0 <0.9.0;

contract Voting{
    struct voterdetail{
        uint weight;
        bool votedornot;
        uint Towhom;
    }
    struct Candidate{
        string name;
        uint votecount;
    }

    enum Stages{
        Init,Reg,Vote,Done
    }
    Stages stages=Stages.Init;
    address chairperson;
    mapping(address=>voterdetail) voters;
    Candidate[] public candidates;
    uint timestamp;
    event voteCompleted(string result);

    modifier validstages(Stages reqstage){
        require(stages==reqstage);
        _;
    }

    constructor(string[] memory _name){
        chairperson=msg.sender; 
        voters[msg.sender].weight=1;
        for(uint i=0;i<_name.length;i++){
            candidates.push(Candidate(_name[i],0));
        }
        timestamp=block.timestamp;
        stages=Stages.Reg;
    }

    function voteRegister(address _voter) public validstages(Stages.Reg){
        require(msg.sender==chairperson,"Not authorized");
        require(voters[_voter].votedornot==false,"Already voted");
        voters[_voter].weight=1;
        voters[_voter].votedornot=false;
        if(block.timestamp>(timestamp+30 seconds)){
            stages=Stages.Vote;
        }
    }

    function Tovote(uint _towhom) public validstages(Stages.Vote){
        require(_towhom<candidates.length,"There is no proposals");
        require(voters[msg.sender].votedornot==false,"Already voted");
        candidates[_towhom].votecount+=voters[msg.sender].weight;
        voters[msg.sender].votedornot=true;
        voters[msg.sender].Towhom=_towhom;
        if(block.timestamp>(timestamp+70 seconds)){
            stages=Stages.Done;
            emit voteCompleted("Vote Time completed");
        }
    }

    function Winniner() public validstages(Stages.Done) view returns(string memory winnername)  {
        uint wincount=0;   
        for(uint i=0;i<candidates.length;i++){
            if(wincount<candidates[i].votecount){
                wincount=candidates[i].votecount;
                winnername=candidates[i].name;                           
            }
        }     
    }
}