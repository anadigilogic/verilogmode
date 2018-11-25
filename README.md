# Verilogmode

## Introduction

This plugin is useful for writing Verilog-HDL.
Retrieve the instance from the file.

## How to use

* Move cursor on words that is module-name.
* Call Ex command as :GetVerilogPorts.  

  To set the directory path, enter the command followed by the relative path from the current directory.

  ``` text
  :GetVerilogPorts path
  ```

* Search under the directory for files with the same name as module-name.
* If file exist, append instance under the cursor line.

