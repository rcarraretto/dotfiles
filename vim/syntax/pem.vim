if exists("b:current_syntax")
    finish
endif

let b:current_syntax = "pem"

syn match pemDelimiterContent "\(BEGIN\|END\) \(CERTIFICATE REQUEST\|CERTIFICATE\|PRIVATE KEY\|RSA PRIVATE KEY\|ENCRYPTED PRIVATE KEY\)" contained
syn match pemDelimiter "^-----\(BEGIN\|END\) \(CERTIFICATE REQUEST\|CERTIFICATE\|PRIVATE KEY\|RSA PRIVATE KEY\|ENCRYPTED PRIVATE KEY\)-----$" contains=pemDelimiterContent
hi def link pemDelimiterContent Function
hi def link pemDelimiter Comment
