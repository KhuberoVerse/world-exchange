//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Stocks.sol";
import "./StockExchange.sol";

contract StocksFactory is Ownable {

    uint public stocksCount;

    struct StockData {
        IStocks stocks;
        IStockExchange stex;
        bool allowTrade;
    }

    mapping(bytes=>StockData) private stocksList;

    function createStocks(string memory _name, string memory _symbol, address _usdc) external payable onlyOwner {
        // check for already existing token symbol as well
        require(address(stocksList[bytes(_symbol)].stocks)==address(0), "Stock already exists.");
        IStocks newStock = new Stocks(_name, _symbol, address(this), owner());
        IStockExchange tokenExchange = new StockExchange(address(newStock), _usdc);
        stocksList[bytes(_symbol)] = StockData(newStock, tokenExchange, true);
        stocksCount++;
    }

    function getStocksData(string memory _symbol) external view returns (StockData memory) {
        return stocksList[bytes(_symbol)];
    }

    function getExchange(string memory _symbol) external view returns (address) {
        return address(stocksList[bytes(_symbol)].stex);
    }

    // Check if Stock exists and trading
    function isStockTrading(string memory _symbol) public view returns (bool) {
        return stocksList[bytes(_symbol)].allowTrade;
    }

    // Create function to disable a stock from trading
    function disableStock(string memory _symbol) external onlyOwner {
        stocksList[bytes(_symbol)].allowTrade = false;
    }
    

}