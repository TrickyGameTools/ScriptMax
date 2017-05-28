


Type TFileHandler
	
	Global File:TList = New TList
	
	' Loads file into memory (each line as an element of the linked list called "File"
	Function LoadFile:TStream(path:String)
		Local fileIn:TStream = ReadFile(path)
		If Not fileIn
			Print "File " + path + " Not found!"
		Else
			While Not Eof(fileIn)
				File.AddLast(ReadLine(fileIn))
			Wend
			CloseStream(fileIn)
		End If
	End Function
	
	' FIFO
	Function GetNextLine:String()
		If Not File.IsEmpty()
			Return String(File.RemoveFirst()) 'Pop first element of linked list
		Else
			
		End If
	End Function


End Type