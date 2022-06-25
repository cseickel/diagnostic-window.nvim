if exists("b:current_syntax")
    finish
endif
echom   "Current syntax: diagmsg"
let b:current_syntax = "diagmsg"

syntax match diagMsgBorder "┏"
syntax match diagMsgBorder "┃"
syntax match diagMsgBorder "┗"
syntax match diagMsgBorder "━"
syntax match diagMsgBorder "┓"
syntax match diagMsgBorder "┛"
syntax match diagMsgHeader "Diagnostics for line \d\+ in [^\n┃]\+"
syntax match diagMsgError "ERROR\:"
syntax match diagMsgWarn "WARNING\:"
syntax match diagMsgInfo "INFO\:"
syntax match diagMsgHint "HINT\:"
syntax match diagMsgDeprecation "DEPRECATION\:"
syntax match diagSingleQuoted "'[^']\+'"
syntax region diagMsgProperties start="\:"ms=s+1 end="\." contains=diagMsgProperty,diagMsgPropertiesMore
syntax match diagMsgProperty "\v\s<[A-z0-9_]+>" contained containedin=diagMsgProperties
syntax match diagMsgPropertiesMore ", and \d\+ more" contained containedin=diagMsgProperties

highlight link diagMsgBorder markdownHeadingRule
highlight link diagMsgHeader markdownH1
highlight link diagMsgError ErrorMsg
highlight link diagMsgWarn WarningMsg
highlight link diagMsgInfo Comment
highlight link diagMsgHint Comment
highlight link diagMsgProperties Property
highlight link diagSingleQuoted Type
highlight link diagMsgProperty TSField
