# Hands-on: Pharo Tools for Smart Contract Analysis

In this material, I will present tools coded in Pharo Smalltalk for smart contract analysis. 

## 1. Pharo

[Pharo](https://pharo.org/) is a fully integrated programming environment (kind like an IDE + OS + APIs). Pharo is smalltalk dialect. If you want to learn more about Pharo, their [MOOC](https://mooc.pharo.org/) is a nice starting point.

For this tutorial, you wont need to know how to code in Pharo. I will give all code and instructions to execute the tools. Just remember that Pharo is an image based system (a very rough analogy would be docker images) instead of file based.

## 2. Visualization

One of the analysis tools we have developed is a Visualization for smart contracts. We are still working on improving the visualization approach, and if you want help please answer this [academic survey]().

First, we need to install SmaCC on your Pharo image. Run the following code in a playground screen:

```pharo
Metacello new
    baseline: 'SmaCC';
    repository: 'github://SmaCCRefactoring/SmaCC';
    load.
```

Now, you can get the visualization tool by running the following code on a playground:
```pharo
Metacello new
    baseline: 'SolVis';
    repository: 'github://hscrocha/SolVis';
    load.
```

The Solidity smart contract visualization tool is now installed in your image. Do a click on the main Pharo window to open the menu, you will see a new option there called XX.

![images/pharo-solvis.png]


