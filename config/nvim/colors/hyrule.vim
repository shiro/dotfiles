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

hi Normal guifg=#c0d5c1 guibg=#2d2c2b guisp=#2d2c2b gui=NONE ctermfg=151 ctermbg=236 cterm=NONE
"hi clear -- no settings --
hi IncSearch guifg=#c0d5c1 guibg=#36548f guisp=#36548f gui=NONE ctermfg=151 ctermbg=60 cterm=NONE
hi WildMenu guifg=#000000 guibg=#eb7373 guisp=#eb7373 gui=NONE ctermfg=NONE ctermbg=210 cterm=NONE
hi SignColumn guifg=#275d78 guibg=#eb7373 guisp=#eb7373 gui=NONE ctermfg=6 ctermbg=210 cterm=NONE
hi SpecialComment guifg=#9e9a98 guibg=#334455 guisp=#334455 gui=NONE ctermfg=247 ctermbg=240 cterm=NONE
hi Typedef guifg=#f5c504 guibg=#2d2c2b guisp=#2d2c2b gui=NONE ctermfg=220 ctermbg=236 cterm=NONE
hi Title guifg=#c0d5c1 guibg=#2d2c2b guisp=#2d2c2b gui=NONE ctermfg=151 ctermbg=236 cterm=NONE
hi Folded guifg=#85807c guibg=#30343d guisp=#30343d gui=NONE ctermfg=102 ctermbg=237 cterm=NONE
hi PreCondit guifg=#90c93f guibg=#2d2c2b guisp=#2d2c2b gui=NONE ctermfg=149 ctermbg=236 cterm=NONE
hi Include guifg=#f5c504 guibg=#2d2c2b guisp=#2d2c2b gui=NONE ctermfg=220 ctermbg=236 cterm=NONE
hi Float guifg=#f5c504 guibg=#2d2c2b guisp=#2d2c2b gui=NONE ctermfg=220 ctermbg=236 cterm=NONE
hi StatusLineNC guifg=#c0d5c1 guibg=#2d2c2b guisp=#2d2c2b gui=NONE ctermfg=151 ctermbg=236 cterm=NONE
hi CTagsMember guifg=NONE guibg=#eb7373 guisp=#eb7373 gui=NONE ctermfg=NONE ctermbg=210 cterm=NONE
hi NonText guifg=#c0d5c1 guibg=#2d2c2b guisp=#2d2c2b gui=NONE ctermfg=151 ctermbg=236 cterm=NONE
hi CTagsGlobalConstant guifg=NONE guibg=#eb7373 guisp=#eb7373 gui=NONE ctermfg=NONE ctermbg=210 cterm=NONE
hi DiffText guifg=#c0d5c1 guibg=#664444 guisp=#664444 gui=NONE ctermfg=151 ctermbg=95 cterm=NONE
hi ErrorMsg guifg=#eb7373 guibg=#2d2c2b guisp=#2d2c2b gui=NONE ctermfg=210 ctermbg=236 cterm=NONE
hi Ignore guifg=#cccccc guibg=#2d2c2b guisp=#2d2c2b gui=NONE ctermfg=252 ctermbg=236 cterm=NONE
hi Debug guifg=#ff9999 guibg=#2d2c2b guisp=#2d2c2b gui=NONE ctermfg=210 ctermbg=236 cterm=NONE
hi PMenuSbar guifg=NONE guibg=#2d2c2b guisp=#2d2c2b gui=NONE ctermfg=NONE ctermbg=236 cterm=NONE
hi Identifier guifg=#c0d5c1 guibg=#2d2c2b guisp=#2d2c2b gui=NONE ctermfg=151 ctermbg=236 cterm=NONE
hi SpecialChar guifg=#bbddff guibg=#2d2c2b guisp=#2d2c2b gui=NONE ctermfg=153 ctermbg=236 cterm=NONE
hi Conditional guifg=#90c93f guibg=#2d2c2b guisp=#2d2c2b gui=NONE ctermfg=149 ctermbg=236 cterm=NONE
hi StorageClass guifg=#569e16 guibg=#2d2c2b guisp=#2d2c2b gui=NONE ctermfg=70 ctermbg=236 cterm=NONE
hi Todo guifg=#359ce6 guibg=#2d2c2b guisp=#2d2c2b gui=NONE ctermfg=74 ctermbg=236 cterm=NONE
hi Special guifg=#bbddff guibg=#2d2c2b guisp=#2d2c2b gui=NONE ctermfg=153 ctermbg=236 cterm=NONE
hi LineNr guifg=#aaaaaa guibg=#2d2c2b guisp=#2d2c2b gui=NONE ctermfg=248 ctermbg=236 cterm=NONE
hi StatusLine guifg=#9ba89b guibg=#2d2c2b guisp=#2d2c2b gui=NONE ctermfg=108 ctermbg=236 cterm=NONE
hi Label guifg=#ffccff guibg=#2d2c2b guisp=#2d2c2b gui=NONE ctermfg=225 ctermbg=236 cterm=NONE
hi CTagsImport guifg=NONE guibg=#eb7373 guisp=#eb7373 gui=NONE ctermfg=NONE ctermbg=210 cterm=NONE
hi PMenuSel guifg=#ce840d guibg=#333231 guisp=#333231 gui=NONE ctermfg=172 ctermbg=236 cterm=NONE
hi Search guifg=#c0d5c1 guibg=#2d2c2b guisp=#2d2c2b gui=NONE ctermfg=151 ctermbg=236 cterm=NONE
hi CTagsGlobalVariable guifg=NONE guibg=#eb7373 guisp=#eb7373 gui=NONE ctermfg=NONE ctermbg=210 cterm=NONE
hi Delimiter guifg=#c0d5c1 guibg=#2d2c2b guisp=#2d2c2b gui=NONE ctermfg=151 ctermbg=236 cterm=NONE
hi Statement guifg=#569e16 guibg=#2d2c2b guisp=#2d2c2b gui=NONE ctermfg=70 ctermbg=236 cterm=NONE
hi SpellRare guifg=#c0d5c1 guibg=#2d2c2b guisp=#2d2c2b gui=NONE ctermfg=151 ctermbg=236 cterm=NONE
hi EnumerationValue guifg=#311ec7 guibg=#eb7373 guisp=#eb7373 gui=NONE ctermfg=4 ctermbg=210 cterm=NONE
hi Comment guifg=#716d6a guibg=#2d2c2b guisp=#2d2c2b gui=NONE ctermfg=242 ctermbg=236 cterm=NONE
hi Character guifg=#569e16 guibg=#2d2c2b guisp=#2d2c2b gui=NONE ctermfg=70 ctermbg=236 cterm=NONE
hi TabLineSel guifg=#90c93f guibg=#2d2c2b guisp=#2d2c2b gui=NONE ctermfg=149 ctermbg=236 cterm=NONE
hi Number guifg=#f5c504 guibg=#2d2c2b guisp=#2d2c2b gui=NONE ctermfg=220 ctermbg=236 cterm=NONE
hi Boolean guifg=#f5c504 guibg=#2d2c2b guisp=#2d2c2b gui=NONE ctermfg=220 ctermbg=236 cterm=NONE
hi Operator guifg=#90c93f guibg=#2d2c2b guisp=#2d2c2b gui=NONE ctermfg=149 ctermbg=236 cterm=NONE
hi CursorLine guifg=#c0d5c1 guibg=#2c445c guisp=#2c445c gui=NONE ctermfg=151 ctermbg=17 cterm=NONE
hi Union guifg=#b5219f guibg=#eb7373 guisp=#eb7373 gui=NONE ctermfg=126 ctermbg=210 cterm=NONE
hi TabLineFill guifg=NONE guibg=#2d2c2b guisp=#2d2c2b gui=NONE ctermfg=NONE ctermbg=236 cterm=NONE
hi Question guifg=#f5c504 guibg=#2d2c2b guisp=#2d2c2b gui=NONE ctermfg=220 ctermbg=236 cterm=NONE
hi WarningMsg guifg=#eb7373 guibg=#2d2c2b guisp=#2d2c2b gui=NONE ctermfg=210 ctermbg=236 cterm=NONE
hi VisualNOS guifg=#bdb84f guibg=#eb7373 guisp=#eb7373 gui=NONE ctermfg=143 ctermbg=210 cterm=NONE
hi DiffDelete guifg=#c0d5c1 guibg=#664444 guisp=#664444 gui=NONE ctermfg=151 ctermbg=95 cterm=NONE
hi ModeMsg guifg=#ffeecc guibg=#2d2c2b guisp=#2d2c2b gui=NONE ctermfg=230 ctermbg=236 cterm=NONE
hi CursorColumn guifg=#c0d5c1 guibg=#2c445c guisp=#2c445c gui=NONE ctermfg=151 ctermbg=17 cterm=NONE
hi Define guifg=#f5c504 guibg=#2d2c2b guisp=#2d2c2b gui=NONE ctermfg=220 ctermbg=236 cterm=NONE
hi Function guifg=#569e16 guibg=#2d2c2b guisp=#2d2c2b gui=NONE ctermfg=70 ctermbg=236 cterm=NONE
hi FoldColumn guifg=#85807c guibg=#30343d guisp=#30343d gui=NONE ctermfg=102 ctermbg=237 cterm=NONE
hi PreProc guifg=#90c93f guibg=#2d2c2b guisp=#2d2c2b gui=NONE ctermfg=149 ctermbg=236 cterm=NONE
hi EnumerationName guifg=#606331 guibg=#eb7373 guisp=#eb7373 gui=NONE ctermfg=58 ctermbg=210 cterm=NONE
hi Visual guifg=#ffffff guibg=#557799 guisp=#557799 gui=NONE ctermfg=15 ctermbg=67 cterm=NONE
hi MoreMsg guifg=#ffeecc guibg=#2d2c2b guisp=#2d2c2b gui=NONE ctermfg=230 ctermbg=236 cterm=NONE
hi SpellCap guifg=#c0d5c1 guibg=#2d2c2b guisp=#2d2c2b gui=NONE ctermfg=151 ctermbg=236 cterm=NONE
hi VertSplit guifg=#ffffff guibg=#2d2c2b guisp=#2d2c2b gui=NONE ctermfg=15 ctermbg=236 cterm=NONE
hi Exception guifg=#569e16 guibg=#2d2c2b guisp=#2d2c2b gui=NONE ctermfg=70 ctermbg=236 cterm=NONE
hi Keyword guifg=#90c93f guibg=#2d2c2b guisp=#2d2c2b gui=NONE ctermfg=149 ctermbg=236 cterm=NONE
hi Type guifg=#90c93f guibg=#2d2c2b guisp=#2d2c2b gui=NONE ctermfg=149 ctermbg=236 cterm=NONE
hi DiffChange guifg=#c0d5c1 guibg=#3a5738 guisp=#3a5738 gui=NONE ctermfg=151 ctermbg=65 cterm=NONE
hi Cursor guifg=#2d2c2b guibg=#c0d5c1 guisp=#c0d5c1 gui=NONE ctermfg=236 ctermbg=151 cterm=NONE
hi SpellLocal guifg=#c0d5c1 guibg=#2d2c2b guisp=#2d2c2b gui=NONE ctermfg=151 ctermbg=236 cterm=NONE
hi Error guifg=#eb7373 guibg=#2d2c2b guisp=#2d2c2b gui=NONE ctermfg=210 ctermbg=236 cterm=NONE
hi PMenu guifg=#90c93f guibg=#3b3a39 guisp=#3b3a39 gui=NONE ctermfg=149 ctermbg=237 cterm=NONE
hi SpecialKey guifg=#c0d5c1 guibg=#2d2c2b guisp=#2d2c2b gui=NONE ctermfg=151 ctermbg=236 cterm=NONE
hi Constant guifg=#ffffff guibg=#2d2c2b guisp=#2d2c2b gui=NONE ctermfg=15 ctermbg=236 cterm=NONE
hi DefinedName guifg=#026191 guibg=#eb7373 guisp=#eb7373 gui=NONE ctermfg=24 ctermbg=210 cterm=NONE
hi Tag guifg=#bbddff guibg=#2d2c2b guisp=#2d2c2b gui=NONE ctermfg=153 ctermbg=236 cterm=NONE
hi String guifg=#ce840d guibg=#2d2c2b guisp=#2d2c2b gui=NONE ctermfg=172 ctermbg=236 cterm=NONE
hi PMenuThumb guifg=NONE guibg=#90c93f guisp=#90c93f gui=NONE ctermfg=NONE ctermbg=149 cterm=NONE
hi MatchParen guifg=#ce840d guibg=#2d2c2b guisp=#2d2c2b gui=NONE ctermfg=172 ctermbg=236 cterm=NONE
hi LocalVariable guifg=#ff1c1c guibg=#eb7373 guisp=#eb7373 gui=NONE ctermfg=196 ctermbg=210 cterm=NONE
hi Repeat guifg=#90c93f guibg=#2d2c2b guisp=#2d2c2b gui=NONE ctermfg=149 ctermbg=236 cterm=NONE
hi SpellBad guifg=#bbddff guibg=#2d2c2b guisp=#2d2c2b gui=NONE ctermfg=153 ctermbg=236 cterm=NONE
hi CTagsClass guifg=#7e4aba guibg=#eb7373 guisp=#eb7373 gui=NONE ctermfg=97 ctermbg=210 cterm=NONE
hi Directory guifg=#337700 guibg=#2d2c2b guisp=#2d2c2b gui=NONE ctermfg=2 ctermbg=236 cterm=NONE
hi Structure guifg=#c0d5c1 guibg=#2d2c2b guisp=#2d2c2b gui=NONE ctermfg=151 ctermbg=236 cterm=NONE
hi Macro guifg=#f5c504 guibg=#2d2c2b guisp=#2d2c2b gui=NONE ctermfg=220 ctermbg=236 cterm=NONE
hi Underlined guifg=#99ccff guibg=#2d2c2b guisp=#2d2c2b gui=underline ctermfg=153 ctermbg=236 cterm=underline
hi DiffAdd guifg=#c0d5c1 guibg=#2c445c guisp=#2c445c gui=NONE ctermfg=151 ctermbg=17 cterm=NONE
hi TabLine guifg=NONE guibg=#2d2c2b guisp=#2d2c2b gui=NONE ctermfg=NONE ctermbg=236 cterm=NONE
hi titled guifg=#c0d5c1 guibg=#2d2c2b guisp=#2d2c2b gui=NONE ctermfg=151 ctermbg=236 cterm=NONE
hi htmlh2 guifg=#c0d5c1 guibg=#2d2c2b guisp=#2d2c2b gui=NONE ctermfg=151 ctermbg=236 cterm=NONE

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
