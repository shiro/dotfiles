" Vim color file - hyrule
set background=dark
if version > 580
	hi clear
	if exists("syntax_on")
		syntax reset
	endif
endif

set t_Co=256
let g:colors_name = "hyrule"

hi Normal guifg=#c0d5c1 guibg=NONE guisp=#2d2c2b gui=NONE ctermfg=151 ctermbg=NONE cterm=NONE
"hi clear -- no settings --
"hi IncSearch guifg=#c0d5c1 guibg=NONE guisp=#36548f gui=NONE ctermfg=151 ctermbg=NONE cterm=NONE
hi WildMenu guifg=#000000 guibg=NONE guisp=#eb7373 gui=NONE ctermfg=NONE ctermbg=NONE cterm=NONE
hi SignColumn guifg=#275d78 guibg=NONE guisp=#eb7373 gui=NONE ctermfg=6 ctermbg=NONE cterm=NONE
hi SpecialComment guifg=#9e9a98 guibg=NONE guisp=#334455 gui=NONE ctermfg=247 ctermbg=NONE cterm=NONE
hi Typedef guifg=#f5c504 guibg=NONE guisp=#2d2c2b gui=NONE ctermfg=220 ctermbg=NONE cterm=NONE
hi Title guifg=#c0d5c1 guibg=NONE guisp=#2d2c2b gui=NONE ctermfg=151 ctermbg=NONE cterm=NONE
" hi Folded guifg=#85807c guibg=NONE guisp=#30343d gui=NONE ctermfg=102 ctermbg=NONE cterm=NONE
hi PreCondit guifg=#90c93f guibg=NONE guisp=#2d2c2b gui=NONE ctermfg=149 ctermbg=NONE cterm=NONE
hi Include guifg=#f5c504 guibg=NONE guisp=#2d2c2b gui=NONE ctermfg=220 ctermbg=NONE cterm=NONE
hi Float guifg=#f5c504 guibg=NONE guisp=#2d2c2b gui=NONE ctermfg=220 ctermbg=NONE cterm=NONE
" hi StatusLineNC guifg=#c0d5c1 guibg=NONE guisp=#2d2c2b gui=NONE ctermfg=151 ctermbg=NONE cterm=NONE
hi CTagsMember guifg=NONE guibg=NONE guisp=#eb7373 gui=NONE ctermfg=NONE ctermbg=NONE cterm=NONE
hi NonText guifg=#c0d5c1 guibg=NONE guisp=#2d2c2b gui=NONE ctermfg=151 ctermbg=NONE cterm=NONE
hi CTagsGlobalConstant guifg=NONE guibg=NONE guisp=#eb7373 gui=NONE ctermfg=NONE ctermbg=NONE cterm=NONE
" hi DiffText guifg=#c0d5c1 guibg=#664444 guisp=#664444 gui=NONE ctermfg=151 ctermbg=95 cterm=NONE
hi ErrorMsg guifg=#eb7373 guibg=NONE guisp=#2d2c2b gui=NONE ctermfg=210 ctermbg=NONE cterm=NONE
hi Ignore guifg=#cccccc guibg=NONE guisp=#2d2c2b gui=NONE ctermfg=252 ctermbg=NONE cterm=NONE
hi Debug guifg=#ff9999 guibg=NONE guisp=#2d2c2b gui=NONE ctermfg=210 ctermbg=NONE cterm=NONE
hi PMenuSbar guifg=NONE guibg=NONE guisp=#2d2c2b gui=NONE ctermfg=NONE ctermbg=NONE cterm=NONE
hi Identifier guifg=#c0d5c1 guibg=NONE guisp=#2d2c2b gui=NONE ctermfg=151 ctermbg=NONE cterm=NONE
hi SpecialChar guifg=#bbddff guibg=NONE guisp=#2d2c2b gui=NONE ctermfg=153 ctermbg=NONE cterm=NONE
hi Conditional guifg=#90c93f guibg=NONE guisp=#2d2c2b gui=NONE ctermfg=149 ctermbg=NONE cterm=NONE
hi StorageClass guifg=#569e16 guibg=NONE guisp=#2d2c2b gui=NONE ctermfg=70 ctermbg=NONE cterm=NONE
hi Todo guifg=#359ce6 guibg=NONE guisp=#2d2c2b gui=NONE ctermfg=74 ctermbg=NONE cterm=NONE
hi Special guifg=#bbddff guibg=NONE guisp=#2d2c2b gui=NONE ctermfg=153 ctermbg=NONE cterm=NONE
" hi LineNr guifg=#aaaaaa guibg=NONE guisp=#2d2c2b gui=NONE ctermfg=248 ctermbg=NONE cterm=NONE
" hi StatusLine guifg=#9ba89b guibg=NONE guisp=#2d2c2b gui=NONE ctermfg=108 ctermbg=NONE cterm=NONE
hi Label guifg=#ffccff guibg=NONE guisp=#2d2c2b gui=NONE ctermfg=225 ctermbg=NONE cterm=NONE
hi CTagsImport guifg=NONE guibg=NONE guisp=#eb7373 gui=NONE ctermfg=NONE ctermbg=NONE cterm=NONE
hi PMenuSel guifg=#ce840d guibg=NONE guisp=#333231 gui=NONE ctermfg=172 ctermbg=NONE cterm=NONE
"hi Search guifg=#c0d5c1 guibg=NONE guisp=#2d2c2b gui=NONE ctermfg=151 ctermbg=NONE cterm=NONE
hi CTagsGlobalVariable guifg=NONE guibg=NONE guisp=#eb7373 gui=NONE ctermfg=NONE ctermbg=NONE cterm=NONE
hi Delimiter guifg=#c0d5c1 guibg=NONE guisp=#2d2c2b gui=NONE ctermfg=151 ctermbg=NONE cterm=NONE
hi Statement guifg=#569e16 guibg=NONE guisp=#2d2c2b gui=NONE ctermfg=70 ctermbg=NONE cterm=NONE
hi SpellRare guifg=#c0d5c1 guibg=NONE guisp=#2d2c2b gui=NONE ctermfg=151 ctermbg=NONE cterm=NONE
hi EnumerationValue guifg=#311ec7 guibg=NONE guisp=#eb7373 gui=NONE ctermfg=4 ctermbg=NONE cterm=NONE
hi Comment guifg=#716d6a guibg=NONE guisp=#2d2c2b gui=NONE ctermfg=242 ctermbg=NONE cterm=NONE
hi Character guifg=#569e16 guibg=NONE guisp=#2d2c2b gui=NONE ctermfg=70 ctermbg=NONE cterm=NONE
hi TabLineSel guifg=#90c93f guibg=NONE guisp=#2d2c2b gui=NONE ctermfg=149 ctermbg=NONE cterm=NONE
hi Number guifg=#f5c504 guibg=NONE guisp=#2d2c2b gui=NONE ctermfg=220 ctermbg=NONE cterm=NONE
hi Boolean guifg=#f5c504 guibg=NONE guisp=#2d2c2b gui=NONE ctermfg=220 ctermbg=NONE cterm=NONE
hi Operator guifg=#90c93f guibg=NONE guisp=#2d2c2b gui=NONE ctermfg=149 ctermbg=NONE cterm=NONE
" hi CursorLine guifg=#c0d5c1 guibg=NONE guisp=#2c445c gui=NONE ctermfg=151 ctermbg=NONE cterm=NONE
hi Union guifg=#b5219f guibg=NONE guisp=#eb7373 gui=NONE ctermfg=126 ctermbg=NONE cterm=NONE
hi TabLineFill guifg=NONE guibg=NONE guisp=#2d2c2b gui=NONE ctermfg=NONE ctermbg=NONE cterm=NONE
hi Question guifg=#f5c504 guibg=NONE guisp=#2d2c2b gui=NONE ctermfg=220 ctermbg=NONE cterm=NONE
hi WarningMsg guifg=#eb7373 guibg=NONE guisp=#2d2c2b gui=NONE ctermfg=210 ctermbg=NONE cterm=NONE
"hi VisualNOS guifg=#bdb84f guibg=NONE guisp=#eb7373 gui=NONE ctermfg=143 ctermbg=NONE cterm=NONE
"hi DiffDelete guifg=#c0d5c1 guibg=#664444 guisp=#664444 gui=NONE ctermfg=151 ctermbg=95 cterm=NONE
hi ModeMsg guifg=#ffeecc guibg=NONE guisp=#2d2c2b gui=NONE ctermfg=230 ctermbg=NONE cterm=NONE
" hi CursorColumn guifg=#c0d5c1 guibg=NONE guisp=#2c445c gui=NONE ctermfg=151 ctermbg=NONE cterm=NONE
hi Define guifg=#f5c504 guibg=NONE guisp=#2d2c2b gui=NONE ctermfg=220 ctermbg=NONE cterm=NONE
hi Function guifg=#569e16 guibg=NONE guisp=#2d2c2b gui=NONE ctermfg=70 ctermbg=NONE cterm=NONE
hi FoldColumn guifg=#85807c guibg=NONE guisp=#30343d gui=NONE ctermfg=102 ctermbg=NONE cterm=NONE
hi PreProc guifg=#90c93f guibg=NONE guisp=#2d2c2b gui=NONE ctermfg=149 ctermbg=NONE cterm=NONE
hi EnumerationName guifg=#606331 guibg=NONE guisp=#eb7373 gui=NONE ctermfg=58 ctermbg=NONE cterm=NONE
"hi Visual guifg=#ffffff guibg=NONE guisp=#557799 gui=NONE ctermfg=15 ctermbg=NONE cterm=NONE
hi MoreMsg guifg=#ffeecc guibg=NONE guisp=#2d2c2b gui=NONE ctermfg=230 ctermbg=NONE cterm=NONE
hi SpellCap guifg=#c0d5c1 guibg=NONE guisp=#2d2c2b gui=NONE ctermfg=151 ctermbg=NONE cterm=NONE
hi VertSplit guifg=#ffffff guibg=NONE guisp=#2d2c2b gui=NONE ctermfg=15 ctermbg=NONE cterm=NONE
hi Exception guifg=#569e16 guibg=NONE guisp=#2d2c2b gui=NONE ctermfg=70 ctermbg=NONE cterm=NONE
hi Keyword guifg=#90c93f guibg=NONE guisp=#2d2c2b gui=NONE ctermfg=149 ctermbg=NONE cterm=NONE
hi Type guifg=#90c93f guibg=NONE guisp=#2d2c2b gui=NONE ctermfg=149 ctermbg=NONE cterm=NONE
" hi DiffChange guifg=#c0d5c1 guibg=#3a5738 guisp=#3a5738 gui=NONE ctermfg=151 ctermbg=65 cterm=NONE
"hi Cursor guifg=#2d2c2b guibg=NONE guisp=#c0d5c1 gui=NONE ctermfg=236 ctermbg=NONE cterm=NONE
hi SpellLocal guifg=#c0d5c1 guibg=NONE guisp=#2d2c2b gui=NONE ctermfg=151 ctermbg=NONE cterm=NONE
hi Error guifg=#eb7373 guibg=NONE guisp=#2d2c2b gui=NONE ctermfg=210 ctermbg=NONE cterm=NONE
hi PMenu guifg=#90c93f guibg=NONE guisp=#3b3a39 gui=NONE ctermfg=149 ctermbg=NONE cterm=NONE
hi SpecialKey guifg=#c0d5c1 guibg=NONE guisp=#2d2c2b gui=NONE ctermfg=151 ctermbg=NONE cterm=NONE
" hi Constant guifg=#ffffff guibg=NONE guisp=#2d2c2b gui=NONE ctermfg=15 ctermbg=NONE cterm=NONE
hi DefinedName guifg=#026191 guibg=NONE guisp=#eb7373 gui=NONE ctermfg=24 ctermbg=NONE cterm=NONE
" hi Tag guifg=#bbddff guibg=NONE guisp=#2d2c2b gui=NONE ctermfg=153 ctermbg=NONE cterm=NONE
" hi String guifg=#ce840d guibg=NONE guisp=#2d2c2b gui=NONE ctermfg=172 ctermbg=NONE cterm=NONE
hi PMenuThumb guifg=NONE guibg=NONE guisp=#90c93f gui=NONE ctermfg=NONE ctermbg=NONE cterm=NONE
hi MatchParen guifg=#ce840d guibg=NONE guisp=#2d2c2b gui=NONE ctermfg=172 ctermbg=NONE cterm=NONE
hi LocalVariable guifg=#ff1c1c guibg=NONE guisp=#eb7373 gui=NONE ctermfg=196 ctermbg=NONE cterm=NONE
hi Repeat guifg=#90c93f guibg=NONE guisp=#2d2c2b gui=NONE ctermfg=149 ctermbg=NONE cterm=NONE
hi SpellBad guifg=#bbddff guibg=NONE guisp=#2d2c2b gui=NONE ctermfg=153 ctermbg=NONE cterm=NONE
hi CTagsClass guifg=#7e4aba guibg=NONE guisp=#eb7373 gui=NONE ctermfg=97 ctermbg=NONE cterm=NONE
hi Directory guifg=#337700 guibg=NONE guisp=#2d2c2b gui=NONE ctermfg=2 ctermbg=NONE cterm=NONE
hi Structure guifg=#c0d5c1 guibg=NONE guisp=#2d2c2b gui=NONE ctermfg=151 ctermbg=NONE cterm=NONE
hi Macro guifg=#f5c504 guibg=NONE guisp=#2d2c2b gui=NONE ctermfg=220 ctermbg=NONE cterm=NONE
hi Underlined guifg=#99ccff guibg=NONE guisp=#2d2c2b gui=underline ctermfg=153 ctermbg=NONE cterm=underline
"hi DiffAdd guifg=#c0d5c1 guibg=#2c445c guisp=#2c445c gui=NONE ctermfg=151 ctermbg=17 cterm=NONE
hi TabLine guifg=NONE guibg=NONE guisp=#2d2c2b gui=NONE ctermfg=NONE ctermbg=NONE cterm=NONE
hi titled guifg=#c0d5c1 guibg=NONE guisp=#2d2c2b gui=NONE ctermfg=151 ctermbg=NONE cterm=NONE
hi htmlh2 guifg=#c0d5c1 guibg=NONE guisp=#2d2c2b gui=NONE ctermfg=151 ctermbg=NONE cterm=NONE



