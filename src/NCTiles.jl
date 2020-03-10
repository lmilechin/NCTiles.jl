module NCTiles

using NCDatasets,NetCDF,Dates,MeshArrays,Printf
#using MITgcmTools


include("write.jl")
include("read.jl")
include("tile_support.jl")
include("helper_functions.jl")
include("data_recipe.jl")

export NCvar, BinData, NCData, TileData, NewData, readbin, readncfile
export createfile, addDim, addVar, addData, addDimData, write, calcNewFld


end # module
