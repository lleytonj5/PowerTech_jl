function readGensMPC(testCase :: MPCObject, nBuses :: Int)
	println("Read Gens started.")
	V0 = testCase.bus[1, 8]
	Vnom = testCase.bus[2:end,8]
	Vmin = testCase.bus[2:end,13]
	Vmax = testCase.bus[2:end,12]

	nGen = size(testCase.gen, 1)
	baseMVA = testCase.baseMVA

	Pd = zeros(nBuses - 1, 1)
	Qd = zeros(nBuses - 1, 1)

	Pav = zeros(nBuses-1, 1)
	Sinj = zeros(nBuses-1, 1)

	a = 5
	b = 1
	c = 0
	d = 0

	A = Matrix(0.5 * I(nBuses - 1) * a)
	B = b * ones(nBuses - 1, 1)
	C = Matrix(0.5 * I(nBuses - 1) * c)
	D = d * ones(nBuses - 1, 1)
 
	PF = 0.80

	println("Read Gens finished.")
	return (nGen, Vnom, Vmin, Vmax, V0, Pd, Qd, Pav, Sinj, A, B, C, D, PF)
end

function readLinesMPC(testCase :: MPCObject)
	println("Read Lines started.")
	nBuses = size(testCase.bus, 1)
	nLines = size(testCase.branch, 1)
	YBusSlack = makeYbus(testCase).Ybus
	YBus = YBusSlack[2:end, 2:end]
	ZBus = sparse(inv(Matrix(YBus)))
	# We have to convert it to a matrix before taking the inverse, otherwise Julia returns the following error:
	# ERROR: LoadError: The inverse of a sparse matrix can often be dense and can cause the computer to run out of memory.
	# If you are sure you have enough memory, please convert your matrix to a dense matrix, e.g. by calling `Matrix`.

	Ymn :: SparseMatrixCSC{Float64, Int64} = 2 * [real(conj(YBusSlack)) zeros(nBuses,nBuses); zeros(nBuses,nBuses) real(conj(YBusSlack))]
	R = testCase.branch[:, 3]
	X = testCase.branch[:, 4]
	Ysc = 1 ./ (R - 1im * X)
	nB = size(YBus, 1)

	Imax = testCase.branch[:, 6]
	i2e = Int.(testCase.bus[:, 1])
	e2i = sparse(zeros(maximum(i2e), 1))
	e2i[i2e] = collect(1:size(testCase.bus, 1))
	Cf = sparse(1:nLines, e2i[Int.(testCase.branch[:,1])], testCase.branch[:,11], nLines, nBuses)
	Ct = sparse(1:nLines, e2i[Int.(testCase.branch[:,2])], testCase.branch[:,11], nLines, nBuses)
	# Matlab code for this line was Aa = spdiags(ones(nBuses,1), 0, nLines, nLines)* Cf - Ct
	Aa = spdiagm(0 => ones(nBuses))[1:nLines, 1:nLines] * Cf - Ct

	println("Read Lines finished.")
	return (YBus, ZBus, Ysc, Aa, Ymn, Imax, nBuses, nLines, nB)
end