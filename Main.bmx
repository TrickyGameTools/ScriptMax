SuperStrict

Include "TLexer.bmx"
Include "TParser.bmx"



Local Lexer:TLexer = New TLexer

Lexer.LexFile("testfile.txt")