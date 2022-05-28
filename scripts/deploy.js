const { ethers } = require("hardhat")
require("@nomiclabs/hardhat-etherscan")

async function main() {
    const SOFAContract = await ethers.getContractFactory("ShadowsOfForgottenAncestors")
    const deployedSOFAContract = await SOFAContract.deploy()
    await deployedSOFAContract.deployed()
    console.log("Contract address:", deployedSOFAContract.address)

    await new Promise((resolve) => setTimeout(resolve, 15*1000))
    await hre.run("verify:verify", {
        address: deployedSOFAContract.address,
        constructorArguments: [],
    })
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })
