pragma solidity ^0.6.0;

uint public total;
event AddToTotalEvent();

function addToTotal(uint _number) {
    total = total + _number;
    emit AddToTotalEvent();
}