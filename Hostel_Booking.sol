// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Hostel{
    address payable landlord;

    uint public no_of_rooms;
    uint public no_of_aggrement;
    uint public no_of_rent;

    struct Room{
        uint roomid;
        uint agreementid;
        string roomname;
        string roomaddress;
        uint rent_per_month;
        uint securitydeposite;
        uint timestamp;
        bool vacant;
        address payable landlord;
        address payable currentTenant;
    }
    mapping(uint=>Room) public Room_By_No;

    struct RoomAgreement{
        uint roomid;
        uint agreementid;
        string roomname;
        string roomaddress;
        uint rent_per_month;
        uint securitydeposite;
        uint timestamp;
        uint lockInperiod;    
        address payable landlord;
        address payable currentTenant;
    }
    mapping(uint=>RoomAgreement) public RoomAgreement_By_No;

    struct Rent{
        uint rentno;
        uint roomid;
        uint agreementid;
        string roomname;
        string roomaddress;
        uint rent_per_month;
        uint timestamp;
        address payable landlord;
        address payable currentTenant;
    }
    mapping(uint=>Rent) public Rent_By_No;
    
    constructor(){
        landlord=payable(msg.sender);
    }

    modifier onlyLandlord(uint _index){
        require(msg.sender==Room_By_No[_index].landlord,"Only landlord can access this");
        _;
    }
    modifier notLandlord(uint _index){
        require(msg.sender!=Room_By_No[_index].landlord,"Only Tenant can access this");
        _;
    }
    modifier onlywhileVacant(uint _index){
        require(Room_By_No[_index].vacant==true,"Room is currently occupied");
        _;
    }
    modifier enoughRent(uint _index){
        require(msg.value>=Room_By_No[_index].rent_per_month,"Not enough room rent");
        _;
    }
    modifier enoughAgreementfee(uint _index){
        require(msg.value >= Room_By_No[_index].rent_per_month + Room_By_No[_index].securitydeposite,"Not enough to secutity deposite");
        _;
    }
    modifier sameTenant(uint _index){
        require(msg.sender == Room_By_No[_index].currentTenant,"The room occupied by another tenant");
        _;
    }
    modifier AgreementTimesLeft(uint _index){
        uint _AgreementNo=Room_By_No[_index].agreementid;
        uint time=RoomAgreement_By_No[_AgreementNo].lockInperiod;
        require(block.timestamp < time,"Agreement time ended");
        _;
    }
    modifier AgreementTimesUp(uint _index){
        uint _AgreementNo=Room_By_No[_index].agreementid;
        uint time=RoomAgreement_By_No[_AgreementNo].lockInperiod;
        require(block.timestamp > time,"Agreement time left");
        _;
    }

    modifier RentTimeUp(uint _index){
        uint time=Room_By_No[_index].timestamp+30 days;
        require(block.timestamp>=time,"Time Left to pay Rent");
        _;
    }

    function addRoom(string memory _roomname,string memory _roomaddress,uint _rentcost,uint _securitydeposite) public {
        require(msg.sender!=address(0),"landlord address is needed");
        no_of_rooms++;
        Room_By_No[no_of_rooms]=Room(no_of_rooms,0,_roomname, _roomaddress,_rentcost, _securitydeposite,0,true,payable(msg.sender),payable(address(0)));
    }

    function singagreement(uint _index) public payable notLandlord(_index) onlywhileVacant(_index) enoughAgreementfee(_index){
        require(msg.sender!=address(0),"Tenant address should be there");
        address payable _landlord=Room_By_No[_index].landlord;
        uint totalfee=Room_By_No[_index].rent_per_month+Room_By_No[_index].securitydeposite;
        _landlord.transfer(totalfee);
        no_of_aggrement++;
        Room_By_No[_index].currentTenant=payable(msg.sender);
        Room_By_No[_index].vacant=false;
        Room_By_No[_index].timestamp=block.timestamp;
        Room_By_No[_index].agreementid=no_of_aggrement;
        Room storage rent=Room_By_No[_index];
        uint lockperiod=block.timestamp+47 weeks;
        RoomAgreement_By_No[no_of_aggrement]=RoomAgreement(rent.roomid,rent.agreementid,rent.roomname,rent.roomaddress,rent.rent_per_month,rent.securitydeposite,block.timestamp,lockperiod,rent.landlord,rent.currentTenant); 
        no_of_rent++;
        Rent_By_No[no_of_rent]=Rent(no_of_rent,rent.roomid,rent.agreementid,rent.roomname,rent.roomaddress,rent.rent_per_month,block.timestamp,rent.landlord,rent.currentTenant);
    }

    function payrent(uint _index) public payable sameTenant(_index) RentTimeUp(_index) AgreementTimesLeft(_index) enoughRent(_index){
        require(msg.sender!=address(0));
        address payable _landlord=Room_By_No[_index].landlord;
        uint rentfee=Room_By_No[_index].rent_per_month;
        _landlord.transfer(rentfee);
        Room_By_No[_index].timestamp=block.timestamp;
        Room memory rent=Room_By_No[_index];
        no_of_rent++;
        Rent_By_No[no_of_rent]=Rent(no_of_rent,rent.roomid,rent.agreementid,rent.roomname,rent.roomaddress,rent.rent_per_month,block.timestamp,rent.landlord,rent.currentTenant);
    }

    function agreementCompleted(uint _index) public payable onlyLandlord(_index) AgreementTimesUp(_index){
        require(msg.sender!=address(0));
        Room storage room=Room_By_No[_index];
        require(room.vacant==false,"Room is already vacant");
        address payable _Tenant=room.currentTenant;
        _Tenant.transfer(room.securitydeposite);
         room.vacant=true;
         room.agreementid=0;
         room.timestamp=0;
         room.currentTenant=payable(address(0));
    }
 
    function agreementTerminated(uint _index) public  onlyLandlord(_index) AgreementTimesLeft(_index){
        require(msg.sender!=address(0));
         Room storage room=Room_By_No[_index];
         address payable _Tenant=room.currentTenant;
        _Tenant.transfer(room.securitydeposite);
         room.vacant=true;
         room.timestamp=0;
         room.agreementid=0;
         room.currentTenant=payable(address(0));
    }
}