a = SharedArray(Float64,10);
function nonParallelRandom(a)
	for i=1:10
		a[i] = mean(rand(10000,10000));
	end
	return a;

end

function parallelRandom(a)
	
	@parallel for i=1:10
         a[i] = mean(rand(10000,10000))
       end

end
#to trigger compilation
parallelRandom(a);
nonParallelRandom(a);

println("En paralelo...")
@time parallelRandom(a)
print(a)
println("\nSecuencial...")
@time nonParallelRandom(a)
print(a)



