module.exports = async ({
    getNamedAccounts,
    deployments,
  }) => { // Deploy functions to hardhat Run time as a parameter 
    const {deploy} = deployments; // the deployments field itself contains the deploy function 
    const {deployer} = await getNamedAccounts(); // we fetch the accounts. These can be configured in hardhat.config.ts as explained above 
    const greeter = await deploy('Greeter', { // this will create a deployment called 'Greeter'. By default it will look for an artifact with the same name. the contract option allows you to use a different artifact 
        from: deployer, // deployer will be performing the deployment transaction 
        args: ["hello"], // we pass in a greeting as the argument
        log: true, // display the address and gas used in the console (not when run in test though)
    });
    console.log(greeter.address);
};