@sync @parallel for worker=1:8
	#println("worker: ",worker)
	for frame=0:3
		index = 500 + 4*(worker-1) + frame
		#println("t: ",index)
		@time fetch(remotecall(ObtenComponentesYEscribeP,worker,CSD,index,index))
		println("t: ",index)
	end

end


