#include("IEEE_18BUS_PV.jl")

function dataInput(testCase :: MPCObject, solarCap :: Int, PVcap :: Matrix{Float64}, T :: Int)
    tttt = Float64[0.256 0.537 0.874 0.455 1.914 0.345 0.787 0.701 0.65 0.323 0.471 0.446 2.689 0.269 1.07 0.038 6.031 0.304 1.932 0.222 0.275 0.057 0.288 0.69 0.082 0.138 2.429 0.235 0.832 5.854 0.694 0.2 0.069 0.286 0.338; 0.226 0.269 0.794 0.446 2.092 0.321 0.389 0.419 0.659 0.35 0.148 0.443 2.722 0.235 1.168 0.044 0.422 0.704 1.589 0.219 0.271 0.055 0.312 0.459 0.062 0.18 3.0 0.289 0.3 1.965 0.55 0.181 0.575 0.271 0.171; 0.216 0.267 0.417 0.43 1.746 0.34 0.415 0.418 0.562 0.338 0.147 0.435 2.73 0.217 1.087 0.044 0.192 0.782 1.568 0.218 0.278 0.056 0.294 0.374 0.613 0.212 2.567 1.458 0.275 0.261 0.663 0.169 0.057 0.291 0.187; 0.288 0.255 0.331 0.441 1.297 0.343 0.405 0.583 0.594 0.342 0.129 0.609 2.697 0.22 1.335 0.05 0.296 0.718 1.557 0.221 0.27 0.054 0.275 0.383 0.61 0.498 2.976 0.652 0.331 0.251 0.576 0.163 0.063 0.34 0.164; 0.218 0.242 0.265 0.48 1.321 0.324 0.56 0.75 0.655 0.345 0.123 0.487 2.783 0.269 1.322 0.044 1.515 0.297 2.043 0.218 0.27 0.054 0.332 0.446 0.663 0.436 2.748 0.937 0.225 0.23 0.663 0.169 0.062 0.327 0.151; 0.217 0.268 0.262 0.556 1.425 0.32 0.46 0.434 1.09 0.365 0.125 0.443 2.755 0.212 1.031 0.038 2.566 0.684 1.851 0.216 0.354 0.053 0.419 0.48 0.076 0.341 2.889 1.713 0.775 0.224 0.588 0.163 0.063 4.032 0.162; 0.26 1.291 0.276 0.435 1.47 0.32 0.404 1.012 4.423 0.446 0.445 0.659 1.826 0.227 1.406 0.5 2.567 0.506 1.591 0.216 0.589 0.055 0.756 1.352 0.07 0.21 3.08 1.504 0.763 0.222 0.638 0.469 2.45 4.509 0.166; 0.574 1.541 1.436 0.442 1.54 0.351 0.464 2.302 4.48 3.305 0.756 0.578 2.1 1.223 2.587 0.482 2.785 0.597 3.238 0.215 0.767 0.071 0.582 1.348 0.577 0.415 5.383 1.501 0.363 0.214 0.613 0.181 4.238 5.489 1.988; 0.985 1.362 1.207 0.7 1.568 0.355 0.542 1.559 4.165 3.055 3.264 1.591 0.533 3.296 1.261 0.45 3.128 1.726 0.912 0.214 2.751 0.117 0.932 0.716 1.056 0.326 6.908 2.379 0.276 0.365 0.588 0.65 4.55 5.404 1.308; 1.469 0.881 1.071 0.549 2.355 0.346 0.459 0.72 1.403 1.601 0.606 1.568 1.705 0.479 1.306 0.188 4.308 3.065 1.671 3.036 4.185 0.126 1.569 0.457 0.472 0.21 5.623 0.67 0.669 1.183 5.625 0.332 1.726 4.788 1.713; 1.41 0.44 0.297 0.528 2.481 0.35 0.439 4.629 1.715 0.405 0.153 1.701 1.768 0.524 1.388 0.044 4.749 2.501 1.193 8.664 1.025 0.128 1.737 0.326 0.887 0.167 4.996 0.738 2.432 1.383 6.113 1.444 1.112 2.725 2.448; 1.255 0.273 0.384 0.666 3.165 0.351 0.665 2.641 1.97 2.13 0.833 0.437 1.244 0.441 1.483 0.038 4.71 4.006 1.958 6.43 0.334 0.142 1.407 0.404 0.778 0.379 4.53 0.372 0.837 1.167 6.388 5.157 0.619 0.535 2.634; 0.607 0.507 0.409 0.546 2.036 0.347 0.605 1.359 1.768 2.026 0.131 0.412 1.824 0.317 1.225 0.044 3.208 1.012 2.884 6.98 0.757 0.128 0.207 0.457 0.303 0.228 4.623 0.235 0.913 2.018 3.638 0.7 1.488 2.234 2.298; 0.627 0.78 0.337 0.557 1.106 0.343 0.472 0.485 2.812 1.01 0.131 0.406 1.334 0.31 1.43 0.044 0.115 1.15 1.315 2.653 0.708 0.096 0.194 0.714 0.228 0.298 4.573 0.41 0.675 1.367 2.788 1.281 1.925 5.776 2.173; 1.003 0.787 0.38 0.745 0.969 0.341 0.397 0.486 2.595 0.446 0.328 0.427 1.511 0.369 1.543 0.044 0.487 0.419 1.276 2.236 1.016 0.061 0.238 0.593 0.219 0.217 4.193 0.511 1.025 0.224 2.338 0.394 0.787 1.652 2.059; 0.983 0.532 0.646 0.848 1.029 0.346 0.375 0.733 1.874 0.341 0.974 0.442 0.538 0.652 1.437 0.388 0.154 0.348 0.261 2.204 0.847 0.061 0.194 0.581 0.177 0.312 3.913 0.514 2.262 0.249 2.175 3.187 1.207 8.689 1.274; 1.576 0.501 0.701 0.749 1.497 0.387 0.399 1.63 0.96 1.456 0.472 0.438 0.651 0.504 1.438 0.306 1.783 1.106 1.885 2.527 4.434 0.426 0.563 4.003 0.585 2.409 3.948 0.476 0.912 0.213 3.776 2.9 2.113 5.34 1.846; 2.895 1.08 0.782 1.344 2.67 0.345 0.479 2.938 0.824 0.793 1.523 0.429 1.885 2.066 1.491 0.988 2.488 1.753 1.388 1.317 4.69 0.577 5.593 4.575 3.051 2.796 4.539 2.521 3.819 0.23 5.113 3.131 2.113 5.521 1.012; 3.465 1.337 1.125 1.725 2.18 0.347 1.55 1.484 1.448 0.923 2.285 0.441 2.25 2.052 1.434 0.475 1.057 5.578 2.134 0.974 3.739 0.23 6.069 3.762 3.611 2.529 3.992 2.663 1.788 0.248 5.181 2.063 1.869 7.569 0.533; 1.335 1.194 1.704 1.023 4.213 0.359 0.842 3.313 1.27 1.257 3.09 4.311 1.715 2.012 1.557 0.2 0.437 4.363 1.673 5.559 3.552 0.075 6.182 3.832 2.863 1.028 3.082 2.238 1.106 0.982 5.288 2.626 2.232 7.484 2.61; 1.64 1.204 1.129 0.826 3.518 0.356 0.878 3.692 1.098 1.308 2.011 4.786 1.226 2.022 1.426 0.119 0.41 4.23 1.666 7.287 3.374 0.062 4.456 2.846 2.234 0.17 2.622 2.798 1.757 0.715 5.401 0.837 3.607 2.346 1.287; 1.646 1.203 0.644 0.801 3.286 0.357 0.901 2.531 1.217 1.364 1.0 2.438 2.02 3.405 1.36 0.201 0.557 5.088 1.612 5.663 2.002 0.058 1.094 3.112 2.284 0.165 1.662 1.856 0.706 0.657 5.213 1.206 0.487 0.447 4.11; 1.938 1.128 1.084 0.733 3.314 0.387 0.961 1.169 1.239 3.373 1.275 0.552 2.636 0.247 1.844 0.056 0.784 5.373 1.588 3.041 0.277 0.059 0.663 1.591 0.927 0.144 1.66 1.358 0.656 1.053 5.176 1.319 0.969 0.342 1.415; 1.784 0.924 1.171 1.074 1.46 0.399 1.086 1.291 0.802 1.83 0.133 0.459 2.698 0.239 2.297 0.05 1.033 2.273 2.657 3.046 0.274 0.057 0.406 0.621 0.334 0.15 1.599 0.276 0.594 1.154 5.176 0.869 0.175 0.317 0.511]
    solarHH = Float64[0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.011560694, 0.073217726, 0.156069364, 0.217726397, 0.265895954, 0.396917148, 0.493256262, 0.63583815, 0.924855491, 0.98265896, 1.0, 0.963391137, 0.944123314, 0.809248555, 0.747591522, 0.616570328, 0.481695568, 0.385356455, 0.289017341, 0.181117534, 0.107899807, 0.08477842, 0.011560694, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
    P_pv = Float64[0.0562338843853857 0.0566802609774451 0.0559630684276767 0.0564869591485948 0.0565220136654322 0.0564284447233755 0.0565451395049937 0.0564310910121696 0.0559765565636138 0.0558358091167641 0.0565548377177538 0.0560118880033545; 0.0680656234657284 0.067803495733467 0.0684081410795382 0.0675101839740722 0.0675959189337916 0.0683973062709296 0.0679411379816244 0.0680952446478754 0.0681776975870951 0.0681756191916483 0.0679046252386223 0.0682064681921467; 0.0655990691298561 0.0652820072107512 0.0654276752384108 0.0658264093349087 0.0653266287079122 0.065650448759929 0.0650831612839336 0.0656749419986052 0.065785358866607 0.0651284474549134 0.0653641970947614 0.0659289768038988; 0.0509975694444444 0.089171875 0.0703767361111111 0.0703767361111111 0.0726715277777778 0.101995138888889 0.0726715277777778 0.133278472222222 0.101995138888889 0.133278472222222 0.0726715277777778 0.0726715277777778; 0.0725711805555556 0.0962621527777778 0.100148263888889 0.100148263888889 0.103413888888889 0.145142361111111 0.103413888888889 0.176510416666667 0.145142361111111 0.176510416666667 0.103413888888889 0.103413888888889; 0.0875413194444444 0.100215625 0.120807291666667 0.120807291666667 0.124746527777778 0.175082986111111 0.124746527777778 0.207405555555556 0.175082986111111 0.207405555555556 0.124746527777778 0.124746527777778; 0.0959739583333334 0.101794097222222 0.132444097222222 0.132444097222222 0.136762847222222 0.191947916666667 0.136762847222222 0.224856944444444 0.191947916666667 0.224856944444444 0.136762847222222 0.136762847222222; 0.0968336805555556 0.100878472222222 0.133630555555556 0.133630555555556 0.137988194444444 0.193667708333333 0.137988194444444 0.226118402777778 0.193667708333333 0.226118402777778 0.137988194444444 0.137988194444444; 0.0908958333333333 0.0986388888888889 0.125436458333333 0.125436458333333 0.129526736111111 0.181792013888889 0.129526736111111 0.213378819444444 0.181792013888889 0.213378819444444 0.129526736111111 0.129526736111111; 0.0791635416666667 0.0952909722222222 0.109245486111111 0.109245486111111 0.112807986111111 0.158327083333333 0.112807986111111 0.189001388888889 0.158327083333333 0.189001388888889 0.112807986111111 0.112807986111111; 0.0620211805555556 0.0900555555555556 0.0855895833333333 0.0855895833333333 0.0883802083333333 0.124042708333333 0.0883802083333333 0.154609375 0.124042708333333 0.154609375 0.0883802083333333 0.0883802083333333; 0.0677445737581694 0.0677135736199049 0.068244116828297 0.0678405126927168 0.0678937560375452 0.0677031524375162 0.0678976707929464 0.0683078373220165 0.0677698343809923 0.0679054799240757 0.0682897863013889 0.0681539291012497; 0.0740593462787433 0.0740903430620692 0.07422734820925 0.0742301010551193 0.0737922733661704 0.0742500061779875 0.0745919897496665 0.074104220695086 0.0737016379468032 0.0738551775272727 0.0740253997587432 0.0740120717833783; 0.077454593744366 0.0773368879693275 0.0772400876634894 0.0771612321183835 0.0773347211102336 0.0776542692350465 0.0770344611544524 0.0773765726441233 0.077019679756622 0.0773738558169786 0.077339846859927 0.0773319290837927; 0.0849231435404654 0.0849041868792489 0.0844655428714927 0.0846467513191278 0.0849213994270957 0.0846430119555281 0.0847708600704596 0.0846645254648813 0.0844567027682998 0.0843960541411235 0.084958389190472 0.0843241591601102; 0.0908290827805812 0.0910094048935305 0.0910067084339277 0.0909372263945488 0.0910046553008215 0.091273210090694 0.0907060765155249 0.0911315752719459 0.0909703793230617 0.0908248923323262 0.090975152210232 0.0908910263746199]

    nBuses = size(testCase.bus, 1) - 1
    solar = (solarHH * solarCap)[2:2:end, :]

    if nBuses < 25
        loadtable = tttt[:, [3,4,6,7,9,10,11,12,13,15,18,19,21,22,23,24,26,27]]
        loadHH = loadtable * 1.1
        loadHH[16:20, :] *= 1.4
        loadTotal = sum(loadHH, dims = 2)
    else
        loadHH = testCase.bus[:, 3]
        loadTotal = sum(loadHH, dims = 2)
    end

    idxPV = findall(b -> b == 2, testCase.bus[:, 2])
    Pd12 = zeros(T, max(nBuses - 1, maximum(idxPV) - 1)) # Adjusted this line to resolve an error in the next line
    # Matlab allows you to e.g. set index 18 in a list of 17 elements, but Julia doesn't - so we need to account for that
    Pd12[1:T, idxPV .- 1] = loadHH[1:T, idxPV .- 1]

    solarInstalled = sum(PVcap) * solarCap
    #loadP = sum(Pd12[solarInstalled .== max(solarInstalled), :]) # Not sure how this makes sense given solarInstalled is a number
    loadP = sum(Pd12[1, :])
    temp = zeros(length(solar), length(PVcap))
    for j = 1 : length(solar)
        temp[j, :] = solar[j] * PVcap;
    end
    solarGen = sum(temp[:]);
    penetration = solarInstalled / loadP;
    nBuses = size(testCase.bus, 1)

    return (solar, solarInstalled, solarGen, loadHH, loadTotal, penetration, nBuses, Pd12, temp)
end