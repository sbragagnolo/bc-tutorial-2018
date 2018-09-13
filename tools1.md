# Hands-on: Pharo Tools for Smart Contract Analysis

In this material, I will present tools coded in Pharo Smalltalk for smart contract analysis. 

## 1. Pharo

[Pharo](https://pharo.org/) is a fully integrated programming environment (kind like an IDE + OS + APIs). Pharo is a Smalltalk dialect. If you want to learn more about Pharo, their [MOOC](https://mooc.pharo.org/) is a nice starting point.

For this tutorial, you won't need to know how to code in Pharo. I will give all code and instructions to execute the tools. Just remember that Pharo is an image based system (a very rough analogy would be docker images) instead of file based.

## 2. Visualization: SolVis

One of the analysis tools we have developed is a Visualization for smart contracts. We are still working on improving the visualization approach, and if you want help please answer this [academic survey]().

First, we need to install SmaCC on your Pharo image. Run the following code in a playground screen:

```smalltalk
Metacello new
    baseline: 'SmaCC';
    repository: 'github://SmaCCRefactoring/SmaCC';
    load.
```

Now, you can get the visualization tool by running the following code on a playground:
```smalltalk
Metacello new
    baseline: 'SolVis';
    repository: 'github://hscrocha/SolVis';
    load.
```

The Solidity smart contract visualization tool is now installed in your image. Do a click on the main Pharo window to open the menu, you will see a new option there called "Solidity".

![Pharo SolVis](/images/pharo-solvis.png).

In the "Solidity" menu, you should select "Set Database Path" to set up a folder in your local computer to place contracts. After setting it up, you can choose the menu "Open Database" to select a contract file to visualize. As an example, we are using this file which contains the [TokenERC20 standard](contracts/ERC20Token.sol). That contract visualization is shown below.

<img src="https://github.com/hscrocha/bc-tutorial-2018//images/pharo-solvis-contract-erc.png" width="400px" alt="Pharo Solvis ERC20" />

## 3. Smart Metrics

(Under Construction)