let test='#ff0000'


let bg='#2D2C2B'
let shadow='#383735'
let error='#CC4542'
let white='#C0D5C1'
let yellow='#F5C504'
let lightGreen='#90C93F'
let darkGreen='#569E16'
let brown='#93784E'
let orange='#CE830D'
let blue='#458383'
let cyan='#007E8A'
let dirt='#7A7A43'
let red='#DD6718'
let lightRed='#CC4542'
let gray='#716D6A'
let caret='#989BA2'
let selection='#161A1F'
let diffAdd='#304D2E'
let diffAddDark='#313630'
let diffAddFg='#50804C'
let diffMod='#2E455D'
let diffModFg='#446588'
let diffModDark='#323334'
let diffDel='#533232'
let diffDelDark='#363030'
let diffDelFg='#7F4D4D'
let ore='#5B5957'


" editor
exe "hi Cursor guifg=".test." guibg=".white." gui=bold,underline"
exe "hi Visual guibg=".selection
exe "hi LineNr guibg=None guifg=".ore
exe "hi CocHighlightText guibg=NONE guifg=".yellow
exe "hi CocFadeOut guibg=NONE"
exe "hi CocErrorSign guibg=NONE guifg=".red
exe "hi CocWarningSign guibg=NONE guifg=".gray
exe "hi CocInfoSign guibg=NONE guifg=".gray
exe "hi CocHintSign guibg=NONE guifg=".gray
exe "hi CocErrorVirtualText guibg=NONE"
exe "hi CocWarningVirtualText guibg=NONE"
exe "hi CocInfoVirtualText guibg=NONE"
exe "hi CocHintVirtualText guibg=NONE"
exe "hi CocErrorHighlight guibg=NONE guifg=".red
exe "hi CocWarningHighlight guibg=NONE guifg=".test
exe "hi CocInfoHighlight guibg=NONE"
exe "hi CocHintHighlight guibg=NONE guifg=".brown
exe "hi CocDeprecatedHighlight guibg=NONE guifg=".gray
exe "hi CocUnusedHighlight guibg=NONE guifg=".gray
exe "hi CocErrorLine guibg=NONE guifg=".red
exe "hi CocWarningLine guibg=NONE guifg=None"
exe "hi CocInfoLine guibg=NONE guifg=None"
exe "hi CocHintLine guibg=NONE guifg=None"
exe "hi Search guibg=".lightGreen." guifg=".bg." gui=NONE"
exe "hi CurSearch guibg=".yellow." guifg=".bg." gui=NONE"
exe "hi IncSearch guibg=".yellow." guifg=".bg." gui=NONE"
exe "hi Folded guibg=None guifg=".brown." gui=NONE"

