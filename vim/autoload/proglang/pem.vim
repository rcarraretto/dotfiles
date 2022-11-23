function! proglang#pem#ShowCertInfo() abort
  if expand('%:e') == 'key'
    return util#error_msg('proglang#pem#ShowCertInfo: cannot be called on private key')
  end
  " using bufnr() instead of file path allows to show cert info for a buffer
  " that is not on disk
  let output = system('openssl x509 -noout -issuer -subject -dates -nameopt multiline', bufnr())
  if v:shell_error
    return util#error_msg("proglang#pem#ShowCertInfo: openssl failed:\n" . output)
  endif
  new
  setlocal nobuflisted buftype=nofile bufhidden=wipe noswapfile
  put! =output
endfunction
