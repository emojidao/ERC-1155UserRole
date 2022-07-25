import { expect } from "chai";
import { ethers } from "hardhat";

describe("Test 1155 User Role", function () {
    let alice, bob, carl;
    let contract;
    let expiry;

    async function checkRecord(rid,tokenId,amount,owner,user,expiry_) {
        let record = await contract.recordOf(rid);
            expect(record[0]).equals(tokenId,"tokenId");
            expect(record[1]).equals(amount,"amount");
            expect(record[2]).equals(owner,"owner");
            expect(record[3]).equals(user,"user");
            expect(record[4]).equals(expiry_,"expiry_");
    }

    beforeEach(async function () {
        [alice, bob, carl] = await ethers.getSigners();

        const ERC1155WithUserRoleDemo = await ethers.getContractFactory("ERC1155WithUserRoleDemo");

        contract = await ERC1155WithUserRoleDemo.deploy("", 3);

        expiry = Math.floor(new Date().getTime() / 1000) + 3600;
    });

    

    describe("", function () {
        it("Should set user to bob success", async function () {

            await contract.mint(alice.address, 1, 100);

            await contract.setUsable(alice.address, bob.address, 1, 10, expiry);

            await checkRecord(1,1,10,alice.address,bob.address,expiry);

            expect(await contract.balanceOfUsable(bob.address, 1)).equals(10);

            expect(await contract.balanceOf(alice.address, 1)).equals(90);

            expect(await contract.frozenOf(alice.address, 1)).equals(10);

        });

        it("Should set user to bob fail", async function () {

            await contract.mint(alice.address, 1, 100);

            await contract.setUsable(alice.address, bob.address, 1, 10, expiry);
            await contract.setUsable(alice.address, bob.address, 1, 10, expiry);
            await contract.setUsable(alice.address, bob.address, 1, 10, expiry);
            await expect(contract.setUsable(alice.address, bob.address, 1, 10, expiry)).to.be.revertedWith("user cannot have more records");

        });

        it("Should set user to bob fail : balance is not enough", async function () {

            await contract.mint(alice.address, 1, 100);

            await expect(contract.setUsable(alice.address, bob.address, 1, 101, expiry)).to.be.revertedWith('balance is not enough');

        });

        it("Should set user to bob fail : only owner or operator", async function () {

            await contract.mint(carl.address, 1, 100);

            await expect(contract.setUsable(carl.address, bob.address, 1, 110, expiry)).to.be.revertedWith('only owner or operator');

        });

        it("Should transfer success", async function () {

            await contract.mint(alice.address, 1, 100);

            await contract.setUsable(alice.address, bob.address, 1, 10, expiry);

            await contract.safeTransferFrom(alice.address, carl.address, 1, 90, "0x");

            await checkRecord(1,1,10,alice.address,bob.address,expiry);

            expect(await contract.balanceOfUsable(bob.address, 1)).equals(10);

            expect(await contract.balanceOf(alice.address, 1)).equals(0);

            expect(await contract.frozenOf(alice.address, 1)).equals(10);

            expect(await contract.balanceOf(carl.address, 1)).equals(90);

        });

        it("Should transfer fail", async function () {

            await contract.mint(alice.address, 1, 100);

            await contract.setUsable(alice.address, bob.address, 1, 10, expiry);

            await expect(contract.safeTransferFrom(alice.address, carl.address, 1, 91, "0x")).to.be.revertedWith("ERC1155: insufficient balance for transfer");

        });

        it("Should increaseUsable success", async function () {

            await contract.mint(alice.address, 1, 100);

            await contract.setUsable(alice.address, bob.address, 1, 10, expiry);

            await contract.increaseUsable(1, 10, expiry);

            await checkRecord(1,1,20,alice.address,bob.address,expiry);

            expect(await contract.balanceOfUsable(bob.address, 1)).equals(20);

            expect(await contract.balanceOf(alice.address, 1)).equals(80);

            expect(await contract.frozenOf(alice.address, 1)).equals(20);

        });

        it("Should increaseUsable fail", async function () {

            await contract.mint(alice.address, 1, 100);

            await contract.setUsable(alice.address, bob.address, 1, 10, expiry);

            await expect(contract.increaseUsable(1, 91, expiry)).to.be.revertedWith('balance is not enough');

        });

        it("Should decreaseUsable success 10", async function () {

            await contract.mint(alice.address, 1, 100);

            await contract.setUsable(alice.address, bob.address, 1, 10, expiry);

            await contract.decreaseUsable(1, 10, expiry);

            await checkRecord(1,0,0,"0x0000000000000000000000000000000000000000","0x0000000000000000000000000000000000000000",0);

            expect(await contract.balanceOfUsable(bob.address, 1)).equals(0);

            expect(await contract.balanceOf(alice.address, 1)).equals(100);

            expect(await contract.frozenOf(alice.address, 1)).equals(0);

        });

        it("Should decreaseUsable success 1", async function () {

            await contract.mint(alice.address, 1, 100);

            await contract.setUsable(alice.address, bob.address, 1, 10, expiry);

            await contract.decreaseUsable(1, 1, expiry);

            await checkRecord(1,1,9,alice.address,bob.address,expiry);

            expect(await contract.balanceOfUsable(bob.address, 1)).equals(9);

            expect(await contract.balanceOf(alice.address, 1)).equals(91);

            expect(await contract.frozenOf(alice.address, 1)).equals(9);

        });

        it("Should decreaseUsable fail", async function () {

            await contract.mint(alice.address, 1, 100);

            await contract.setUsable(alice.address, bob.address, 1, 10, expiry);

            await expect(contract.decreaseUsable(1, 11, expiry)).to.be.revertedWith('invalid amount');

        });

        it("Should transferUsable success:10", async function () {

            await contract.mint(alice.address, 1, 100);

            await contract.setUsable(alice.address, bob.address, 1, 10, expiry);

            await contract.transferUsable(1, 10, carl.address);

            expect(await contract.balanceOfUsable(bob.address, 1)).equals(10);

            expect(await contract.balanceOf(alice.address, 1)).equals(90);

            expect(await contract.frozenOf(alice.address, 1)).equals(0);

            expect(await contract.frozenOf(carl.address, 1)).equals(10);

        });

        it("Should transferUsable success:9", async function () {

            await contract.mint(alice.address, 1, 100);

            await contract.setUsable(alice.address, bob.address, 1, 10, expiry);

            await contract.transferUsable(1, 9, carl.address);

            expect(await contract.balanceOfUsable(bob.address, 1)).equals(10);

            expect(await contract.balanceOf(alice.address, 1)).equals(90);

            expect(await contract.frozenOf(alice.address, 1)).equals(1);

            expect(await contract.frozenOf(carl.address, 1)).equals(9);

        });

        it("Should transferUsable fail", async function () {

            await contract.mint(alice.address, 1, 100);

            await contract.setUsable(alice.address, bob.address, 1, 10, expiry);

            await expect(contract.transferUsable(1, 11, carl.address)).to.be.revertedWith('invalid amount');

        });



    });


});