using DiffEqBase, DiffEqJump, OrdinaryDiffEq, StochasticDiffEq, Base.Test

a = ExtendedJumpArray(rand(3),rand(2))
b = ExtendedJumpArray(rand(3),rand(2))

a.=b

rate = (t,u) -> u[1]
affect! = (integrator) -> (integrator.u[1] = integrator.u[1]/2)

jump = VariableRateJump(rate,affect!)
jump2 = deepcopy(jump)

f = function (t,u,du)
  du[1] = u[1]
end

prob = ODEProblem(f,[0.2],(0.0,10.0))
jump_prob = JumpProblem(prob,Direct(),jump,jump2)

integrator = init(jump_prob,Tsit5(),dt=1/10)

sol = solve(jump_prob,Tsit5())

@test maximum([sol[i][2] for i in 1:length(sol)]) <= 1e-14
@test maximum([sol[i][3] for i in 1:length(sol)]) <= 1e-14

g = function (t,u,du)
  du[1] = u[1]
end

prob = SDEProblem(f,g,[0.2],(0.0,10.0))
jump_prob = JumpProblem(prob,Direct(),jump,jump2)

sol = solve(jump_prob,SRIW1())

@test maximum([sol[i][2] for i in 1:length(sol)]) <= 1e-14
@test maximum([sol[i][3] for i in 1:length(sol)]) <= 1e-14
