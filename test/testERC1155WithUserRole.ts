import { expect } from "chai";
import { ethers } from "hardhat";

describe("set_user", function () {
    it("Should set user to bob", async function () {
        /**alice is the Owner */
        const [alice, bob] = await ethers.getSigners();

        const ERC1155WithUserRole = await ethers.getContractFactory("ERC1155WithUserRole");

        const contract = await ERC1155WithUserRole.deploy();

        await contract.mint(alice.address, 1,100);

        await contract.setUser(alice.address,bob.address,1,50);

        await contract.setUser(alice.address,bob.address,1,10);

        expect(await contract.balanceOfUser(bob.address,1)).equals(10);

        expect(await contract.balanceOfUserFromOwner(bob.address,alice.address,1)).equals(10);

        expect(await contract.frozenOfOwner(alice.address,1)).equals(10);
        
    });
});