import Gurobi
using JuMP
using PowerModels

# include("IEEE_18BUS_PV.jl")
# include("readMPC.jl")

function quad_form(x :: AbstractArray, P :: AbstractMatrix)
	return x' * P * x
end

function OID(testCase :: MPCObject, T :: Int, T0 :: Int, solar :: Matrix{Float64}, loadHH :: Matrix{Float64},
				multiPer :: Int, per :: Int, plotting :: Int, PVcap :: Matrix{Float64}, Pd12 :: Matrix{Float64})
	_, ZBus, Ysc, Aa, Ymn, Imax, nBuses, _, nB = readLinesMPC(testCase)
	_, Vnom, Vmin, Vmax, V0, Pd, Qd, Pcap, Scap, A, B, C, D, PF = readGensMPC(testCase, nBuses)
	inverterSize = 1.1

	local V, Pcurt, Qc, Gug_I2R

	if multiPer == 1
		mpc = testCase
		baseMVA = mpc.baseMVA
		nPV = size(mpc.gen, 1) - 1
		idxPV = findall(b -> b == 2, mpc.bus[:,2])

		# Storage variables
		Gug_V = complex(zeros(T-T0+1,size(mpc.bus,1)))
		Gug_QgTot = zeros(T-T0+1,1)
		Gug_PcTot = zeros(T-T0+1,1)
		Gug_QcTot = zeros(T-T0+1,1)
		Gug_PgTot = complex(zeros(T-T0+1,1))
		Gug_trasnf = zeros(T-T0+1,1)
		Gug_Obj = zeros(T-T0+1,3)
		Gug_PFgTot = zeros(T-T0+1,1)
		Gug_I2RTot = complex(zeros(T-T0+1,size(mpc.bus,1)-1))
		Gug_ITot = complex(zeros(T-T0+1,size(mpc.bus,1)-1))
		Gug_Vdrop = complex(zeros(T-T0+1,size(mpc.bus,1)-1))
		Gug_QcInd = zeros(T-T0+1,size(mpc.bus,1)-1)
		Gug_PcHH = zeros(T-T0+1,size(mpc.bus,1)-1)
		Gug_QminHH = zeros(T-T0+1,size(mpc.bus,1)-1)
		Gug_Preal = zeros(T-T0+1,size(mpc.bus,1)-1)
		Gug_Sreal = complex(zeros(T-T0+1,size(mpc.bus,1)-1))
		Gug_Pinj = zeros(T-T0+1,size(mpc.bus,1)-1)
		Gug_Qc = zeros(T-T0+1,size(mpc.bus,1)-1)
		Gug_check_Sreal = complex(zeros(T-T0+1,size(mpc.bus,1)-1))
		Gug_max_Pcap = zeros(T-T0+1,size(mpc.bus,1)-1)
		Gug_max_Scap = complex(zeros(T-T0+1,size(mpc.bus,1)-1))
		Gug_check_PF = zeros(T-T0+1,size(mpc.bus,1)-1)

		for t in T0:T
			if nPV != 0
				Pcap[idxPV .- 1] = PVcap .* solar[t] / baseMVA
				Scap[idxPV .- 1] = PVcap .* solar[t] * inverterSize / baseMVA
				Qmin = -tan(acos(PF)) * (Pcap)
			end
			
			Gug_QminHH[t-T0+1,:] = Qmin
			Gug_max_Scap[t-T0+1,:] = Scap
			Gug_max_Pcap[t-T0+1,:] = Pcap

			Pd[idxPV .- 1] = permutedims(Pd12[t, idxPV .- 1]) / baseMVA
			Qd[idxPV .- 1] = permutedims(Pd12[t, idxPV .- 1]) * 0.7 / baseMVA

			# Create the JuMP model
			model = JuMP.Model(Gurobi.Optimizer)

			# Variables
			@variable(model, Vreal[1:nBuses - 1]) # complex
			@variable(model, Vimag[1:nBuses - 1]) # complex
			@variable(model, Pcurt[1:nBuses - 1]) # number
			@variable(model, Qc[1:nBuses - 1]) # number

			# Objectives
			Obj1_Vec = [real(V0); Vreal; imag(V0); Vimag]
			Obj1 = 0.5 * quad_form(Obj1_Vec, Ymn)
			#Obj2 = 0.5 * quad_form(Pcurt, A) + 0.5 * quad_form(Qc, C) + B' * Pcurt + D' * abs.(Qc)
			Obj2 = 0.5 * quad_form(Pcurt, A) + 0.5 * quad_form(Qc, C) + (B' * Pcurt)[1] - (D' * Qc)[1]
			Obj3 = 0

			@objective(model, Min, Obj1 + Obj2 + Obj3)

			# Constraints
			@constraint(model, c1, 0 .<= Pcurt .<= Pcap)
			@constraint(model, c2, Qc .^ 2 .<= Scap .^ 2 - (Pcap - Pcurt) .^ 2)
			#@constraint(model, c3, abs.(Qc) <= tan(acos(PF)) * (Pcap - Pcurt))
			@constraint(model, c3, Qc .>= -tan(acos(PF)) * (Pcap - Pcurt))
			@constraint(model, c4, Vreal .== Vnom + real(ZBus) * (Pcap - Pcurt - Pd) + imag(ZBus) * (Qc - Qd))
			@constraint(model, c5, Vimag .== imag(ZBus) * (Pcap - Pcurt - Pd) - real(ZBus) * (Qc - Qd))
			@constraint(model, c6, Vmin .<= Vnom + real(ZBus) * (Pcap - Pcurt - Pd) + imag(ZBus) * (Qc - Qd))
			@constraint(model, c61, Vnom + real(ZBus) * (Pcap - Pcurt - Pd) + imag(ZBus) * (Qc - Qd) .<= Vmax)

			# Delta_Vreal = Aa * [V0; Vreal]
			# Delta_Vimag = Aa * [V0; Vimag]
			# @constraint(model, c7, -Imax <= real(Ysc .* Delta_Vreal) <= Imax)
			# @constraint(model, c71, -Imax <= real(Ysc .* -Delta_Vimag) <= Imax)
			optimize!(model)

			Obj1, Obj2, Obj3 = (value(Obj1), value(Obj2), value(Obj3))
			Vreal, Vimag, Pcurt, Qc = (value.(Vreal), value.(Vimag), value.(Pcurt), value.(Qc))
			V = complex.(Vreal, Vimag) # Combine parts back into complex numbers

			save_objVal = [Obj1 Obj2 Obj3]
			Gug_Obj[t-T0+1,:] = save_objVal
			check_transf = sum((Pcap - Pcurt - Pd).^2 + (Qc - Qd).^2)
			Gug_trasnf[t-T0+1] = check_transf
			Vfull = [V0; V]
			Gug_V[t-T0+1,:] = Vfull # voltage
			Gug_I2R, Gug_Vdrop[t-T0+1,:], Gug_ITot[t-T0+1,:] = linesLoss(mpc, Vfull, nBuses)

			# Inverter
			Gug_PcTot[t-T0+1] = sum(Pcurt) # TOTAL PV output curtailment
			Gug_QcInd[t-T0+1,:] = Qc # HH PV reactive power
			Gug_QcTot[t-T0+1] = sum(Qc) # TOTAL PV reactive power 
			Gug_PcHH[t-T0+1,:] = Pcurt # HH PV Curtailment
			Preal = Pcap - Pcurt # actual active power if injected at unit factor (not considering inverter support Q support)
			Sreal = Preal * inverterSize # actual inverter capacity in kVA (
			Pinj = sqrt.(Sreal.^2 - Qc.^2) # injected power 
			Gug_Preal[t-T0+1,:] = Preal # PV output injected in the grid
			Gug_Sreal[t-T0+1,:] = Sreal
			Gug_Pinj[t-T0+1,:] = Pinj
			Gug_Qc[t-T0+1,:] = Qc
			Gug_I2RTot[t-T0+1,:] = Gug_I2R # line loss

			# Grid
			Gug_QgTot[t-T0+1,:] .= sum(Qd) * baseMVA # Q from grid
			Gug_PgTot[t-T0+1,:] .= sum(Pd-(Pcap+Pcurt)) * baseMVA + sum(Gug_I2R) # P from grid (including line losses)
			Gug_PFgTot[t-T0+1,:] .= sum(Pd) / sqrt((sum(Pd)).^2 + (sum(Qd)).^2) # PF at the substation

			# Validate results
			Gug_check_Sreal[t-T0+1,:] = sqrt.(Qc.^2+(Pinj).^2) # FOR GRAPHS: real inverter capacity considering Pc
			Gug_check_PF[t-T0+1,:] = @. cos(atan(abs(Qc)/(Pcap-Pcurt)))

		end
	end

	return (V, Pcurt, Qc, Vmax, Gug_V, Gug_I2R, Gug_ITot, Gug_Vdrop, Gug_Preal, Gug_Sreal, Gug_PgTot, Gug_QgTot, Gug_I2RTot, Gug_PcTot, Gug_QcTot, Gug_max_Scap, Gug_max_Pcap, Gug_Pinj, Gug_check_PF, Gug_PcHH, Gug_Qc)
end