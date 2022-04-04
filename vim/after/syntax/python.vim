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
syn clear pythonClass
" don't highlight function name
syn clear pythonFunction
" don't highlight %s in
" e.g. "Key '%s' must be an ISO date" % key
syn clear pythonStrFormatting
" highlight {var} in f'hello, {var}' as blank
hi link pythonStrFormat Operator

" split pythonBuiltinObj into 2 different groups with different highlighting
syn clear pythonBuiltinObj
syn keyword pythonBuiltinObj1 True False Ellipsis None NotImplemented
syn keyword pythonBuiltinObj2 __debug__ __doc__ __file__ __name__ __package__
hi link pythonBuiltinObj1 Constant
hi link pythonBuiltinObj2 Function
