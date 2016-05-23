addprocs(CPU_CORES);
@everywhere include("obtenComponentesDisjuntosParallel.jl");
@everywhere include("funcionesCentrosDeMasa.jl");
include("cargaYFiltra.jl");
curlab = 0