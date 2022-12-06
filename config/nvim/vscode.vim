nnoremap gd <Cmd>call VSCodeNotify('editor.action.revealDefinition')<CR>
nnoremap <leader>w <Cmd>call VSCodeNotify('workbench.action.files.save')<CR>

nnoremap ]e <Cmd>call VSCodeNotify('editor.action.marker.next')<CR>
nnoremap [e <Cmd>call VSCodeNotify('editor.action.marker.prev')<CR>

nnoremap ]c <Cmd>call VSCodeNotify('workbench.action.editor.nextChange')<CR><Cmd>call VSCodeNotify('editor.action.dirtydiff.next')<CR>
nnoremap [c <Cmd>call VSCodeNotify('workbench.action.editor.previousChange')<CR><Cmd>call VSCodeNotify('editor.action.dirtydiff.next')<CR>

nnoremap <leader>yy <Cmd>call VSCodeNotify('copyRelativeFilePath')<CR>

nmap <Esc> :noh<CR>


