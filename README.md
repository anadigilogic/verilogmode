# Verilogmode

## Introduction

Verilog-HDLを書く際に便利な機能を提供します。
- ファイルからインスタンス宣言を取得
- 基数変換 : Bin -> Dec -> Hex
- ポート宣言からwireリストを取得


This plugin is useful for writing Verilog-HDL.
- Retrieve the instance from the file.
- Radix conversion of numbers : Bin -> Dec -> Hex
- Get wire list from port declatation

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
``` verilog
reg[7:0]    left;
reg[1:0]    right;

always@(posedge CLK)begin
    left <= right;
end
```

Set cursor to non-blocking assignment rows and call Ex command
``` text
:ShiftReg
```

Then it will be changed as follows:
``` verilog
reg[7:0]    left;
reg[1:0]    right;

always@(posedge CLK)begin
    left <= { left[5:0] , right };
end
```
### GetRadix

Display numbers as follows
example, when used on 'h1010,it is displayed as follows 
``` text
'h1010 : 'd4112 : 'b1000000010000
```
If there is no radix,it is recognized as a decimal number.
When used on 1010,it is displayed as follows 
``` text
'hA : 'd1010 : 'b1111110010
```


### ToggleNum

Switch in order of Bin -> Dec -> Hex -> Bin -> ...

* Place the cursor on a numeric.
* Call Ex command as :ToggleNum

Toggle as shown below
``` text
4'b1010 -> 4'd10 -> 4'hA

