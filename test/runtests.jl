#-------------------------------------------------------------------------------------------
#=
    Purpose:    Run several tests
    Author:     Laurent Heirendt - LCSB - Luxembourg
    Date:       September 2016
=#

#-------------------------------------------------------------------------------------------

# retrieve all packages that are installed on the system
include("$(Pkg.dir("COBRA"))/src/checkSetup.jl")
packages = checkSysConfig()

# configure for runnint the tests in batch
solverName = :GLPKMathProgInterface #:CPLEX
nWorkers = 4
connectSSHWorkers = false
include("$(Pkg.dir("COBRA"))/src/connect.jl")

# create a parallel pool and determine its size
if (@isdefined nWorkers) && (@isdefined connectSSHWorkers)
    workersPool, nWorkers = createPool(nWorkers, connectSSHWorkers)
end

# use the module COBRA and Base.Test modules on all workers
using COBRA
using Test
using Requests

# download the ecoli_core_model
include("getTestModel.jl")
getTestModel()

# list all currently supported solvers
supportedSolvers = [:Clp, :GLPKMathProgInterface, :CPLEX, :Gurobi, :Mosek]

# test if an error is thrown for non-installed solvers
for i = 1:length(supportedSolvers)
    if !(supportedSolvers[i] in packages)
        @test_throws ErrorException changeCobraSolver(string(supportedSolvers[i]))
    end
end

includeCOBRA = false

for s = 1:length(packages)
    # define a solvername
    solverName = string(packages[s])

    # read out the directory with the test files
    testDir = readdir(".")

    # print the solver name
    printstyled("\n\n -- Running $(length(testDir) - 2) tests using the $solverName solver. -- \n\n", color=:green)

    # evaluate the test file
    for t = 1:length(testDir)
        # run only parallel and serial test files
        if testDir[t][1:2] == "p_" || testDir[t][1:2] == "s_" || testDir[t][1:2] == "z_"
            printstyled("\nRunning $(testDir[t]) ...\n\n", color=:green)
            include(testDir[t])
        end
    end
end

# remove the results folder to clean up
tmpDir = joinpath(dirname(@__FILE__), "..", "results")
if isdir(tmpDir)
    rm(tmpDir, recursive=true)
end

# print a status line
printstyled("\n -- All tests passed. -- \n\n", color=:green)

#-------------------------------------------------------------------------------------------
