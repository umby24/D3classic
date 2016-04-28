# Generates a Headers.pbi file for Purebasic Hypercube.

files = []
functions = []

IO.foreach("Minecraft-Server.pb") {|line|
	if line[0, 12] == "XIncludeFile" # Loads a list of all includes files.
		files.push(line[line.index("\"") + 1, line.length - (line.index("\"") + 3)])
	end
}

files.each {|file| # For each include file we found
	if file == "Includes/NBT.pbi"
		next
	end
		
	puts "'#{file}'"
	
	bFile = File.new(file)
	while (line = bFile.gets)
		if line[0, 9] == "Procedure" # Search for a procedure, and push its name and arguments to our array.
			if line[9, 1] == "."
				functions.push("." + line[10, line.length - 10])
			else
				functions.push(line[10, line.length - 10])
			end
		end
	end
	bFile.close()
}

aFile = File.new("Headers.pbi", "w+") # Create our new file (Will be overwritten if it exists already)

functions.each {|func|
	if func[0, 1] != "."
		aFile.syswrite("Declare " + func + "\n")
	else
		aFile.syswrite("Declare" + func + "\n")
	end
}

aFile.close()

puts "Headers Generated."