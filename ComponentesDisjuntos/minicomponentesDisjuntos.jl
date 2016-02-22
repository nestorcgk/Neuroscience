function miniComponentesDisjuntos(CSD::Array)
   	Pozo=Array{Int16}[]
	Fuente=Array{Int16}[]
	CuentaFuentes=zeros(64,64);
	CuentaPozos=zeros(64,64);
	#El mismo ejemplo graficado anteriormente
	for j=1:64, k=1:64
	    if(CSD[j,k,1999]<-0.0)      
	        push!(Pozo, [j, k])
	        CuentaPozos[j,k]+=1
	    elseif(CSD[j,k,1999]>0.0) 
	        push!(Fuente, [j, k])
	        CuentaFuentes[j,k]+=1
	    end             
	end
	#Simple pass method
	lista=copy(Fuente)
	curlab=0
	index = 0
	componentes=Set{Any}()
	while(length(lista)!=0)
	    x=pop!(lista) #arranca el ULTIMO elemento de la lista
	    listaprofundeza=Array{Int64}[]
	    componentecurlab=Array{Int64}[]
	    push!(listaprofundeza, x) #Pone elementos al FINAL de la lista
	    push!(componentecurlab, x)    
	    profundidad=0
	    while ((length(listaprofundeza)!=0) && profundidad<100)
	        y=pop!(listaprofundeza)
	        for v in vecindad8(y)
	        		#index = indexin({v}, lista)
	                if in(v, lista)#index != {0}
	             #   println(indexin({v},lista), v)
	                deleteat!(lista, indexin({v}, lista)) #deleteat!(lista, index)
	            #    println(v, "si estaba en la lista")
	             #   println(lista)
	                    push!(listaprofundeza, v)
	                    profundidad+=1
	                    push!(componentecurlab, v)
	                else
	                    #println(v, "no estaba en la lista")
	                end
	            end
	    end
	    # println("Para ", x, "la profundidad fue ", profundidad)
	    curlab+=1
	    push!(componentes, componentecurlab)
	end
	curlab
	#CentrosDeMasa
	centrosdemasa=[[0 0 0];]
	for p in componentes
	    masa=0.00
	    x=0.00
	    y=0.00
	    for q in p
	        j=q[1]
	        k=q[2]
	        masalocal=CSD[j,k,1999]
	        masa+=masalocal
	        x+=k*masalocal
	        y+=j*masalocal
	    end
	    x/=masa
	    y/=masa
	    A=[x y masa]
	    centrosdemasa=vcat(centrosdemasa, A)
	end
	centrosdemasa=centrosdemasa[2:end,:];
end