" list, dict, etc.
hi link pythonBuiltinType Function
hi link pythonSelf Function
" the @ in @staticmethod
hi link pythonDecorator Function
" Exception and other classes
hi link pythonExClass Function
" try except finally
hi link pythonException Keyword
" shebang
hi link pythonCoding Comment

" don't highlight class name
hi link pythonClass Normal
" don't highlight function name
hi link pythonFunction Normal
" highlight {var} in f'hello, {var}' as blank
hi link pythonStrFormat Normal

" don't highlight %s differently in
" e.g. "Key '%s' must be an ISO date" % key
"
" Else %d, %f may show as false positives e.g. in a date formatting string
" "%Y-%m-%dT%H:%M:%S.%f%z"
hi link pythonStrFormatting String

" split pythonBuiltinObj into 2 different groups with different highlighting
syn clear pythonBuiltinObj
syn keyword pythonBuiltinObj1 True False Ellipsis None NotImplemented
syn keyword pythonBuiltinObj2 __debug__ __doc__ __file__ __name__ __package__
hi link pythonBuiltinObj1 Constant
hi link pythonBuiltinObj2 Function
