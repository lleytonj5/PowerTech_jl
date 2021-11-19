# import SparseArrays: sparse, SparseMatrixCSC

#include("IEEE_18BUS_PV.jl")

struct YbusResult
    Ybus :: SparseMatrixCSC{ComplexF64, Int64}
    Yf :: SparseMatrixCSC{ComplexF64, Int64}
    Yt :: SparseMatrixCSC{ComplexF64, Int64}
end

function makeYbus(testCase :: MPCObject)
    baseMVA = testCase.baseMVA
    bus = testCase.bus
    branch = testCase.branch

    nb = size(bus, 1)
    nl = size(branch, 1)

    PQ, PV, REF, NONE = 1:4
    BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, VA, BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN = 1:17

    F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, RATE_C, TAP, SHIFT, BR_STATUS = 1:11
    PF, QF, PT, QT, MU_SF, MU_ST = 14:19
    ANGMIN, ANGMAX, MU_ANGMIN, MU_ANGMAX = 12, 13, 20, 21

    # skipping the error check now - consider it later

    stat = branch[:, BR_STATUS]
    Ys = stat ./ (branch[:, BR_R] + 1im * branch[:, BR_X])
    Bc = stat .* branch[:, BR_B]
    tap = ones(nl, 1)
    i = findall(x -> x != 0, branch[:, TAP])    # closest equivalent I can find to Matlab's "find" function
    tap[i] = branch[i, TAP]
    tap = tap .* exp.(1im * pi / 180 * branch[:, SHIFT])
    Ytt = Ys + 1im * Bc / 2
    Yff = Ytt ./ (tap .* conj(tap))
    Yft = - Ys ./ conj(tap)
    Ytf = - Ys ./ tap

    Ysh = (bus[:, GS] + 1im * bus[:, BS]) / baseMVA

    f = branch[:, F_BUS]
    t = branch[:, T_BUS]
    Cf = sparse(1:nl, f, ones(nl), nl, nb)
    Ct = sparse(1:nl, t, ones(nl), nl, nb)

    #i = permutedims(collect.([1:nl, 1:nl])) # not certain whether this works
    i = vec([1:nl 1:nl])
    Yf = sparse(i, [f; t], vec([Yff; Yft]), nl, nb)
    Yt = sparse(i, [f; t], vec([Ytf; Ytt]), nl, nb)

    Ybus = Cf' * Yf + Ct' * Yt + sparse(1:nb, 1:nb, Ysh, nb, nb)
    return YbusResult(Ybus, Yf, Yt)
end