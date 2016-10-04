@time @sync @parallel for worker=1:8
	println("worker: ",worker)
	for frame=0:7
		index = 501 + 8*(worker-1) + frame 
		println("t: ",index)
		fetch(remotecall(worker,ObtenComponentesYEscribeP,CSD,index,index))
		#println("t: ",index)
	end
end


@time @fetch remotecall(1,ObtenComponentesYEscribeP,CSD,501,501)

@time ObtenComponentesYEscribeP(CSD,501,564)