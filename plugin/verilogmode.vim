scriptencoding utf-8

" s: local変数
" vimのコマンドに登録
command! -nargs=? GetVerilogPorts call s:GetVerilogPorts(<f-args>)
command! -nargs=0 GetRadix call s:GetRadix()
command! -nargs=0 ShiftReg call s:ShiftReg()
command! -nargs=0 ToggleNum call s:ToggleNum()


let s:_VERILOGMODE_VERSION = '0.0.3'
"lockvar s:_VERILOGMODE_VERSION

function! s:GetVerilogPorts(...)
    let l:sourcelist = []
    let l:no_comment_list = []
    let l:instance = []

    "let l:sourcelist = s:GetVerilogFilePath(expand('%:p:h'))
    if(a:0 > 0)
        let l:sourcelist = s:GetVerilogFilePath(a:1)
    else
        let l:sourcelist = s:GetVerilogFilePath("")
    endif

    if(len(l:sourcelist) > 0)
        let l:no_comment_list = s:GetVerilogfile(l:sourcelist)
    else
        return
    endif

    let l:instance = s:GetPortList(l:no_comment_list)
    call append(line('.'), l:instance)
endfunction

function! s:GetVerilogFilePath(_path)
    let l:searchroot = "./" . a:_path . "/"
    
    let l:filelist = []
    let l:vlist = []
    let l:svlist = []
    let l:sourcelist = []

    let s:serchfilename = expand('<cword>')
    "let l:filelist = glob("%:p:h/**/".s:serchfilename."\.*",1,1)
    let l:filelist = glob(l:searchroot . s:serchfilename . "\.*",1,1)
    let l:vlist = filter(copy(l:filelist),'v:val =~? "[.]v$"')
    let l:svlist = filter(copy(l:filelist),'v:val =~? "[.]sv$"')
    let l:sourcelist = l:vlist + l:svlist


    return l:sourcelist
endfunction

function! s:GetVerilogfile(_filepath)
    let l:filepath = a:_filepath[0]
    if(!filereadable(l:filepath))
        return 0
    endif

    let l:code = readfile(l:filepath)

    let l:no_comment_list = s:RemoveCommentAndBlank(copy(l:code))

    return l:no_comment_list
endfunction

function! s:RemoveCommentAndBlank(_list)
    if(len(a:_list) == 0)
        return 0
    endif

    let l:comment_reg = '//.*\|/\*[^*.]*\*/'
    let l:blank_reg = '^\s\+\|\s\+$'

    let l:remlist = []
    for row in a:_list
        let l:removecomment = substitute(row, l:comment_reg, "", "g")
        let l:removeblank = substitute(l:removecomment, l:blank_reg, "", "g")
        call add(l:remlist, l:removeblank)
    endfor

    return l:remlist
endfunction

function! s:GetPortList(_list)

    let l:instance = []
    let l:port_declaration = []
    let l:portmatchlist = []
    let l:port = ""

    if(len(a:_list) == 0)
        return 0
    endif

    " parameter部の正規表現
    let l:param_pattern = 'parameter\s\+\(\w\+\)\s*=\s*\(\w*\)'
    " ポート宣言部の正規表現
    let l:port_pattern = '\(input\|output\|inout\)\s*\(wire\|reg\|logic\)\?\s*\(\[.*\]\)\?\s*\(\w*\),*'

    " ポート宣言のみのリストを作成
    let l:port_declaration = filter(copy(a:_list),"v:val =~ l:port_pattern")
    " parameter宣言のみのリストを作成
    let l:param_declaration = filter(copy(a:_list),"v:val =~ l:param_pattern")

    if(len(l:param_declaration) > 0)
        " parameterの記述を作成
        call add(l:instance, "#(")
        
        for param in l:param_declaration
            let l:parammatchlist = matchlist(param, l:param_pattern)
            let l:param = "." . l:parammatchlist[1] . "()," . "// " . l:parammatchlist[2]
            call add(l:instance, l:param)
        endfor

        call add(l:instance, ")")
    endif

    " インスタンスの記述を作成
    call add(l:instance, s:serchfilename)
    call add(l:instance, "(")

    for dec in l:port_declaration
        let l:portmatchlist = matchlist(dec, l:port_pattern)
        let l:port = "." . l:portmatchlist[4] . "()," . "//" . l:portmatchlist[1] . l:portmatchlist[3]
        call add(l:instance, l:port)
    endfor

    call add(l:instance, ");")

    return l:instance

endfunction

"基数変換
function! s:ToggleNum()
    let l:curpos = getcurpos()
    let l:line = getline(l:curpos[1])
    let l:pattern = '\([0-9]*\)''\([bodhBODH]*\)\([A-F0-9_]\+\)'

    " 行の中にある数値を取得
    let l:list = s:GetMatchList(l:line,l:pattern)

    if(len(l:list) == 0)
        return
    endif

    " カーソル位置の数値を探す
    for item in l:list
        if((item[1] <= l:curpos[2]) && (item[2] >= l:curpos[2]))
            let l:target = item
        endif
    endfor

    " targetのサブマッチをとる
    let l:num = matchlist(l:target,l:pattern)

    " 基数を抜き出して変換する
    let l:flag = 0
    if(l:num[2] == "h")
        let l:substr = "'b" . s:Hex2Bin(l:num[3])
        let l:flag = 1
    endif
    if(l:num[2] == "b")
        let l:substr = "'d" . s:Bin2Dec(l:num[3])
        let l:flag = 1
    endif
    if(l:num[2] == "d")
        let l:substr = "'h" . s:Dec2Hex(l:num[3])
        let l:flag = 1
    endif

    if(l:flag == 0)
        return
    endif

    let l:substr = l:num[1] . l:substr
    echo l:substr

    let l:beforestr = ""
    let l:afterstr = ""

    if(l:target[1] != 0)
        let l:beforestr = l:line[0:(l:target[1]-1)]
    end
    let l:afterstr = l:line[(l:target[2]):]
    let l:substr = l:beforestr . l:substr . l:afterstr

    execute ":delete"

    call append(l:curpos[1]-1, l:substr)

    call setpos('.',l:curpos)

    unlet! l:beforestr
    unlet! l:afterstr
    unlet! l:substr

