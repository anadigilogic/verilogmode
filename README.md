# Verilogmode

## Introduction

This plugin is useful for writing Verilog-HDL.
Retrieve the instance from the file.

## How to use

### GetVerilogPorts

* Move cursor on words that is module-name.
* Call Ex command as :GetVerilogPorts  

  To set the directory path, enter the command followed by the relative path from the current directory.

  ``` text
  :GetVerilogPorts path
  ```

* Search under the directory for files with the same name as module-name.
* If file exist, append instance under the cursor line.

### ShiftReg

Search wire,reg,logic declaration and get bit width.
Set variable as shift register.

* Move cursor to non-blocking assignment
* Call Ex command as :ShiftReg

    example
    ```verilog
    reg[7:0]    left;
    reg[1:0]    right;

    always@(posedge CLK)begin
        left <= right;
    end
    ```

    Set cursor to non-blocking assignment rows and call Ex command
    ```text
    :ShiftReg
    ```

    Then it will be changed as follows:
    ```verilog
    reg[7:0]    left;
    reg[1:0]    right;

    always@(posedge CLK)begin
        left <= { left[5:0] , right };
    end
    ```
