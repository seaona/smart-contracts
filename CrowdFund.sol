// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "./IERC20sol";

contract CrowdFund {
    event Launch(
        uint id,
        address indexed creator,
        uint goal,
        uint32 startAt,
        uint32 endAt
    );

    event Cancel(uint id);
    event Pledge(uint indexed id, address indexed caller, uint amount);
    event Unpledge(uint indexed id, address indexed caller, uint amount);
    event Claim(uint id);
    event Refund(uint indexed id, address indexed caller, uint amount);

    struct Campaign {
        address creator;
        uint goal;
        uint pledged;
        uint32 startAt;
        uint32 endAt;
        bool claimed;
    }

    IERC20 public immutable token;
    uint public count;
    mapping(uint => Campaign) public campaigns;
    mapping(uint => mapping(address => uint)) public pledgedAmount;

    constructor(address _token) {
        token = IERC(_token);
    }

    function launch(
        uint _goal, //amt tokens they want to raise
        uint32 _startAt,
        uint32 _endAt
    ) external {
        require(_startAt >= block.timestamp, "start at less now");
        require(_endAt >= _startAt, "end at less than start at");
        require(_endAt < block.timestamp + 90 days, "end at greater max duration");

        count += 1;
        campaigns[count] = Campaign({
            creator: msg.sender,
            goal: _goal,
            pledged: 0,
            startAt: _startAt,
            endAt: _endAt,
            claimed: false
        });

        emit Launch(count, msg.sender, _goal, _startAt, _endAt);
    }

    // cancel campaign if it has not started
    function cancel(uint _id) external {
        Campaign memory campaign = campaigns[_id];
        require(msg.sender == campaign.creator, "not creator");
        require(block.timestamp < campaign.startAt, "started");
        delete campaigns[_id];
        
        emit Cancel(_id);
    }
    
    // user sends tokens
    function pledge(uint _id, uint _amount) external {
        Campaign storage campaign = campaigns[_id]; // storage bc we need to modify it
        require(block.timestamp >= campaign.startAt, "not started");
        require(block.timestamp <= campaign.endAt, "ended");

        campaign.pledged += amount;
        pledgedAmount[_id][msg.sender] += _amount;
        token.transferFrom(msg.sender, address(this), _amount);

        emit Pledge(_id, msg.sender, _amount);
    }


    function unpledge(uint _id, uint _amount) external {
        Campaign storage campaign = campaigns[_id]; // storage bc we need to modify it
        require(block.timestamp <= campaign.endAt, "ended");

        campaign.pledged -= amount;
        pledgedAmount[_id][msg.sender] -= _amount;
        token.transfer(msg.sender, _amount);

        emit Unpledge(_id, msg.sender, _amount);

    }

    // when campaing is over, if the amount is greater than the goal, the creator can claim the rest of tokens
    function claim(uint _id) external {
        Campaign storage campaign = campaigns[_id]; // storage bc we need to modify it
        require(msg.sender == campaign.creator, "not creator");
        require(block.timestamp > campaign.endAt, "not ended");
        require(campaign.pledged >= campaign.goal, "pledged less than goal");
        require(!campaign.claimed, "claimed");

        campaign.claimed = true;
        token.transfer(msg.sender, campaign.pledged);

        emit Claim(_id);
    }

    // if the goal is not reached, users can claim back the tokens
    function refund(uint _id) external {
        Campaign storage campaign = campaigns[_id]; // storage bc we need to modify it
        require(block.timestamp > campaign.endAt, "not ended");
        require(campaign.pledged < campaign.goal, "pledged less than goal");
        
        uint bal = pledgedAmount[_id][msg.sender];
        pledgedAmount[_id][msg.sender] = 0; // we do this before transfer, to prevent re-entrancy
        token.transfer(msg.sender, bal);

        emit Refund(_id, msg.sender, bal);
    }
}


