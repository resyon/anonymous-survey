// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0; 
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./Snowflake.sol";

contract SurveyContract {


    Snowflake IdGenerator;
    constructor(){
        IdGenerator =  new Snowflake();
    }

    // ------- Struct for holding surveys ---
    struct survey {
        uint256 id;

        // uint amount;
        address admin;
        // address tokenAddress; // ERC20 Token

        // Keep track of the available funds
        // uint remainingAmount;

        
        bytes32[] data;
        uint256[] answers;
    }

    struct answer {
        uint256 id;
        address owner;
        bytes32[] data;
    }

    mapping(uint256 => survey) internal Surveys;
    mapping(uint256 => answer) internal Answers;
    mapping(address => uint256[]) internal UserAnswers; 
    mapping(address => uint256[]) internal UserSurveys;
    
    // uint public numSurveys = 0;
    // mapping shortcoming
    uint256[] internal surveyIndices;
    uint256[] internal answerIndices;


    // ----- Functions -------

    function createAndSubmitSurvey(
        // string memory _name,
        // uint _amount,
        // address _tokenAddress,
        bytes32[] memory data
    )
    public
    payable
    returns (uint256)
    {
        // require(_tokenAddress == address(0) || msg.value == 0);

        // // Transfer funds
        // if (_tokenAddress != address(0)) {
        //     // ERC20 token
        //     ERC20 token = ERC20(_tokenAddress);
        //     require(token.transferFrom(msg.sender, address(this), _amount));
        // } else {
        //     // Ether
        //     require(_amount == msg.value);
        //     require(msg.value > 0);
        // }

        // make sure id is unique
        uint256 id;
        do{ 
            id = IdGenerator.generateId();
        }while(Surveys[id].admin == address(0));
        

        // create survey
        uint256[] memory answers;
        // survey memory s = survey(id, _amount, msg.sender, _tokenAddress,  _amount, data, answers);
        survey memory s = survey(id, msg.sender, data, answers);

        Surveys[id] = s;
        UserSurveys[msg.sender].push(id);

        surveyIndices.push(id);    
        return id;
    }

    function createAndSubmitAnswer(uint256 questionId, bytes32[] memory data) public returns(uint256) {

        require(Surveys[questionId].admin != address(0));
        
        uint256 id;
        do{ 
            id = IdGenerator.generateId();
        }while(Answers[id].owner == address(0));

        answer memory ans = answer(id, msg.sender, data);
        Answers[id] = ans;
        UserAnswers[msg.sender].push(id);
        answerIndices.push(id);

        Surveys[questionId].answers.push(id);
        
        return id; 
    }

    function submitSurveyResponse(uint256 id)
    public
    payable
    returns (bool)
    {
        survey memory s = Surveys[id];

        // Check if surveyee is the survey owner
        require(s.admin != msg.sender);

        // Check if there's funding available to transfer to the surveyee
        // require(s.amount != 0 && s.remainingAmount != 0);

        // Check if the user had already submitted response
        // require(!s.isSurveyee[msg.sender]);

        // Transfer funds to the surveyee
        // uint _value = s.amount / s.requiredResponses;

        // if (s.tokenAddress != address(0)) {
        //     // ERC20
        //     ERC20 token = ERC20(s.tokenAddress);
        //     require(token.transfer(msg.sender, _value));
        // } else {
        //     // ETH
        //     msg.sender.transfer(_value);
        // }

        // Update survey data in the Surveys Map

        // s.remainingAmount -= _value;

        Surveys[id] = s;

        return true;
    }

    // ------- getter functions -----------
    function surveyInfo(uint256 id)
    public
    view
    returns (address, bytes32[] memory, uint256[] memory)
    {
        return _surveyInfo(id);
    }

    function _surveyInfo(uint256 id)
    internal
    view
    returns (address, bytes32[] memory, uint256[] memory)
    {
        survey memory s = Surveys[id];
        return (s.admin, s.data, s.answers);
    }

    function getAllSurveys()
    public
    view
    returns (uint256[] memory, address[] memory, bytes32[][] memory)
    {

        
        uint cnt = surveyIndices.length;
        // Name, Shortid, Responses Count
        uint256[] memory ids = new uint256[](cnt);
        address[] memory owners = new address[](cnt);
        bytes32[][] memory datas = new bytes32[][](cnt);

        for (uint i = 0; i < cnt; i++) {
            
            survey memory s = Surveys[surveyIndices[i]];

            ids[i] = s.id;
            owners[i] = s.admin;
            datas[i] = s.data;
        }

        return (ids, owners, datas);
    }

    function getUserSurveys(address _admin)
    public
    view
    returns (uint256[] memory, bytes32[][] memory)
    {
        uint surveysCount = UserSurveys[_admin].length;

        // Name, Shortid, Responses Count
        uint256[] memory ids = new uint256[](surveysCount);
        bytes32[][] memory datas = new bytes32[][](surveysCount);

        for (uint i = 0; i < surveysCount; i++) {
            survey memory s = Surveys[UserSurveys[_admin][i]];

            ids[i] = s.id;
            datas[i] = s.data;
        }

        return (ids, datas);
    }

    function getAnswer(uint256 id)
    public
    view
    returns (address, bytes32[] memory)
    {

        // make sure the answer exists
        require(Answers[id].owner != address(0));
        answer memory ans = Answers[id];
        return (ans.owner, ans.data);
    }

    function getUserAnswers(address _owner)
    public
    view
    returns (uint256[] memory, bytes32[][] memory)
    {
        uint cnt = UserAnswers[_owner].length;

        // Name, Shortid, Responses Count
        uint256[] memory ids = new uint256[](cnt);
        bytes32[][] memory datas = new bytes32[][](cnt);

        for (uint i = 0; i < cnt; i++) {
            answer memory a = Answers[UserAnswers[_owner][i]];

            ids[i] = a.id;
            datas[i] = a.data;
        }

        return (ids, datas);
    }

    // ------- helper functions -----------

    function strToMappingIndex(string memory str)
    private
    pure
    returns (bytes32 result)
    {
        return keccak256(abi.encodePacked(str));
    }

    function stringToBytes32(string memory source)
    private
    pure
    returns (bytes32 result)
    {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }

        return result;
    }

}
