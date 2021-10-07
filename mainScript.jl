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
    nRandLoc = 1

    store_Gug_V18 = complex(zeros(T-T0+1, nRandCap)) # voltage vector, house 18
    store_Gug_V9 = complex(zeros(T-T0+1, nRandCap)) # voltage vector, house 9
    store_Gug_V3 = complex(zeros(T-T0+1, nRandCap)) # voltage vector, house 3
    store_Gug_Pc = zeros(T-T0+1, nRandCap) # Pc - curtailment
    store_Gug_Qc = zeros(T-T0+1, nRandCap) # Qc - from PV
    store_Gug_Qg = zeros(T-T0+1, nRandCap) # Qg - from grid
    store_Gug_Pg = zeros(T-T0+1, nRandCap) # Pg - from grid
    store_Gug_V = Array{Any}(undef,(1, nRandCap))
    store_Gug_Preal = Array{Any}(undef,(1, nRandCap))
    store_Gug_Sreal = Array{Any}(undef,(1, nRandCap))
    store_Gug_I2R = Array{Any}(undef,(nRandLoc, nRandCap)) # line losses
    store_Gug_I = Array{Any}(undef,(1, nRandCap)) # line current
    store_Gug_Vdrop = Array{Any}(undef,(1, nRandCap)) # voltage drop
    store_Gug_Penet = zeros(nRandCap, 1) # penetration levels
    store_Gug_PVCap = zeros(nRandCap, 1) # total PV capacity
    store_Gug_PVGen = zeros(nRandCap, 1) # total PV generated
    store_Gug_Scap = Array{Any}(undef,(1, nRandCap)) # max inverter capacity
    store_Gug_Pcap = Array{Any}(undef,(1, nRandCap)) # Pav
    store_Gug_Pinj = Array{Any}(undef,(1, nRandCap)) #Sinj real
    store_Gug_Qc1 = Array{Any}(undef,(1, nRandCap)) #Sinj real
    store_Gug_PF = Array{Any}(undef,(1, nRandCap)) #Sinj real
    store_Gug_PcHH = Array{Any}(undef,(nRandLoc, nRandCap));

    PVsizeVec = ones(1, 12) * 10
    PVsysEff = 0.8
    PVcap = PVsizeVec * PVsysEff

    local V, Pcurt, Qc, Vmax, Gug_V, Gug_I2R, Gug_ITot, Gug_Vdrop, Gug_Preal, Gug_Sreal, Gug_PgTot, Gug_QgTot, Gug_I2RTot, Gug_PcTot, Gug_QcTot, Gug_max_Scap, Gug_max_Pcap, Gug_Pinj, Gug_check_PF, Gug_PcHH, Gug_Qc

    for i in 1:nRandCap
        solar, solarTotal, solarGen, loadHH, loadTotal, penetration, nBuses, Pd12, temp = dataInput(testCase, solarCap[i], PVcap, T)

        V, Pcurt, Qc, Vmax, Gug_V, Gug_I2R, Gug_ITot, Gug_Vdrop, Gug_Preal, Gug_Sreal, Gug_PgTot, Gug_QgTot, Gug_I2RTot, Gug_PcTot, Gug_QcTot, Gug_max_Scap, Gug_max_Pcap, Gug_Pinj, Gug_check_PF, Gug_PcHH, Gug_Qc = OID(testCase, T, T0, solar, loadHH, multiPer, per, plotting, PVcap, Pd12)

        # store_Gug_V18(:,i) = Gug_V(:,18); %voltage vector Bus 18
        # store_Gug_V9(:,i) = Gug_V(:,9); % voltage vector Bus 9
        # store_Gug_V3(:,i) = Gug_V(:,3); % voltage vector Bus 3
        # store_Gug_Pc(:,i) = Gug_PcTot * testCase.baseMVA; % Pc - curtailment
        # store_Gug_Qc(:,i) = Gug_QcTot * testCase.baseMVA; % Qc - from PV
        # store_Gug_Qg(:,i) = Gug_QgTot * testCase.baseMVA; % Qg - from grid
        # store_Gug_Pg(:,i) = Gug_PgTot * testCase.baseMVA; % Pg - from grid
        # store_Gug_V{i} = Gug_V; % V - voltage
        # store_Gug_Preal{i} = Gug_Preal * testCase.baseMVA;
        # store_Gug_Sreal{i} = Gug_Sreal * testCase.baseMVA;
        # store_Gug_I2R{1,i} = Gug_I2RTot * testCase.baseMVA; % line loss
        # store_Gug_I{i} = Gug_ITot; % line current
        # store_Gug_Vdrop{i} = Gug_Vdrop; % voltage drop
        # store_Gug_Penet(i) = penetration; % penetration level
        # store_Gug_PVCap(i) = solarTotal; % total solar PV capacity
        # store_Gug_PVGen(i) = solarGen; % total PV generated
        # store_Gug_Scap{i} = Gug_max_Scap * testCase.baseMVA; % max inverter capacity
        # store_Gug_Pcap{i} = Gug_max_Pcap * testCase.baseMVA; % Pav
        # store_Gug_Pinj{i} = Gug_Pinj * testCase.baseMVA;
        # store_Gug_Qc1{i} = Gug_Qc * testCase.baseMVA;
        # store_Gug_PF{i} = Gug_check_PF;
        # store_Gug_PcHH{1,i} = Gug_PcHH * testCase.baseMVA;
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