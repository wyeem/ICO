pragma solidity 0.5.8;

/**
 * @title Queue
 * @dev Data structure contract used in `Crowdsale.sol`
 * Allows buyers to line up on a first-in-first-out basis
 * See this example: http://interactivepython.org/courselib/static/pythonds/BasicDS/ImplementingaQueueinPython.html
 */

contract Queue {

	uint8  size = 5;//Maximum queue length
	uint8 peopleWaitingInQueue=0;
    uint256 firstIndex=1; //head of queue starts ar index 1 not 0 (0 value in mapping 'positions' has been reserved for value not in queue)
    uint256 timeInFirstSlot; //Timestamp for first slot
    uint256 timeLimit = 1 minutes; //Max. time limit for first slot

	address[]  queue;

	// position of each address in the queue. '0' => address not in queue
	mapping(address => uint8)  positions;


	/* Add events */

	/* constructor */
constructor() public{
	queue.push(address(0));// first element to be later stored at queue[1];

}
	/* Returns the number of people waiting in line */
	function qsize() public view returns(uint8) {
			return peopleWaitingInQueue;
	}

	/* Returns whether the queue is empty or not */
	function empty() public view returns(bool) {
		return peopleWaitingInQueue == 0;
	}
	
	/* Returns the address of the person in the front of the queue */
	function getFirst() public view returns(address) {
		require(firstIndex<queue.length,'address not in Queue');
		return queue[firstIndex];
	}
	
	/* Allows `msg.sender` to check their position in the queue */
	function checkPlace() public view returns(uint8) {
		return positions[msg.sender];
	}
	
	/* Allows anyone to expel the first person in line if their time
	 * limit is up
	 */
	function checkTime() public{
		if (now - timeInFirstSlot >= timeLimit){
			dequeue();
			timeInFirstSlot = 0;
		}

	}
	
	/* Removes the first person in line; either when their time is up or when
	 * they are done with their purchase

	 firstIndex == queue.length => queue is empty
	 firstIndex < queue.length => items in queue
	 */
	function dequeue() public {
		require(!empty(), 'Queue is empty');//or assert?
		positions[queue[firstIndex]] =0;
		delete queue[firstIndex];
		-- peopleWaitingInQueue;
		
		++firstIndex; //move the index to the next first item in queue
		if (peopleWaitingInQueue >0) //start the timer for the new first item in queue
			timeInFirstSlot =now; 

	}

	/* Places `addr` in the first empty position in the queue */
	function enqueue(address addr) public{
		require(peopleWaitingInQueue<=size, 'Queue is full');
		
		queue.push(addr);

		if (peopleWaitingInQueue ==0) // if the queue is empty and the new item is the first in queue start the timer
			timeInFirstSlot = now;


		++peopleWaitingInQueue;
		positions[addr]=peopleWaitingInQueue;
	}
}