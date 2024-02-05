// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract greedy599 is Ownable {

    event Start(address indexed payee);
    event Invest(address indexed payee, uint256 key_price, uint256 last);
    event Distribute(address indexed payee, uint256 investorTokens);
    event Breaking(address indexed payee, uint256 investorTokens);

    mapping(address=>bool) record;
    mapping(address=>uint) public investorTokens;
    address payable[] public investors; // array of investors
    address payable public leader;
    uint public key_price = 1000000000000000 wei;
    uint public last;
    // uint public balance;
    bool public break_sign = true;

    constructor(address initialOwner)
        Ownable(initialOwner)
    {}

    function start() public payable onlyOwner {
        require(msg.value == key_price && break_sign);
        investors.push(payable(msg.sender));
        record[msg.sender] = true;
        break_sign = false;
        investorTokens[msg.sender] += key_price / 100;
        key_price += 1000000000000000 wei;
        leader = payable(msg.sender);
        last = block.timestamp;
        emit Start(msg.sender);
    }

    function invest() public payable {
        require(msg.value == key_price && !break_sign);
        if (!record[msg.sender]){
            investors.push(payable(msg.sender));
            record[msg.sender] = true;
        }
        investorTokens[msg.sender] += key_price / 100;
        
        leader = payable(msg.sender);
        last = block.timestamp;
        emit Invest(msg.sender, key_price, last);
        key_price += 1000000000000000 wei;
    }

    function distribute() public onlyOwner {
        require(!break_sign);
        for(uint i = 0; i < investors.length; i++) { 
            investors[i].transfer(investorTokens[investors[i]]);
            emit Distribute(investors[i], investorTokens[investors[i]]);
        }
    }

    function breaking() public onlyOwner {
        require(!break_sign);
        break_sign = true;
        leader.transfer(address(this).balance / 2);
        emit Breaking(leader, address(this).balance / 2);
        // balance /= 2;
        uint tmp = address(this).balance / investors.length;
        for(uint i = 0; i < investors.length; i++) { 
            investors[i].transfer(tmp);
            emit Breaking(investors[i], tmp);
            investorTokens[investors[i]] = 0;
            record[investors[i]] = false;
        }
        delete investors;
        key_price = 1000000000000000 wei;
        leader = payable(address(0));
    }
}
