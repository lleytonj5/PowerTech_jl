import LinearAlgebra: I, Diagonal
import SparseArrays: sparse, spdiagm, SparseMatrixCSC

include("datafiles/IEEE_18BUS_PV.jl")
include("dataInput.jl")
include("makeYbus.jl")
include("readMPC.jl")
include("OID.jl")
include("linesLoss.jl")

function main()
    println("Starting script.")
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
    store_Gug_Pg = complex(zeros(T-T0+1, nRandCap)) # Pg - from grid
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

        store_Gug_V18[:,i] = Gug_V[:,18] # voltage vector Bus 18
        store_Gug_V9[:,i] = Gug_V[:,9] # voltage vector Bus 9
        store_Gug_V3[:,i] = Gug_V[:,3] # voltage vector Bus 3
        store_Gug_Pc[:,i] = Gug_PcTot * testCase.baseMVA # Pc - curtailment
        store_Gug_Qc[:,i] = Gug_QcTot * testCase.baseMVA # Qc - from PV
        store_Gug_Qg[:,i] = Gug_QgTot * testCase.baseMVA # Qg - from grid
        store_Gug_Pg[:,i] = Gug_PgTot * testCase.baseMVA # Pg - from grid
        store_Gug_V[i] = Gug_V # V - voltage
        store_Gug_Preal[i] = Gug_Preal * testCase.baseMVA
        store_Gug_Sreal[i] = Gug_Sreal * testCase.baseMVA
        store_Gug_I2R[1,i] = Gug_I2RTot * testCase.baseMVA # line loss
        store_Gug_I[i] = Gug_ITot # line current
        store_Gug_Vdrop[i] = Gug_Vdrop # voltage drop
        store_Gug_Penet[i] = penetration # penetration level
        store_Gug_PVCap[i] = solarTotal # total solar PV capacity
        store_Gug_PVGen[i] = solarGen # total PV generated
        store_Gug_Scap[i] = Gug_max_Scap * testCase.baseMVA # max inverter capacity
        store_Gug_Pcap[i] = Gug_max_Pcap * testCase.baseMVA # Pav
        store_Gug_Pinj[i] = Gug_Pinj * testCase.baseMVA
        store_Gug_Qc1[i] = Gug_Qc * testCase.baseMVA
        store_Gug_PF[i] = Gug_check_PF
        store_Gug_PcHH[1,i] = Gug_PcHH * testCase.baseMVA

        if !isdir("output/")
            mkdir("output")
        end

        open("output/OID_V_1pm_no.txt", "w") do io
            for s in ("Gug_V18", store_Gug_V18, "Gug_V9", store_Gug_V9, "Gug_V3", store_Gug_V3)
                println(io, s)
            end
        end
    
        open("output/OIDf_PQ_1pm.txt", "w") do io
            for s in ("Gug_Pc", store_Gug_Pc, "Gug_Qc", store_Gug_Qc, "Gug_Pg", store_Gug_Pg, "Gug_Qg", store_Gug_Qg)
                println(io, s)
            end
        end
    
        open("output/OIDf_I2R_1pm.txt", "w") do io
            for s in ("Gug_I2R", store_Gug_I2R, "Gug_I", store_Gug_I, "Gug_Preal", store_Gug_Preal, "Gug_Sreal", store_Gug_Sreal, "Gug_V", store_Gug_V, "Gug_Vdrop", store_Gug_Vdrop, "Gug_Scap", store_Gug_Scap, "Gug_Pcap", store_Gug_Pcap, "Gug_Pinj", store_Gug_Pinj, "Gug_PF", store_Gug_PF, "Gug_PcHH", store_Gug_PcHH)
                println(io, s)
            end
        end
    
        open("output/OIDf_penet_1pm.txt", "w") do io
            for s in ("Gug_Penet", store_Gug_Penet, "Gug_PVCap", store_Gug_PVCap, "Gug_PVGen", store_Gug_PVGen)
                if (s isa String)
                    println(io, s)
                else
                    println(io, s')
                end
            end
        end
    end
end

main()