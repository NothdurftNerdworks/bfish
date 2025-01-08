# bfish
Lightweight MATLAB framework to internationalize strings used in GUI and command-line applications.

## Overview
### Problem Solved

### Architecture

### Scope & Limitations
* Designed only for phrase matching & replacement - it does *not* detect intent or translate complex language structure.
* Designed for text only - it does *not* attempt to alter numbers, dates.
* Designed for minimal changes to original GUI.
* *Assumes* Left-to-Right (LTR) language. In principle there is nothing stopping a developer from using bfish with Right-to-Left (RTL) languages, but RTL usage typically involves modifying the overall GUI layout. Such modifications are beyond the current scope.

## Installation
**bfish** is released as a [MATLAB](https://matlab.mathworks.com/) [Namespace Folder](https://www.mathworks.com/help/matlab/matlab_oop/namespaces.html) (aka Package Folder). For general installation simply:
1. Download package *(Once released)*
2. Unzip to folder of your choosing
3. Copy the "+bfish" folder in to the base folder of your MATLAB project

## General Use
### Commmand-Line


### GUI