" omnibar
exe "hi TelescopeMatching guifg=".orange
exe "hi TelescopeSelectionCaret guibg=".shadow
exe "hi TelescopeSelection guibg=".shadow

" popups
exe "hi FgCocHintFloatBgCocFloating guifg=".yellow
exe "hi CocFloating guifg=".white
exe "hi FloatBorder guifg=".white

" language agnostic
exe "hi Tag guibg=None guifg=".lightGreen
exe "hi String guibg=None guifg=".orange
exe "hi Constant guibg=None guifg=".yellow
exe "hi Include guifg=".lightGreen
exe "hi Type guifg=".darkGreen


" diff
exe "hi @text.diff.add.diff guibg="..diffAddDark.." guifg=".white
exe "hi @text.diff.delete.diff guibg="..diffDelDark.." guifg=".white
exe "hi DiffAdd guibg=".diffAdd." guifg=None"
exe "hi DiffChange gui=None guibg=".diffModDark." guifg=None"
exe "hi DiffDelete gui=None guibg=".diffDel." guifg=".diffDel
exe "hi DiffText gui=None guibg=".diffMod." guifg=None"
exe "hi GitGutterAdd guifg=".diffAdd." guibg=".diffAdd
exe "hi GitGutterAddLineNr guifg=".diffAddFg." guibg=".diffAdd
exe "hi GitGutterChange guifg=".diffMod." guibg=".diffMod
exe "hi GitGutterChangeLineNr guifg=".diffModFg." guibg=".diffMod
exe "hi GitGutterDelete guifg=".diffDel." guibg=".diffDel
exe "hi GitGutterDeleteLineNr guifg=".diffDelFg." guibg=".diffDel
exe "hi diffAdded guifg=".white." guibg=".diffAdd
exe "hi diffChanged guifg=".white." guibg=".diffMod
exe "hi diffRemoved guifg=".white." guibg=".diffDel

