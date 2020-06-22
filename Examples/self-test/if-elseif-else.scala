object HelloWorld {
	def main () {
		var a : int = 1
		var b : float = 2.3
		val c : boolean = true
		
		// statement
		if (a < b) println ("1")
		if (a < b)
			println ("2")
		if (c) println ("3") else println ("4")
		if (c)
			println ("5")
		else
			println ("6")
		if (c) println ("7")
		else if (!c)
			println ("8")
		else println ("9")

		// block
		if (a < b) { println ("1") }
		if (a < b)
		{ println ("1") }
		if (a < b)
		{
			println ("2")
		}
		if (c) { println ("3") 
		} else { println ("4") }
		if (c)
			{ println ("5") }
		else
			{ println ("6") }
		if (c)
		{
			println ("7")
		}
		else if (!c) {
			println ("8")
		}
		else { println ("9")
		}
	}
}
