#carga los Datos y filra
using PyPlot;
cd("/Users/Nes/Desktop/NeuroCiencias/JuliaExperiments/Optimizacion_Componentes_Disjuntos");
muacamuaca=open("DatosActividadEpilepticaSelectos.bin", "r");
formaarray=(64,64,9101);
Datos=read(muacamuaca, Float64, formaarray);
GaussianKernel=readdlm("GaussianMatrix.dat")
tmax=formaarray[3];
close(muacamuaca);
Datos=Datos[:,:,3500:8500];
tmax=size(Datos)[3];
formaarray=(64,64,tmax);
map!(x-> abs(x)>1750? 0: x, Datos);



#Filtra todos los datos con gausiano
LFPSuave=zeros(Datos);
for j=1:64, k=1:64
    LFPSuave[j,k,:]=GaussSuavizar(reshape(Datos[j,k,:],tmax),7)
end


LFPplanchado=zeros(formaarray)
for t=1:tmax
    LFPplanchado[:,:,t]=GaussianSmooth(LFPSuave[:,:,t])
end


CSD=zeros(formaarray)
for t=1:tmax
    CSD[:,:,t]=DiscreteLaplacian(-LFPplanchado[:,:,t])
end

CSDAplanado = CSD
CSDAplanado=map(x->abs(x)<0.99? 0:x, CSD);




