// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "remix_tests.sol"; // this import is automatically injected by Remix.
import "hardhat/console.sol";
import "../contracts/3_Survey.sol";

contract SurveyTest {

    uint256 questionId;
    uint256 answerId;

    Survey surveyToTest;
    function beforeAll () public {
        surveyToTest = new Survey();
    }

    function checkQustionWork() public {
        string memory content = "this-is-content-of-a-question-test";
        questionId = surveyToTest.addQuestion(content);
        Assert.equal(surveyToTest.getQuestionContent(questionId), content, "can not store Question correctly");
    } 

    function checkAnswerWork() public {
        if(questionId == 0){
            checkQustionWork();
        }
        string memory answerContent = "this-is-content-of-an-answer-test";
        answerId = surveyToTest.addAnswer(questionId, answerContent);
        Assert.equal(surveyToTest.getAnswerContent(questionId, answerId), answerContent, "can not add Answer correctly");
    }
}