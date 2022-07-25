import { expect } from "chai";
import { ethers } from "hardhat";

describe("Test 1155 User Role", function () {
    let alice, bob, carl;
    let contract;
    let expiry;

    async function checkRecord(rid, tokenId, amount, owner, user, expiry_) {
        let record = await contract.recordOf(rid);
        expect(record[0]).equals(tokenId, "tokenId");
        expect(record[1]).equals(amount, "amount");
        expect(record[2]).equals(owner, "owner");
        expect(record[3]).equals(user, "user");
        expect(record[4]).equals(expiry_, "expiry_");
    }

    beforeEach(async function () {
        [alice, bob, carl] = await ethers.getSigners();

        const ERC1155WithUserRoleDemo = await ethers.getContractFactory("ERC1155WithUserRoleDemo");

        contract = await ERC1155WithUserRoleDemo.deploy("", 255);

        expiry = Math.floor(new Date().getTime() / 1000) + 3600;
    });



    describe("", function () {
        it("Should set user to bob success", async function () {

            await contract.mint(alice.address, 1, 1000);

            for (let index = 0; index < 255; index++) {
                await contract.setUsable(alice.address, bob.address, 1, 1, expiry);
                let start = new Date().getTime();
                expect(await contract.balanceOfUsable(bob.address, 1)).equals(index + 1);
                let end = new Date().getTime();
                console.log(index, "cost time:", end - start);
            }

        });


    });


});