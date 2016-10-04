function memoryTestRowOrder(CSD::Array)
   	for t=101:1000
	   	Pozo=Array{Int16}[]
		Fuente=Array{Int16}[]
		CuentaFuentes=zeros(64,64);
		CuentaPozos=zeros(64,64);
		#El mismo ejemplo graficado anteriormente
		for j=1:64, k=1:64
		    if(CSD[j,k,t]<-0.0)      
		        push!(Pozo, [j, k])
		        CuentaPozos[j,k]+=1
		    elseif(CSD[j,k,t]>0.0) 
		        push!(Fuente, [j, k])
		        CuentaFuentes[j,k]+=1
		    end             
		end
	end
end

function memoryTestColOrder(CSD::Array)
	for t=101:1000
	   	Pozo=Array{Int16}[]
		Fuente=Array{Int16}[]
		CuentaFuentes=zeros(64,64);
		CuentaPozos=zeros(64,64);
		#El mismo ejemplo graficado anteriormente
		for k=1:64, j=1:64
		    if(CSD[j,k,t]<-0.0)      
		        push!(Pozo, [j, k])
		        CuentaPozos[j,k]+=1
		    elseif(CSD[j,k,t]>0.0) 
		        push!(Fuente, [j, k])
		        CuentaFuentes[j,k]+=1
		    end             
		end
	end
end
