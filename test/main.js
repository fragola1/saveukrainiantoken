const { expect } = require("chai")

describe("SaveUkranianToken.sol", function () {
    let contract
    let owner, addrs

    beforeEach(async function () {
        [owner, ...addrs] = await ethers.getSigners()
        const SOFAContract = await ethers.getContractFactory("SaveUkranianToken")
        contract = await SOFAContract.deploy()
    })

    function contractBalance() {
        return owner.provider.getBalance(contract.address)
    }

    function numberMinted(address=owner.address) {
        return contract.balanceOf(address)
    }

    async function mint(quantity) {
        const price = await contract.PRICE_PER_FOLK()
        await expect(contract.mint(quantity, { value: price.mul(quantity) }))
            .to.emit(contract, 'Transfer')
        expect(await numberMinted()).to.equal(quantity)
        expect(await contractBalance()).to.equal(price.mul(quantity))
    }

    it("Should airdrop", async function () {
        await contract.airdrop()
        expect(await numberMinted(), await contract.AIRDROP_FOLKS())
    })

    it("Should mint a single FOLK", async function () {
        await mint(1)
    })

    it("Should not mint on wrong sent value", async function () {
        await expect(contract.mint(1, { value: 1 })).to.be.reverted
    })

    it("Should mint a max batch of FOLKs", async function () {
        await mint(await contract.MAX_FOLKS_PER_HOLDER())
    })

    it("Should not mint on max balance reached", async function () {
        await expect(contract.mint(10, { value: 1 })).to.be.reverted
    })

    it("Should donate ethers", async function () {
        await mint(5)  // Deposit
        await expect(contract.donate()).to.emit(contract, 'Donated')
        expect(await contractBalance()).to.equal(0)
    })

    it("Should not donate on zero balance", async function () {
        await expect(contract.donate()).to.be.reverted
    })

    it("Should transfer FOLK", async function() {
        await mint(1)
        await expect(contract.transferFrom(owner.address, addrs[0].address, 0))
            .to.emit(contract, 'Transfer')
        expect(await numberMinted(addrs[0].address), 1)
    })
})
