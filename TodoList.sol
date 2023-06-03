// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract TodoList{
    struct Todo{
        string task;
        bool completed;
    }
    Todo[] todos;

    function create(string memory _task) external {
        todos.push(Todo(_task,false));
    }

    function update(string memory _updatedTask,uint index) external {
        todos[index].task = _updatedTask;  // 1st way(Cheaper on gas for single thing to update
        // Todo storage updated = todos[index];  // 2nd way(If we want to update multiple things,then this is better)
        // updated.task  =_updatedTask;
    }

    function toggleCompleted(uint _index) external {
        todos[_index].completed = !todos[_index].completed;
    }

    // 1st way to get a array of type Struct - function get(uint _index) external view returns (Todo memory){
    //      return todos[_index];
    // }
    
    function get(uint _index) external view returns(string memory,bool){
         Todo storage getTodos = todos[_index];
         return (getTodos.task,getTodos.completed);
    }
}