endfunction

"基数が不明な時、それぞれの基数での変換を表示
function! s:GetRadix()

    let l:curpos = getcurpos()
    let l:line = getline(l:curpos[1])
    let l:pattern = '\([0-9]*\)''*\([bodhBODH]*\)\([A-F0-9_]\+\)'

    " 行の中にある数値を取得
    let l:list = s:GetMatchList(l:line,l:pattern)

    if(len(l:list) == 0)
        return
    endif

    " カーソル位置の数値を探す
    for item in l:list
        if((item[1] <= l:curpos[2]) && (item[2] >= l:curpos[2]))
            let l:target = item
        endif
    endfor

    " targetのサブマッチをとる
    let l:num = matchlist(l:target,l:pattern)

    " 基数を抜き出して変換する
    let l:flag = 0
    if(l:num[2] == "h")
        let l:hex = l:num[3]
        let l:dec = s:Hex2Dec(l:num[3])
        let l:bin = s:Hex2Bin(l:num[3])
    endif
    if(l:num[2] == "b")
        let l:hex = s:Bin2Hex(l:num[3])
        let l:dec = s:Bin2Dec(l:num[3])
        let l:bin = l:num[3]
    endif
    if(l:num[2] == "d")
        let l:hex = s:Dec2Hex(l:num[3])
        let l:dec = l:num[3]
        let l:bin = s:Dec2Bin(l:num[3])
    endif
    if(l:num[2] == "")
        let l:num = expand('<cword>')
        let l:hex = s:Dec2Hex(l:num)
        let l:dec = l:num
        let l:bin = s:Dec2Bin(l:num)
    endif

    echo "'h" . l:hex ." : " . "'d" . l:dec . " : " . "'b" . l:bin

endfunction

function! s:Bin2Dec(_num)
    return str2nr(a:_num, 2)
endfunction

function! s:Bin2Hex(_num)
    return printf("%X",str2nr(a:_num,2))
endfunction

function! s:Hex2Bin(_num)
    return printf("%b",str2nr(a:_num, 16))
endfunction

function! s:Hex2Dec(_num)
    return str2nr(a:_num, 16)
endfunction

function! s:Dec2Hex(_num)
    return printf("%X", a:_num)
endfunction

function! s:Dec2Bin(_num)
    return printf("%b",a:_num)
endfunction

function! s:ShiftReg()
    let l:save_cursor = getcurpos()
    let l:declaration_pattern = '\s*\(wire\|reg\|logic\)\s*\(\[.*\]\)\?\s*'
    let l:pattern = '\(\s*\)\(\w*\)\s*<=\s*\(\w*\)'
    let l:strlist = matchlist(getline('.'),l:pattern)
    let l:indent = l:strlist[1]
    let l:left_str = l:strlist[2]
    let l:right_str = l:strlist[3]
    let l:bitlist_l = GetBitWidth(l:left_str)
    let l:bitlist_r = GetBitWidth(l:right_str)

    let l:msb_r = l:bitlist_r[0]
    let l:lsb_r = l:bitlist_r[1]

    let l:msb_l = l:bitlist_l[0] - l:msb_r - 1
    let l:lsb_l = l:bitlist_l[1]


    let l:str = l:indent . l:left_str . " <= { " . l:left_str . "[" . l:msb_l . ":" . l:lsb_l . "] , " . l:right_str . " };"
    call setpos('.',l:save_cursor)
    call append(l:save_cursor[1]-1, l:str)
    call execute(":delete")

endfunction

function! GetBitWidth(str)
    let l:dec_pattern = '\s*\(wire\|reg\|logic\)\s*\(\[.*\]\)\?\s*'
    let l:dec_str = getline(searchpos(l:dec_pattern . a:str,'w')[0])
    let l:declist = matchlist(l:dec_str,l:dec_pattern . '\(' .  a:str . '\)')
    let l:bitwidth = matchlist(l:declist[2],'\[\(\w*\):\(\w*\)\]')
    let l:msb = l:bitwidth[1]
    let l:lsb = l:bitwidth[2]
    let l:bitlist = []
    call add(l:bitlist,l:msb)
    call add(l:bitlist,l:lsb)
    return l:bitlist
endfunction

function! s:GetMatchList(expr, pat, ...)
    let l:matchstrlists = []
    let l:result = matchstrpos(a:expr,a:pat)

    while l:result[0] != ""
        call add(l:matchstrlists,l:result)
        let l:result = matchstrpos(a:expr,a:pat,l:result[2])
    endwhile
    return l:matchstrlists
endfunction
