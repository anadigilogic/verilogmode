scriptencoding utf-8

" s: local変数
" vimのコマンドに登録
command! -nargs=? GetVerilogPorts call s:GetVerilogPorts(<f-args>)
command! -nargs=0 GetRadix call s:GetRadix()

let s:_VERILOGMODE_VERSION = '0.0.1'
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

    " ポート宣言部の正規表現
    let l:port_reg = '\(input\|output\|inout\)\s\+\(wire\|reg\)*\s*\(\[.*\]\)\s*\(\w*\),*'

    " ポート宣言のみのリストを作成
    let l:port_declaration = filter(copy(a:_list),"v:val =~ l:port_reg")

    " インスタンスの記述を作成
    call add(l:instance, s:serchfilename."(")

    for dec in l:port_declaration
        let l:portmatchlist = matchlist(dec, l:port_reg)
        let l:port = "." . l:portmatchlist[4] . "()," . "//" . l:portmatchlist[1] . l:portmatchlist[3]
        call add(l:instance, l:port)
    endfor

    call add(l:instance, ");")

    return l:instance

endfunction

"基数が不明な時、それぞれの基数での変換を表示
function! s:GetRadix()
    let l:reg = '[^ABCDEF0-9_]'
    let l:word = expand('<cword>')
    let l:num = substitute(l:word,l:reg,"","g")

    let l:dec2hex = str2nr(l:num, 16)
    let l:hex2dec = printf("%x",l:num)
    let l:bin2dec = str2nr(l:num, 2)
    let l:bin2hex = printf("%x",l:bin2dec)

    let l:hex2bin = printf("%b",l:dec2hex)
    let l:dec2bin = printf("%b",l:num)

    let l:rad = l:word[0]

    echo "'h " . l:num . " -> " ."'d " . l:dec2hex . " -> " . "'b " . l:hex2bin
    echo "'d " . l:num . " -> " ."'h " . l:hex2dec . " -> " . "'b " . l:dec2bin
    echo "'b " . l:num . " -> " ."'d " . l:bin2dec . " -> " . "'h " . l:bin2hex

endfunction

