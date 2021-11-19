struct MPCObject
    baseMVA :: Int
    bus :: Matrix{Float64}
    gen :: Matrix{Float64}
    branch :: Matrix{Float64}
    bus_name :: NTuple{19, String}
    gencost :: Matrix{Float64}
    Vbase :: Float64
    Sbase :: Int
    Ibase :: Float64
end

function IEEE_18BUS_PV()
    mbase = 75
    mpc_baseMVA = mbase
    Pload = 0
    Qload = 0
    Vmin = 0.9
    Vmax = 1.05
    Vinit = 240
    
    mpc_bus = Float64[
        1	3	0       0       0	0	1	1	0	Vinit   1	1	    1
        2	2	Pload	Qload	0	0	1	1	0	Vinit	1	Vmax	Vmin
        3	1	0       0       0	0	1	1	0	Vinit	1	Vmax	Vmin
        4	2	Pload	Qload	0	0	1	1	0	Vinit	1	Vmax	Vmin
        5	2	Pload	Qload	0	0	1	1	0	Vinit	1	Vmax	Vmin
        6	1	0       0       0	0	1	1	0	Vinit	1	Vmax	Vmin
        7	2	Pload   Qload	0	0	1	1	0	Vinit	1	Vmax	Vmin
        8	2	Pload	Qload	0	0	1	1	0	Vinit	1	Vmax	Vmin
        9	1	0       0       0	0	1	1	0	Vinit	1	Vmax	Vmin
        10	2	Pload   Qload	0	0	1	1	0	Vinit	1	Vmax	Vmin
        11	2	Pload	Qload	0	0	1	1	0	Vinit	1	Vmax	Vmin
        12	1	0       0       0	0	1	1	0	Vinit	1	Vmax	Vmin
        13	2	Pload   Qload	0	0	1	1	0	Vinit	1	Vmax	Vmin
        14	2	Pload	Qload	0	0	1	1	0	Vinit	1	Vmax	Vmin
        15	1	0       0       0	0	1	1	0	Vinit	1	Vmax	Vmin
        16	2	Pload   Qload	0	0	1	1	0	Vinit	1	Vmax	Vmin
        17	2	Pload	Qload	0	0	1	1	0	Vinit	1	Vmax	Vmin
        18	1	0       0       0	0	1	1	0	Vinit	1	Vmax	Vmin
        19	2	Pload	Qload	0	0	1	1	0	Vinit	1	Vmax	Vmin
        ]
    
    PVeff = 0.8
    mpc_gen = Float64[
        1	0	0   1000	    -1000	        1	1	mbase     750          -750   0	0	0	0	0	0	0	0	0	0	0
        2	0	0	5.52*PVeff	-5.52*PVeff     1	1	mbase     5.52*PVeff	0	0	0	0	0	0	0	0	0	0	0	0
        4	0	0	5.70*PVeff	-5.70*PVeff     1	1	mbase     5.70*PVeff	0	0	0	0	0	0	0	0	0	0	0	0
        5	0	0	9.00*PVeff	-9.00*PVeff     1	1	mbase     9.00*PVeff	0	0	0	0	0	0	0	0	0	0	0	0
        7	0	0	9.00*PVeff	-9.00*PVeff     1	1	mbase     9.00*PVeff	0	0	0	0	0	0	0	0	0	0	0	0
        8	0	0	9.00*PVeff	-9.00*PVeff     1	1	mbase     9.00*PVeff	0	0	0	0	0	0	0	0	0	0	0	0
        10	0	0	5.70*PVeff	-5.70*PVeff     1	1	mbase     5.70*PVeff	0	0	0	0	0	0	0	0	0	0	0	0
        11	0	0	9.00*PVeff	-9.00*PVeff     1	1	mbase     9.00*PVeff	0	0	0	0	0	0	0	0	0	0	0	0
        13	0	0	5.70*PVeff	-5.70*PVeff     1	1	mbase     5.70*PVeff	0	0	0	0	0	0	0	0	0	0	0	0
        14	0	0	5.52*PVeff  -5.52*PVeff     1	1	mbase     5.52*PVeff	0	0	0	0	0	0	0	0	0	0	0	0
        16	0	0	5.52*PVeff	-5.52*PVeff     1	1	mbase     5.52*PVeff	0	0	0	0	0	0	0	0	0	0	0	0
        17	0	0	5.70*PVeff	-5.70*PVeff     1	1	mbase     5.70*PVeff	0	0	0	0	0	0	0	0	0	0	0	0
        19	0	0	9.00*PVeff	-9.00*PVeff     1	1	mbase    9.00*PVeff	    0	0	0	0	0	0	0	0	0	0	0	0
    ]

    dropLineL = 25
    polePoleL = 75
    f = 50
    r_dropLine = 0.549
    r_poleLine = 0.270
    r_Dline = r_dropLine/1000*dropLineL
    x_Dline = r_dropLine/1000*dropLineL/3.5
    r_Pline = r_poleLine/1000*polePoleL
    x_Pline = r_poleLine/1000*polePoleL/3.5

    Imaxp = 350
    Imaxd = 100
    mpc_branch = Float64[
        1	3	r_Pline	x_Pline     0	312.5	    0	0	0	0	1	-360	360
        3	2	r_Dline	x_Dline	    0	Imaxd	0	0	0	0	1	-360	360
        3	4	r_Dline	x_Dline     0	Imaxd	0	0	0	0	1	-360	360
        3	6	r_Pline	x_Pline 	0	Imaxp	0	0	0	0	1	-360	360
        6	5	r_Dline	x_Dline     0	Imaxd	0	0	0	0	1	-360	360
        6	7	r_Dline	x_Dline     0	Imaxd	0	0	0	0	1	-360	360
        6	9	r_Pline	x_Pline 	0	Imaxp	0	0	0	0	1	-360	360
        9	8	r_Dline	x_Dline     0	Imaxd	0	0	0	0	1	-360	360
        9	10	r_Dline	x_Dline     0	Imaxd	0	0	0	0	1	-360	360
        9	12	r_Pline	x_Pline 	0	Imaxp	0	0	0	0	1	-360	360
        12	11	r_Dline	x_Dline     0	Imaxd	0	0	0	0	1	-360	360
        12	13	r_Dline	x_Dline     0	Imaxd	0	0	0	0	1	-360	360
        12	15	r_Pline	x_Pline 	0	Imaxp	0	0	0	0	1	-360	360
        15	14	r_Dline	x_Dline     0	Imaxd	0	0	0	0	1	-360	360
        15	16	r_Dline	x_Dline     0	Imaxd	0	0	0	0	1	-360	360
        15	18	r_Pline	x_Pline 	0	Imaxp	0	0	0	0	1	-360	360
        18	17	r_Dline	x_Dline     0	Imaxd	0	0	0	0	1	-360	360
        18	19	r_Dline	x_Dline     0	Imaxd	0	0	0	0	1	-360	360
    ]

    mpc_bus_name = (
	"Grid",
	"BUS NO2",
	"POLE NO3",
	"BUS NO4",
	"BUS NO5",
	"POLE  NO6",
	"BUS NO7",
	"BUS NO8",
	"POLE  NO9",
	"BUS NO10",
    "BUS NO11",
    "POLE  NO12",
    "BUS NO13",
    "BUS NO14",
    "POLE  NO15",
    "BUS NO16",
    "BUS NO17",
    "POLE  NO18",
    "BUS NO19"
    )

    mpc_gencost = Float64[
        2	0      0	3	0    0.3	 0
        2	0      0	3	0    0	 0
        2	0      0	3	0    0	 0
        2	0      0	3	0    0	 0
        2	0      0	3	0    0	 0
        2	0      0	3	0    0	 0
        2	0      0	3	0    0	 0
        2	0      0	3	0    0	 0
        2	0      0	3	0    0	 0
        2	0      0	3	0    0	 0
        2	0      0	3	0    0	 0
        2	0      0	3	0    0	 0
        2	0      0	3	0    0	 0
    ]

    mpc_Vbase = mpc_bus[1,10]
    mpc_Sbase = mpc_baseMVA * 1000
    mpc_branch[:, [3, 4]] = mpc_branch[:, [3, 4]] / (mpc_Vbase^2 / mpc_Sbase)
    mpc_Ibase = mpc_Sbase / mpc_Vbase
    mpc_branch[:, 6] /= mpc_Ibase

    return MPCObject(mpc_baseMVA, mpc_bus, mpc_gen, mpc_branch, mpc_bus_name, mpc_gencost, mpc_Vbase, mpc_Sbase, mpc_Ibase)
end