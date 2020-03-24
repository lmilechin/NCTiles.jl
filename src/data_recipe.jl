"""
DataRecipe

DataRecipe data structure. Contains info to create new field from an operation performed on
one or more fields. Binary operations must be associative. Will be applied as op(...op(op(f1,f2),f3)...,fn)

For sum:
sumData = DataRecipe("totalflds",flds,+,true,())

For mean:
DataRecipe("meanflds",sumData, x -> x ./ length(flds),false,())

More complex function:
function myfun(flds::Array,arg1,arg2,...)
...
end

DataRecipe("mynewfld",flds,myfun,false,(arg1,arg2,...))

"""
struct DataRecipe
    name::String
    precision::Type
    flds::Union{BinData,NCData,Array,DataRecipe}
    operation
    isbinaryop::Bool
    fncargs::Tuple
    readdata
    savenames::Array
end
"""
DataRecipe(name::String, flds::Union{BinData,NCData,Array,DataRecipe}, operation, isbinaryop::Bool, fncargs::Tuple)

Construct a DataRecipe with default readdata function.
"""
function DataRecipe(name::String, precision::Type, flds::Union{BinData,NCData,Array,DataRecipe}, operation, isbinaryop::Bool, fncargs::Tuple)
    return DataRecipe(name::String, precision::Type, flds::Union{BinData,NCData,Array,DataRecipe}, operation, isbinaryop::Bool, fncargs::Tuple,NCTiles.readdata,[])
end



isfiledata(x) = isa(x,BinData) || isa(x,NCData)
function calcNewFld(d::DataRecipe,tidx,returnres=true)

    typeof(d.flds)
    if isa(d.flds,DataRecipe)
        flds = calcNewFld(d.flds,tidx)
    else
        flds = d.flds
        if isa(flds,Array) && length(flds) == 1 && isfiledata(flds[1])
            flds = flds[1]
        end
    end

    if d.isbinaryop == false
        if ~isa(flds,Array)
            fldin = d.readdata(flds,tidx)
        elseif isa(flds[1],BinData)
            fldin = [BinData(fd.fnames[tidx],fd.precision,fd.iosize,fd.fldidx) for fd in d.flds]
        else # Not supporting Array of DataRecipe for non-binary ops
            fldin = flds
        end
        if isempty(d.fncargs) || ismissing(d.fncargs)
            res = d.operation(fldin,d.readdata)
        else
            args = d.fncargs
            if any(isa.(args,Ref(BinData)))
                bidx = findfirst(isa.(args,Ref(BinData)))
                argdata = readbin(args[bidx],tidx)
                args = Base.setindex(args,argdata,bidx)
            end
            res = d.operation(fldin,d.readdata,args...)
        end

    else #if binary operation
        flds = d.flds

        res = d.readdata(flds[1],tidx)

        for f = 2:length(flds)
            if isempty(d.fncargs) || ismissing(d.fncargs)
                res = d.operation(res,d.readdata(flds[f],tidx))
            else
                res = d.operation(res,d.readdata(flds[f],tidx),d.fncargs...)
            end
        end
    end

    if ~isempty(d.savenames)
        write(d.savenames[tidx],hton.(res))
    end
    if returnres
        return res
    else
        return nothing
    end
end
