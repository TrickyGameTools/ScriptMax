

Include "TFileHandler.bmx"
Include "TToken.bmx"


' Lexer Class
Type TLexer
	
	' List that holds the generated tokens
	Field tokens:TList = New TList
	' Load the needed txt files like keywords and operators into memory (see the corresponding txt files)
	Field FileHandler:TFileHandler = New TFileHandler
	Field operators:String = LoadOperators("config/operators.txt")
	Field commentSingleLine:String = LoadSingleLineComment("config/comment.txt")
	Field commentMultiLineStart:String = LoadMultiLineCommentStart("config/comment.txt")
	Field commentMultiLineEnd:String = LoadMultiLineCommentEnd("config/comment.txt")
	Field endLine:String = LoadEndLine("config/endline.txt")
	Field keywords:String = LoadKeywords("config/keywords.txt")


	' Start lexing the file (fileIn: path to file that needs to be lexed | fileOut: not yet been used)
	Method LexFile:Int(fileIn:String, fileOut:String = "")
		' points to the current position of the line that is been processed
		Local i:Int = 1
		' currend line of the file (file is been lexed line by line)
		Local line:String
		' holds the current character that is been processed
		Local char:String
		' if the line has numbers, it will temporarily be stored here
		Local num:String
		' if the line has  identifiers, it will temporarily be stored here
		Local ident:String
		' if the line consists of comments, it will temporarily be stored here
		Local comment:String
		
		' Loasd the file that needs to be lexed (fileIn: path to file that needs to be lexed - see "Method LexFile" obove)
		' Also see TFileHandler class
		FileHandler.LoadFile(fileIn)
		
		While Not FileHandler.File.IsEmpty()
			line = FileHandler.GetNextLine()
			While i <= line.length
				char = GetChr(line, i)
				i = i + 1
				
				If isWhiteSpace(char)
					While isWhiteSpace(char)
						char = GetChr(line, i)
						If isWhiteSpace(char)
							i = i + 1
						End If
					Wend
					
				ElseIf isSingleLineComment(char)
					comment = char
					While i <= line.length
						char = GetChr(line, i)
						i = i + 1
						comment = comment + char
					Wend
					AddToken("singleLineComment:", comment )
					comment = Null
					
				ElseIf isOperator(char)
					AddToken("operator:", char)
					
				ElseIf isDigit(char)
					num = char
					While isDigit(char)
						char = GetChr(line, i)
						If isDigit(char)
							num = num + char
							i = i + 1
						End If
					Wend
					AddToken("number:", num)
					num = Null
	
				ElseIf isIdentifier(char)
					ident = char
					While isIdentifier(char)
						char = GetChr(line, i)
						If isIdentifier(char)
							ident = ident + char
							i = i + 1
						End If
					Wend
					
					If isMultiLineCommentStart(ident)
						AddToken("multiLineCommentStart:", ident)
						Repeat
							If i <= line.length
								char = GetChr(line, i)
								i = i + 1
								comment = comment + char
								If comment.contains(commentMultiLineEnd)
									comment = Replace(comment, commentMultiLineEnd, "")
									AddToken("multiLineCommentEnd:", commentMultiLineEnd)
									Exit
								End If
							Else
								AddToken("multiLineComment:", comment )
								comment = Null
								line = FileHandler.GetNextLine()
								i = 1
							End If
						Forever
						comment = Null
					
					ElseIf isKeyword(ident)
						AddToken("keyword:", ident)
					Else
						AddToken("identifier:", ident)
					End If
					ident = Null
				
				Else RuntimeError("Invalid token: " + char)
				End If
			Wend
			i = 1
			AddToken("endline:", endLine)
		Wend
		
		AddToken("(END", "END)")
		
		
		?Debug
		For Local tok:TToken = EachIn Tokens
			Print tok.typ + tok.value
		Next
		?
		Return True
	End Method
	

	
	' Appends a token to the token list
	Method AddToken(typ:String, value:String)
		Local t:TToken = New TToken
		t.typ = typ
		t.value = value
		tokens.Addlast(t)
	End Method

	' Returns one character at position "pos" (one based) from string "str"
	Method GetChr:String(str:String, pos:Int)
		Return Mid(str, pos, 1)
	End Method
	
	' -- Not used! --
	' Returns one character at position "pos" (one based) from string "str"
	' pos is called by reference
	Method GetNextChr:String(str:String, pos:Int Var)
		Local char:String
		If  pos <= str.length
			char = Mid(str, pos, 1)
			pos = pos + 1
			Return char
		Else
			Return Null
		End If
	End Method
	
	' Checks if char is an operator (see ASCII table)
	Method isOperator:Int(char:String)
		If operators.contains(char) Then Return True
		Return False
	End Method
	
	
	' Checks if char is a digit (see operators.txt)
	Method isDigit:Int(char:String)
		If Asc(char) >= 48 And Asc(char) <= 57 ' 0 - 9
			Return True
		End If
		Return False
	End Method 
	
	' Checks if char is a whitespace
	Method isWhiteSpace:Int(char:String)
		If char = " " Or char = Chr(9) ' horizantal TAB
			Return True
		End If
		Return False
	End Method
	
	' Checks if char is the single line comment character (see comment.txt)
	Method isSingleLineComment:Int(char:String)
		If char = commentSingleLine Then Return True
		Return False
	End Method
	
	
	' Checks if string is the multi line comment start string (see comment.txt)
	Method isMultiLineCommentStart:Int(str:String)
		If str = commentMultiLineStart Then Return True
		Return False
	End Method
	
	
	' Checks if string is the multi line comment end string (see comment.txt)
	Method isMultiLineCommentEnd:Int(str:String)
		If str = commentMultiLineEnd Then Return True
		Return False
	End Method
	
	' Checks if string is a keyword (see keywords.txt)
	Method isKeyword:Int(str:String)
		If keywords.contains(str) Then Return True
		Return False
	End Method
	

	
	' Checks if char is an identifier (neither an operator, nor a digit nor a whitespace)
	Method isIdentifier:Int(char:String)
		If Not isOperator(char) And Not isDigit(char) And Not isWhiteSpace(char)
			Return True
		End If
		Return False
	End Method
	
