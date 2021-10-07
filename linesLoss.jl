function linesLoss(mpc::MPCObject, Vfull::Vector{ComplexF64}, nBuses::Int)
    
    bus = mpc.bus
    baseMVA = mpc.baseMVA
    branch = mpc.branch
    
    PQ, PV, REF, NONE = 1:4
    BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, VA, BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN = 1:17

    F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, RATE_C, TAP, SHIFT, BR_STATUS = 1:11
    PF, QF, PT, QT, MU_SF, MU_ST = 14:19
    ANGMIN, ANGMAX, MU_ANGMIN, MU_ANGMAX = 12, 13, 20, 21

    i2e = Int.(bus[:, BUS_I])
    e2i = sparse(zeros(maximum(i2e), 1))
    e2i[i2e] = (1:size(bus, 1))'
    out = findall(x -> x == 0, branch[:, BR_STATUS])
    nb = size(bus, 1)      # number of buses
    nl = size(branch, 1)   # number of branches

    # parameters
    Cf = sparse(1:nl, e2i[Int.(branch[:, F_BUS])], branch[:, BR_STATUS], nl, nb)
    Ct = sparse(1:nl, e2i[Int.(branch[:, T_BUS])], branch[:, BR_STATUS], nl, nb)
    
    #Aa = spdiags(ones(nBuses,1), 0, nl, nl)* Cf - Ct; % spdiags - extracts all non zero diagonals from a spars matrix 
    Aa = spdiagm(0 => ones(nBuses))[1:nl, 1:nl] * Cf - Ct
    Ysc = 1 ./ (branch[:, BR_R] - 1im * branch[:, BR_X]) 
    Vdrop = Aa * Vfull      # vector of voltage drop across series impedance element
    lineLoss = baseMVA * Ysc .* Vdrop .* conj(Vdrop) 
    I = Ysc .* conj(Vdrop)

    return (lineLoss, Vdrop, I)
end