專案流程

step1. 部署合約 deploy contract ZNtokenFactory.sol
	
step2. 寫入新option的截止日和標準價格，(ZNtokenFactory.sol) function updatePrice.

step3. 新增所有 option token項目，(ZNtokenFactory.sol) function createZNtoken.

--

step4. 交易者買option，(ZNtokenFactory.sol) function buyOP.

--

step5. 清算，（Liquidate.sol）...to be continued...
