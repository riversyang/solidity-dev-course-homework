pragma solidity ^0.4.24;

import "../openzeppelin-solidity-2.0.0/contracts/ownership/Secondary.sol";
import "../openzeppelin-solidity-2.0.0/contracts/access/Roles.sol";

contract AgentRole is Secondary {
    using Roles for Roles.Role;

    event AgentAdded(address indexed account);
    event AgentRemoved(address indexed account);

    Roles.Role private agents;

    constructor() internal {
        _addAgent(msg.sender);
    }

    modifier onlyAgent() {
        require(isAgent(msg.sender), "Only agents can call this function.");
        _;
    }

    function isAgent(address account) public view returns (bool) {
        return agents.has(account);
    }

    function addAgent(address account) public onlyPrimary {
        _addAgent(account);
    }

    function renounceAgent() public {
        _removeAgent(msg.sender);
    }

    function _addAgent(address account) internal {
        agents.add(account);
        emit AgentAdded(account);
    }

    function _removeAgent(address account) internal {
        agents.remove(account);
        emit AgentRemoved(account);
    }
}
