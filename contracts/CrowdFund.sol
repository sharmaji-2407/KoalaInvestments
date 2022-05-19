// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

contract CrowdFund{
    
    address payable public manager; 
    uint public minimumContribution;
    uint public deadline;
    uint public target;
    uint public raisedAmount;
    uint public noOfContributors;
    

    struct Project {
        uint id;
        string name;
        uint target;
        uint deadline;
        bool status;
    }

    mapping(address => uint) public ContributedIn;
    mapping(address=>uint) public contributors; 
    mapping(uint => Project) public ProjectMap; 
    
    Projs[] public projList;
    
    event viewProjects(
        uint id,
        string name,
        uint target,
        uint deadline,
        bool status
    );

    

    constructor(){
        manager=payable(msg.sender);
    }

    function createProject(uint _id, string memory _name, uint _target,uint _deadline) public {
        Project memory Projects;
        Projects.id = _id;
        Projects.name = _name;
        Projects.target=_target;
        Projects.deadline=block.timestamp+_deadline; //10sec + 3600sec (60*60)
        Projects.status = true;
        projList.push(Projects);
        minimumContribution=100 wei;
        manager = payable(msg.sender);

        emit viewProjects(ProjectMap[_id].id, ProjectMap[_id].name, ProjectMap[_id].target, ProjectMap[_id].deadline, ProjectMap[_id].status);
    }
    

    function sendEth(uint _id, uint _sentAmount) external payable{
        
        require(block.timestamp < Projects.deadline,"Deadline has passed");
        require(msg.value >=minimumContribution,"Minimum Contribution is not met");
        ContributedIn[msg.sender] = _id; // to mark in which project user has contributed in .
        if(contributors[msg.sender] == 0){ 
            noOfContributors++;
        }
        contributors[msg.sender]+=_sentAmount;
        raisedAmount+=_sentAmount;
        // contributors[msg.sender]+=msg.value;
        // raisedAmount+=msg.value;
    }

    function getBalance() external view returns(uint){
        return raisedAmount;
    }

    // function withdraw(uint _amount) external{
    //     require(msg.sender == manager, "Only owner can access");
    //     payable(msg.sender).transfer(_amount);
    // }

    // function getBalance() external view returns(uint){
    //     return address(this).balance;
    // }

}


// contract FundWallet {

//     constructor(address manager) public {
//     address owner = manager;
//     }

//     function withdraw(uint _amount) external{
//         require(msg.sender == owner, "Only owner can access");
//         payable(msg.sender).transfer(_amount);
//     }

//     function getBalance() external view returns(uint){
//         return address(this).balance;
//     }
// }

// pragma solidity ^0.8.10;

// interface IERC20 {
//     function transfer(address, uint) external returns (bool);

//     function transferFrom(
//         address,
//         address,
//         uint
//     ) external returns (bool);
// }

// contract CrowdFund {
//     event Launch(
//         uint id,
//         address indexed creator,
//         uint goal,
//         uint32 startAt,
//         uint32 endAt
//     );
//     event Cancel(uint id);
//     event Pledge(uint indexed id, address indexed caller, uint amount);
//     event Unpledge(uint indexed id, address indexed caller, uint amount);
//     event Claim(uint id);
//     event Refund(uint id, address indexed caller, uint amount);

//     struct Campaign {
//         // Creator of campaign
//         address creator;
//         // Amount of tokens to raise
//         uint goal;
//         // Total amount pledged
//         uint pledged;
//         // Timestamp of start of campaign
//         uint32 startAt;
//         // Timestamp of end of campaign
//         uint32 endAt;
//         // True if goal was reached and creator has claimed the tokens.
//         bool claimed;
//     }

//     IERC20 public immutable token;
//     // Total count of campaigns created.
//     // It is also used to generate id for new campaigns.
//     uint public count;
//     // Mapping from id to Campaign
//     mapping(uint => Campaign) public campaigns;
//     // Mapping from campaign id => pledger => amount pledged
//     mapping(uint => mapping(address => uint)) public pledgedAmount;

//     constructor(address _token) {
//         token = IERC20(_token);
//     }

//     function launch(
//         uint _goal,
//         uint32 _startAt,
//         uint32 _endAt
//     ) external {
//         require(_startAt >= block.timestamp, "start at < now");
//         require(_endAt >= _startAt, "end at < start at");
//         require(_endAt <= block.timestamp + 90 days, "end at > max duration");

//         count += 1;
//         campaigns[count] = Campaign({
//             creator: msg.sender,
//             goal: _goal,
//             pledged: 0,
//             startAt: _startAt,
//             endAt: _endAt,
//             claimed: false
//         });

//         emit Launch(count, msg.sender, _goal, _startAt, _endAt);
//     }

//     function cancel(uint _id) external {
//         Campaign memory campaign = campaigns[_id];
//         require(campaign.creator == msg.sender, "not creator");
//         require(block.timestamp < campaign.startAt, "started");

//         delete campaigns[_id];
//         emit Cancel(_id);
//     }

//     function pledge(uint _id, uint _amount) external {
//         Campaign storage campaign = campaigns[_id];
//         require(block.timestamp >= campaign.startAt, "not started");
//         require(block.timestamp <= campaign.endAt, "ended");

//         campaign.pledged += _amount;
//         pledgedAmount[_id][msg.sender] += _amount;
//         token.transferFrom(msg.sender, address(this), _amount);

//         emit Pledge(_id, msg.sender, _amount);
//     }

//     function unpledge(uint _id, uint _amount) external {
//         Campaign storage campaign = campaigns[_id];
//         require(block.timestamp <= campaign.endAt, "ended");

//         campaign.pledged -= _amount;
//         pledgedAmount[_id][msg.sender] -= _amount;
//         token.transfer(msg.sender, _amount);

//         emit Unpledge(_id, msg.sender, _amount);
//     }

//     function claim(uint _id) external {
//         Campaign storage campaign = campaigns[_id];
//         require(campaign.creator == msg.sender, "not creator");
//         require(block.timestamp > campaign.endAt, "not ended");
//         require(campaign.pledged >= campaign.goal, "pledged < goal");
//         require(!campaign.claimed, "claimed");

//         campaign.claimed = true;
//         token.transfer(campaign.creator, campaign.pledged);

//         emit Claim(_id);
//     }

//     function refund(uint _id) external {
//         Campaign memory campaign = campaigns[_id];
//         require(block.timestamp > campaign.endAt, "not ended");
//         require(campaign.pledged < campaign.goal, "pledged >= goal");

//         uint bal = pledgedAmount[_id][msg.sender];
//         pledgedAmount[_id][msg.sender] = 0;
//         token.transfer(msg.sender, bal);

//         emit Refund(_id, msg.sender, bal);
//     }
