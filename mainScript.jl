import LinearAlgebra: I, Diagonal
import SparseArrays: sparse, spdiagm, SparseMatrixCSC
import Gurobi
using PowerModels
# using JuMP

println("Imports done.")
include("IEEE_18BUS_PV.jl")
println("Include 1 done.")
include("dataInput.jl")
println("Include 2 done.")
include("makeYbus.jl")
println("Include 3 done.")
include("readMPC.jl")
println("Include 4 done.")
include("OID.jl")
println("Include 5 done.")
include("linesLoss.jl")
println("Include 6 done.")

function main()
    println("Main started.")
    multiPer = 1
    per = 13
    T = 13
    T0 = 13

    plotting = 0

    testCase = IEEE_18BUS_PV()
    solarCap = 1
    nRandCap = length(solarCap)

    PVsizeVec = ones(1, 12) * 10
    PVsysEff = 0.8
    PVcap = PVsizeVec * PVsysEff

    local V, Pcurt, Qc, Vmax, Gug_V, Gug_I2R, Gug_ITot, Gug_Vdrop, Gug_Preal, Gug_Sreal, Gug_PgTot, Gug_QgTot, Gug_I2RTot, Gug_PcTot, Gug_QcTot, Gug_max_Scap, Gug_max_Pcap, Gug_Pinj, Gug_check_PF, Gug_PcHH, Gug_Qc

    for i in 1:nRandCap
        solar, solarTotal, solarGen, loadHH, loadTotal, penetration, nBuses, Pd12, temp = dataInput(testCase, solarCap[i], PVcap, T)

        (V, Pcurt, Qc, Vmax, Gug_V, Gug_I2R, Gug_ITot, Gug_Vdrop, Gug_Preal, Gug_Sreal, Gug_PgTot, Gug_QgTot, Gug_I2RTot, Gug_PcTot, Gug_QcTot, Gug_max_Scap, Gug_max_Pcap, Gug_Pinj, Gug_check_PF, Gug_PcHH, Gug_Qc) = OID(testCase, T, T0, solar, loadHH, multiPer, per, plotting, PVcap, Pd12)
    end

    for value in (V, Pcurt, Qc, Vmax, Gug_V, Gug_I2R, Gug_ITot, Gug_Vdrop, Gug_Preal, Gug_Sreal, Gug_PgTot, Gug_QgTot, Gug_I2RTot, Gug_PcTot, Gug_QcTot, Gug_max_Scap, Gug_max_Pcap, Gug_Pinj, Gug_check_PF, Gug_PcHH, Gug_Qc)
        println(value)
    end

    return
end

println("Function defined.")
main()
# import ProfileView
# using Profile
# println("Starting.")
# @ProfileView.profview main()