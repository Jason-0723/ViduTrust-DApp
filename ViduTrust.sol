// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ViduTrust {
    address public hospital; // 醫院管理方地址

    struct Product {
        string name;       // 商品或服務名稱
        uint256 price;     // 所需時數積分
        address merchant;  // 提供該商品的商家地址
        bool isAvailable;  // 是否上架中
    }

    uint256 public productCount;
    mapping(uint256 => Product) public products;          // 商品列表 (ID => 商品)
    mapping(address => uint256) public volunteerBalances; // 志工時數餘額
    mapping(address => uint256) public merchantBalances;  // 商家持有的可結算積分

    constructor() {
        hospital = msg.sender; // 部署合約的人即為醫院管理方
    }

    // 1. 醫院發行時數積分給志工
    function mintHours(address _volunteer, uint256 _hours) public {
        require(msg.sender == hospital, "Only the hospital can mint hours.");
        volunteerBalances[_volunteer] += _hours;
    }

    // 2. 商家發布可供兌換的商品
    function addProduct(string memory _name, uint256 _price) public {
        productCount++;
        products[productCount] = Product(_name, _price, msg.sender, true);
    }

    // 3. 志工消耗積分兌換商品
    function redeemProduct(uint256 _productId) public {
        Product storage prod = products[_productId];
        require(prod.isAvailable, "Product is not available.");
        require(volunteerBalances[msg.sender] >= prod.price, "Insufficient volunteer hours.");

        volunteerBalances[msg.sender] -= prod.price;
        merchantBalances[prod.merchant] += prod.price;
    }

    // 4. 商家向醫院發起積分清算（清空商家餘額）
    function settlePoints(address _merchant) public {
        require(msg.sender == hospital, "Only the hospital can settle accounts.");
        require(merchantBalances[_merchant] > 0, "No points to settle.");
        
        merchantBalances[_merchant] = 0; // 清算完成，商家點數歸零
    }
}
