nnoremap <space>g :set operatorfunc=GrepOperator<cr>g@
vnoremap <space>g :<c-u>call GrepOperator(visualmode())<cr>

function! GrepOperator(type)
    if a:type ==# 'v'
        execute "normal! `<v`>y"
    elseif a:type ==# 'char'
        execute "normal! `[v`]y"
    else
        return
    endif
    silent execute "Ack! -Q " . shellescape(@@)
endfunction