End Type



' Temp helper functions to load the needed files (might be changed later)

Function LoadOperators:String(path:String)
	Local str:String
	Local fileIn:TStream = ReadFile(path)
	If Not fileIn Then RuntimeError("Unable to load " + path)
	While Not Eof(fileIn)
		str = ReadLine(fileIn)
	Wend
	CloseStream(fileIn)
	Return str
End Function

Function LoadKeywords:String(path:String)
	Local str:String
	Local fileIn:TStream = ReadFile(path)
	If Not fileIn Then RuntimeError("Unable to load " + path)
	While Not Eof(fileIn)
		str = str + ReadLine(fileIn) + " "
	Wend
	CloseStream(fileIn)
	Return str
End Function

Function LoadSingleLineComment:String(path:String)
	Local str:String
	Local fileIn:TStream = ReadFile(path)
	If Not fileIn Then RuntimeError("Unable to load " + path)
	str = ReadLine(fileIn)
	CloseStream(fileIn)
	str = Replace(str, "single line:", "")
	Return str
End Function

Function LoadMultiLineCommentStart:String(path:String)
	Local str:String
	Local fileIn:TStream = ReadFile(path)
	If Not fileIn Then RuntimeError("Unable to load " + path)
	str = ReadLine(fileIn)
	str = ReadLine(fileIn)
	CloseStream(fileIn)
	str = Replace(str, "multi line start:", "")
	Return str
End Function

Function LoadMultiLineCommentEnd:String(path:String)
	Local str:String
	Local fileIn:TStream = ReadFile(path)
	If Not fileIn Then RuntimeError("Unable to load " + path)
	str = ReadLine(fileIn)
	str = ReadLine(fileIn)
	str = ReadLine(fileIn)
	CloseStream(fileIn)
	str = Replace(str, "multi line end:", "")
	Return str
End Function

Function LoadEndLine:String(path:String)
	Local str:String
	Local fileIn:TStream = ReadFile(path)
	If Not fileIn Then RuntimeError("Unable to load " + path)
	str = ReadLine(fileIn)
	CloseStream(fileIn)
	Return str
End Function








