
// File: contracts/2_Snowflake.sol


pragma solidity ^0.8.0;

// This contract generates 64-bit IDs where the first 44 bits are the timestamp 
// in seconds since September 4th, 2021 (the "epoch" time), the next 20 bits are the node ID (the address of the contract), 
// and the final 12 bits are a sequence number that is incremented when multiple IDs are generated in the same second.
contract Snowflake {
    uint256 private lastTimestamp;
    uint256 private sequence;
    uint256 private constant sequenceMask = 0xFFF; // 12 bits
    uint256 private constant sequenceShift = 12;
    uint256 private constant nodeBits = 10;
    uint256 private constant nodeShift = 22;
    uint256 private constant epoch = 1630761600; // 2021-09-04T00:00:00Z


    function generateId() public returns (uint256 id) {
        uint256 currentTimestamp = uint256(block.timestamp);
        require(currentTimestamp >= lastTimestamp, "Timestamp must not go backwards");

        if (currentTimestamp == lastTimestamp) {
            sequence = (sequence + 1) & sequenceMask;
            if (sequence == 0) {
                // Sequence overflow, wait until next timestamp
                currentTimestamp = waitForNextTimestamp();
            }
        } else {
            sequence = 0;
        }
        // lastTimestamp = currentTimestamp;
        // As of Solidity v0.8, you can no longer cast explicitly from address to uint256.
        uint256 nodeId = uint256(uint160(address(this))) >> (256 - nodeBits);
        // [1(no use)] [41bits(timestamp)] [10(node)] [12(seq)]
        id = ((currentTimestamp) << nodeShift) | (nodeId << sequenceShift) | sequence;
    }

    function waitForNextTimestamp() private view returns (uint256) {
        uint256 currentTimestamp = uint256(block.timestamp);
        while (currentTimestamp == lastTimestamp) {
            currentTimestamp = uint256(block.timestamp);
        }
        return currentTimestamp;
    }


    // for test
    // uint256 _id = generateId();
}

// File: contracts/3_Survey.sol


pragma solidity ^0.8.0;

contract Survey {



    //---------------------------------------STRUCTS------BEGIN-----------------------------------------------------------------
    struct Question {

        // TODO: add more details for content
        string content;

        address owner;
        uint256[] answers; // array of answer
        // uint numAnswers; // number of answers recorded so far

        uint256 id;
    }

    function newQuestion(string memory content, address owner, uint256 id) pure internal returns(Question memory question){
        uint256[] memory ans;
        question = Question(content, owner, ans, id);
    }

    struct Answer {
        // TODO: add more details for content
        string content;

        address owner;
        
        // TODO: add hash to prevent being modified
        
        uint256 questionId;
        uint256 id;

    }

    function newAnswer(string memory content, address owner, uint256 questionId, uint256 id) pure internal  returns(Answer memory ans){
        ans = Answer(content, owner, questionId, id);
    }

//-----------------------------------------------STRUCTS------END-------------------------------------------------------------


    constructor(){
        snowflakeGenerator = new Snowflake();
    }


//----------------------------------------------STATE--------BEGIN----------------------------------------------------------
    Snowflake snowflakeGenerator;
    mapping(uint256 => Question) public questions; // mapping from question ID to question
    mapping(uint256 => Answer) public answers;
    
//----------------------------------------------STATE--------END-----------------------------------------------------------


    modifier ValidQuestion(uint256 questionId){
        require(questions[questionId].owner != address(0), "Question not exist");
        _;
    }
    
    function getQuestionContent(uint256 questionId) public view ValidQuestion(questionId) returns (string memory) {
        return questions[questionId].content;
    }
    
    function getAnswerCount(uint256 questionId) public view ValidQuestion(questionId) returns (uint) {
        return questions[questionId].answers.length;
    }

    function getAnswerContent(uint256 questionId, uint256 answerId) public view  returns(string memory){
        require(answers[answerId].owner != address(0), "Answer not exist");
        Answer memory ans = answers[answerId];
        require(ans.questionId == questionId, "Answer not exist under the question");
        return ans.content;
    }

    function getAllAnswer(uint256 questionId) public view ValidQuestion(questionId) returns(Answer[] memory ans) {
        uint256[] memory ids = questions[questionId].answers;
        // can not use `push`
        ans = new Answer[](ids.length);
        for (uint i = 0; i < ids.length; i++) {
            ans[i] = answers[ids[i]];
        }
    }

    function addQuestion(string memory content) public returns (uint256 id) {
        id = snowflakeGenerator.generateId();
        Question memory qus = newQuestion(content, msg.sender, id);
        questions[id] = qus;
    }

    function addAnswer(uint256 questionId, string memory content) public ValidQuestion(questionId) returns( uint256 id) {
        id = snowflakeGenerator.generateId();

        Answer memory ans = newAnswer(content, msg.sender, questionId, id);
        answers[id] = ans;

        questions[questionId].answers.push(id);

    }
}
