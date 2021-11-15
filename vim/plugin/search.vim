command! ShowUniqueSearchMatches :call search#ShowUniqueSearchMatches()
command! -nargs=1 -bar -range=0 SW execute search#SubvertWrap(<line1>, <line2>, <count>, <q-args>)
