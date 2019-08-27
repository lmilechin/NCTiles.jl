module NCTiles

using NetCDF, MeshArrays, Printf, NCDatasets

#include("utilities.jl")
#export read_nctiles

import Base: getindex

export NCvar, BinData, NCData, TileData, NewData, readbin
export createfile, addDim, addVar, addData, addDimData, calcNewFld,
        readncfile, parsemeta, readAvailDiagnosticsLog
        
include("writenctiles.jl")

end # module