exe "hi WinSeparator guifg=".shadow
exe "hi StatusLine gui=None guifg=".ore
exe "hi StatusLineNC gui=None guifg=".ore


" JSON

exe "hi @label.json guifg=".lightGreen

" TypeScript

exe "hi typescriptExport guifg=".lightGreen
exe "hi typescriptImport guifg=".lightGreen
exe "hi tsxTagName guifg=".lightGreen
exe "hi @constant.builtin.tsx guifg=".yellow
exe "hi @tag.tsx guifg=".lightGreen
exe "hi @variable.tsx guifg=".blue
exe "hi @constructor.tsx guifg=".lightGreen
exe "hi tsxAttrib guifg=".darkGreen
exe "hi @tag.attribute.tsx guifg=".darkGreen
exe "hi typescriptVariable guifg=".lightGreen
exe "hi typescriptIdentifierName guifg=".cyan
exe "hi typescriptInterfaceName guifg=".white
exe "hi typescriptMember guifg=".white
exe "hi @tag.delimiter.tsx guifg=".white
exe "hi @method.call.tsx guifg=".dirt
exe "hi typescriptEndColons guifg=".white
exe "hi typescriptTypeReference guifg=".darkGreen
exe "hi typescriptSpecial guifg=".darkGreen
exe "hi typescriptObjectLabel guifg=".white
exe "hi typescriptObjectStaticMethod guifg=".dirt
exe "hi typescriptBraces guifg=".white
exe "hi typescriptArrowFuncArg guifg=".white
exe "hi typescriptStatementKeyword guifg=".lightGreen
exe "hi typescriptVariableDeclaration guifg=".orange

