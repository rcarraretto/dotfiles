" Adapted from https://github.com/AndrewRadev/undoquit.vim
" - keeps track only of the last closed window
" - does not account for tabs

let g:undoquit_quit_win = 0

function! undoquit#SaveWindowQuitHistory() abort
  if !s:IsStorable(bufnr('%'))
    return
  endif
  let g:undoquit_quit_win = undoquit#GetWindowRestoreData()
endfunction

function! undoquit#RestoreWindow() abort
  if empty(g:undoquit_quit_win)
    echo "No closed window to undo"
    return
  endif

  let window_data = g:undoquit_quit_win
  let g:undoquit_quit_win = 0

  if window_data.neighbour_buffer != '' &&
        \ bufnr(window_data.neighbour_buffer) >= 0 &&
        \ bufwinnr(bufnr(window_data.neighbour_buffer)) >= 0
    let neighbour_window = bufwinnr(bufnr(window_data.neighbour_buffer))
    noautocmd execute neighbour_window . 'wincmd w'
  endif
  let path = escape(fnamemodify(window_data.filename, ':~:.'), ' ')
  execute window_data.open_command . ' ' . path

  call winrestview(window_data.view)
endfunction

function! undoquit#GetWindowRestoreData() abort
  let [neighbour_buffer, open_command] = s:FindNeighbourToAnchor()
  return {
        \ 'filename': expand('%:p'),
        \ 'view': winsaveview(),
        \ 'neighbour_buffer': neighbour_buffer,
        \ 'open_command': open_command,
        \ }
endfunction

function! s:FindNeighbourToAnchor() abort
  let tab_buffers = filter(copy(tabpagebuflist()), 's:IsStorable(v:val)')
  if len(tab_buffers) == 1
    " perf: no neighbours in tab
    " return early to avoid doing a window scan
    return ['', 'edit']
  endif
  let candidates = [
        \{'direction': 'j', 'open_command': 'leftabove split'},
        \{'direction': 'k', 'open_command': 'rightbelow split'},
        \{'direction': 'l', 'open_command': 'leftabove vsplit'},
        \{'direction': 'h', 'open_command': 'rightbelow vsplit'},
        \]
  for candidate in candidates
    let neighbour_buffer = s:FindNeighbourInDirection(candidate['direction'])
    if empty(neighbour_buffer)
      continue
    endif
    return [neighbour_buffer, candidate['open_command']]
  endfor
  return ['', 'edit']
endfunction

function! s:FindNeighbourInDirection(direction) abort
  let current_bufnr = bufnr('%')
  let current_winnr = winnr()
  noautocmd execute 'wincmd ' . a:direction
  let bufnr = bufnr('%')
  if bufnr == current_bufnr
    return 0
  endif
  if s:IsStorable(bufnr)
    let neighbour_buffer = expand('%')
  else
    let neighbour_buffer = 0
  endif
  noautocmd execute current_winnr . 'wincmd w'
  return neighbour_buffer
endfunction

function! s:IsStorable(bufnr) abort
  if buflisted(a:bufnr) && getbufvar(a:bufnr, '&buftype') == ''
    return 1
  else
    return getbufvar(a:bufnr, '&buftype') == 'help'
  endif
endfunction
