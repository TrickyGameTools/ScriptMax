
SuperStrict




Function ReadInputFile(path:String)
	Local fileIn:TStream = ReadFile(path)
	Local readln:String
	If Not fileIn
		Print "File " + path + " Not found!"
	Else
		While Not Eof(fileIn)
			readln = ReadLine(fileIn)
			If readln <> ""
				Print readln
			End If
		Wend
		CloseStream(fileIn)
	End If

End Function