" Rust
exe "hi rustModPath guifg=".white
exe "hi rsDelimiter guifg=".white
exe "hi rsAttribute guifg=".yellow
exe "hi rustEnum guifg=".darkGreen
exe "hi rsUserFunc guifg=".lightGreen
exe "hi rsUse guifg=".lightGreen
exe "hi rsUserMethod guifg=".lightGreen
exe "hi rsForeignFunc guifg=".lightGreen
exe "hi rsForeignType guifg=".darkGreen
exe "hi rsTrue guifg=".lightGreen
exe "hi rsNumber guifg=".orange
exe "hi rsTypeParamDef guifg=".cyan
exe "hi rsLibraryType guifg=".darkGreen
exe "hi rsUserConst guifg=".darkGreen
exe "hi rsUserType guifg=".darkGreen
exe "hi rsTypeDef guifg=".white
exe "hi @constant.builtin.rust guifg=".darkGreen
exe "hi @function.rust guifg=".dirt
exe "hi @function.call.rust guifg=".lightGreen
exe "hi @constant.rust guifg=".darkGreen
exe "hi rsFuncDef guifg=".orange
exe "hi rsUserMacro guifg=".red
exe "hi rsLibraryMacro guifg=".red
exe "hi rsStaticLifetime guifg=".cyan
exe "hi rsModule guifg=".white
exe "hi rustAttribute guifg=".white
"exe "hi CocFloating guifg=".white
exe "hi DiagnosticError guifg=".error
"exe "hi FloatShadow guibg=".lightGreen
"set winblend=30
exe "hi GitGutterAddIntraLine guifg=None guibg=".diffMod." gui=None"
exe "hi GitGutterDeleteIntraLine guifg=None guibg=".diffDel." gui=None"


"DiagnosticWarn
"DiagnosticInfo
"DiagnosticHint
"DiagnosticOk


" Vim
exe 'hi vimVar guifg='.white

hi link TagbarAccessPublic Error
hi link TagbarAccessProtected Error
hi link TagbarAccessPrivate Error

" Vimwiki:
hi link VimwikiHeader1 Boolean
hi link VimwikiHeader2 String
hi link VimwikiHeader3 String
hi link VimwikiHeader4 String
hi link VimwikiHeader5 String
hi link VimwikiHeader6 String
