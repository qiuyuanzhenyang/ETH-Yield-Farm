// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./DappToken.sol";
import "./MockDaiToken.sol";

contract TokenFarm{
    string public name = "Dapp Token Farm";
    address public owner;
    DappToken public dappToken;
    DaiToken public daiToken;

    //７．これまでのステーキングを行った全てのアドレスを追跡する配列を作成
    address[] public stakers;

    //４．投資家のアドレスと彼らのステーキングしたトークンの量を紐づけるmappingを作成
    mapping (address => uint) public stakingBalance;

    //６．投資家のアドレスをもとに彼らがステーキングを行ったか否かを紐づけるmappingを作成
    mapping (address => bool) public hasStaked;

    //１０．投資家の最新のステイタスを記録するマッピングを作成
    mapping (address => bool) public isStaking;

    constructor(DappToken _dappToken, DaiToken _daiToken) {
        dappToken = _dappToken;
        daiToken = _daiToken;
        owner = msg.sender;
    }

    //１．ステーキング機能を作成する
    function stakeTokens(uint _amount) public {
        //２．ステーキングされるトークンが０以上あることを確認
        require(_amount > 0, "amount can't be 0");

        //３．投資家のトークンをTokenFarm.solに移動させる
        daiToken.transferFrom(msg.sender, address(this), _amount);

        //５．ステーキングされたトークンの残高を更新する
        stakingBalance[msg.sender] = stakingBalance[msg.sender] + _amount;

        //８．投資家がまだステークしていない場合のみ、彼らをstakers配列に追加する
        if(!hasStaked[msg.sender]){
            stakers.push(msg.sender);
        }

        //９．ステーキングステータスの更新
        isStaking[msg.sender] = true;
        hasStaked[msg.sender] = true;
    }

    //-----追加する機能-----//
    //２．トークンの発行機能
    function issueTokens() public {
        //Dappトークンを発行できるのはあなたのみであることを確認する
        require(msg.sender == owner, "caller must be the owner");

        //投資家が預けた偽Daiトークンの数を確認し、同量のDappトークンを発行する
        for(uint i=0; i<stakers.length; i++) {
            //recipientはDappトークンを受け取る投資家
            address recipient = stakers[i];
            uint balance = stakingBalance[recipient];
            if(balance > 0){
                dappToken.transfer(recipient, balance);
            }
        }
    }

    //３．アンステーキング機能
    //投資家は預け入れたDaiを引き出すことができる
    function unstakeTokens(uint _amount) public {
        //投資家がステーキングした金額を取得する
        uint balance = stakingBalance[msg.sender];
        //投資家がステーキングした金額が０以上であることを確認する
        require(balance > _amount, "staking balance should be more than unstaked amount");
        //偽のDaiトークンを投資家に返金する
        daiToken.transfer(msg.sender, _amount);
        //返金した分のdappTokenを利子として付与する
        dappToken.transfer(msg.sender, _amount);
        //投資家のステーキング残高を０に更新する
        stakingBalance[msg.sender] = balance - _amount;
        //投資家のステーキング状態を更新する
        isStaking[msg.sender] = false;
    }
}