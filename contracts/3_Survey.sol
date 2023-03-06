// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./2_Snowflake.sol";

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
