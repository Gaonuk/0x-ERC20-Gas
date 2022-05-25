module.exports = async ({
    getNamedAccounts,
    deployments,
  }) => { // Deploy functions to hardhat Run time as a parameter 
    const {deploy} = deployments; // the deployments field itself contains the deploy function 
    const {deployer} = await getNamedAccounts(); // we fetch the accounts. These can be configured in hardhat.config.ts as explained above 
    const swapper = await deploy('Swapper', { // this will create a deployment called 'Greeter'. By default it will look for an artifact with the same name. the contract option allows you to use a different artifact 
        from: deployer, // deployer will be performing the deployment transaction 
        args: ["0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"], // we pass in a greeting as the argument
        log: true, // display the address and gas used in the console (not when run in test though)
    });
    console.log(swapper.address);
};