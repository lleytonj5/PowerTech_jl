import Gurobi
using Convex

function quad_form_workaround(x::Convex.AbstractExpr, A::Matrix)
	# From Convex.jl, but without the check (due to a bug)
	P = sqrt(Convex.Hermitian(A))
	return square(norm2(P * x))
end

function OID(testCase :: MPCObject, T :: Int, T0 :: Int, solar :: Matrix{Float64}, loadHH :: Matrix{Float64},
				multiPer :: Int, per :: Int, plotting :: Int, PVcap :: Matrix{Float64}, Pd12 :: Matrix{Float64})
	println("OID started.")
	_, ZBus, Ysc, Aa, Ymn, Imax, nBuses, _, nB = readLinesMPC(testCase)
	_, Vnom, Vmin, Vmax, V0, Pd, Qd, Pcap, Scap, A, B, C, D, PF = readGensMPC(testCase, nBuses)
	inverterSize = 1.1

	if multiPer == 1
		mpc = testCase
		baseMVA = mpc.baseMVA
		nPV = size(mpc.gen, 1) - 1
		idxPV = findall(b -> b == 2, mpc.bus[:,2])

		for t in T0:T
			if nPV != 0
				Pcap[idxPV .- 1] = PVcap .* solar[t] / baseMVA
				Scap[idxPV .- 1] = PVcap .* solar[t] * inverterSize / baseMVA
				Qmin = -tan(acos(PF)) * (Pcap)
			end

			Pd[idxPV .- 1] = permutedims(Pd12[t, idxPV .- 1]) / baseMVA
			Qd[idxPV .- 1] = permutedims(Pd12[t, idxPV .- 1]) * 0.7 / baseMVA

			# Variables
			V = ComplexVariable(nBuses - 1, 1)
			Pcurt = Variable(nBuses - 1, 1)
			Qc = Variable(nBuses - 1, 1)

			# Objectives
			Obj1_Vec = [real(V0); real(V); imag(V0); imag(V)]
			Obj1 = 0.5 * quad_form_workaround(Obj1_Vec, Matrix(Ymn))
			Obj2 = 0.5 * quadform(Pcurt, A) + 0.5 * quadform(Qc, C) + B' * Pcurt + D' * abs(Qc)
			Obj3 = 0

			# Constraints
			c1 = 0 <= Pcurt
			c11 = Pcurt <= Pcap
			c2 = square(Qc) <= Scap .^ 2 - square(Pcap - Pcurt)
			c3 = abs(Qc) <= tan(acos(PF)) * (Pcap - Pcurt)
			c4 = real(V) == Vnom + real(ZBus) * (Pcap - Pcurt - Pd) + imag(ZBus) * (Qc - Qd)
			c5 = imag(V) == imag(ZBus) * (Pcap - Pcurt - Pd) - real(ZBus) * (Qc - Qd)
			c6 = Vmin <= (Vnom + real(ZBus) * (Pcap - Pcurt - Pd) + imag(ZBus) * (Qc - Qd))
			c61 = (Vnom + real(ZBus) * (Pcap - Pcurt - Pd) + imag(ZBus) * (Qc - Qd)) <= Vmax
			Delta_V = Aa * [V0; V]
			c7 = -Imax <= real(Ysc .* conj(Delta_V))
			c71 = real(Ysc .* conj(Delta_V)) <= Imax

			objective = Obj1 + Obj2 + Obj3
			constraints = [c1, c11, c2, c3, c4, c5, c6, c61, c7, c71]
			problem = minimize(objective, constraints)

			solve!(problem, Gurobi.Optimizer)
			println("OID finished.")
			return # For now, we just want to see if one works
		end
	end
end