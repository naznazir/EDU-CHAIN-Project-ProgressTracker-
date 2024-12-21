// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ProgressTracker {

    struct Module {
        string name;
        uint progressPercentage; // percentage completion for this module
    }

    struct Learner {
        uint totalModules;
        mapping(uint => Module) modules; // mapping of module IDs to Modules
        uint completedModules;
    }

    mapping(address => Learner) public learners;

    event ModuleAdded(address learner, uint moduleId, string moduleName);
    event ProgressUpdated(address learner, uint moduleId, uint progressPercentage);
    event ModuleCompleted(address learner, uint moduleId);

    // Add a new module for the learner
    function addModule(string memory _moduleName) external {
        Learner storage learner = learners[msg.sender];
        uint moduleId = learner.totalModules;

        learner.modules[moduleId] = Module({
            name: _moduleName,
            progressPercentage: 0
        });

        learner.totalModules++;

        emit ModuleAdded(msg.sender, moduleId, _moduleName);
    }

    // Update progress for a specific module
    function updateProgress(uint _moduleId, uint _progressPercentage) external {
        require(_progressPercentage <= 100, "Progress must be between 0 and 100.");

        Learner storage learner = learners[msg.sender];
        Module storage module = learner.modules[_moduleId];

        require(bytes(module.name).length > 0, "Module does not exist.");

        module.progressPercentage = _progressPercentage;

        if (_progressPercentage == 100 && learner.completedModules < learner.totalModules) {
            learner.completedModules++;
            emit ModuleCompleted(msg.sender, _moduleId);
        }

        emit ProgressUpdated(msg.sender, _moduleId, _progressPercentage);
    }

    // Retrieve details of a specific module
    function getModule(address _learner, uint _moduleId) external view returns (string memory name, uint progressPercentage) {
        Module storage module = learners[_learner].modules[_moduleId];
        require(bytes(module.name).length > 0, "Module does not exist.");

        return (module.name, module.progressPercentage);
    }

    // Get overall progress for a learner
    function getOverallProgress(address _learner) external view returns (uint totalModules, uint completedModules) {
        Learner storage learner = learners[_learner];
        return (learner.totalModules, learner.completedModules);
    }
}
