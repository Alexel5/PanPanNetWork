import "./PanPanNetWork.sol";

pragma solidity ^0.4.21;


contract PanPanNetWorkFactory {

    mapping(address => address[]) public created;
    mapping(address => bool) public isPanPanNetWork; //verify without having to do a bytecode check.
    bytes public PanPanNetWorkByteCode; // solhint-disable-line var-name-mixedcase

    function PanPanNetWorkFactory() public {
        //upon creation of the factory, deploy a PanPanNetWork (parameters are meaningless) and store the bytecode provably.
        address verifiedToken = createPanPanNetWork(210000000000,"PanPanBi",3,"PPB");
        PanPanNetWorkByteCode = codeAt(verifiedToken);
    }

    //verifies if a contract that has been deployed is a Human Standard Token.
    //NOTE: This is a very expensive function, and should only be used in an eth_call. ~800k gas
    function verifyPanPanNetWork(address _tokenContract) public view returns (bool) {
        bytes memory fetchedTokenByteCode = codeAt(_tokenContract);

        if (fetchedTokenByteCode.length != PanPanNetWorkByteCode.length) {
            return false; //clear mismatch
        }

      //starting iterating through it if lengths match
        for (uint i = 0; i < fetchedTokenByteCode.length; i++) {
            if (fetchedTokenByteCode[i] != PanPanNetWorkByteCode[i]) {
                return false;
            }
        }
        return true;
    }

    function createPanPanNetWork(uint256 _initialAmount, string _name, uint8 _decimals, string _symbol)
        public
    returns (address) {

        PanPanNetWork newToken = (new PanPanNetWork(_initialAmount, _name, _decimals, _symbol));
        created[msg.sender].push(address(newToken));
        isPanPanNetWork[address(newToken)] = true;
        //the factory will own the created tokens. You must transfer them.
        newToken.transfer(msg.sender, _initialAmount);
        return address(newToken);
    }

    //for now, keeping this internal. Ideally there should also be a live version of this that
    // any contract can use, lib-style.
    //retrieves the bytecode at a specific address.
    function codeAt(address _addr) internal view returns (bytes outputCode) {
        assembly { // solhint-disable-line no-inline-assembly
            // retrieve the size of the code, this needs assembly
            let size := extcodesize(_addr)
            // allocate output byte array - this could also be done without assembly
            // by using outputCode = new bytes(size)
            outputCode := mload(0x40)
            // new "memory end" including padding
            mstore(0x40, add(outputCode, and(add(add(size, 0x20), 0x1f), not(0x1f))))
            // store length in memory
            mstore(outputCode, size)
            // actually retrieve the code, this needs assembly
            extcodecopy(_addr, add(outputCode, 0x20), 0, size)
        }
    }
}