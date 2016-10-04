function testCores(frames, scale)
    i = 32 
    while i >= 1
    	println("Nucleos: ", i)
    	@time ObtenComponentesYEscribeP(CSD,101,101+1000)
    	i = i - 2
	end




end