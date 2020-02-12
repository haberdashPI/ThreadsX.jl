module TestWithBase

using Test
using ThreadsX

inc(x) = x + 1

raw_testdata = """
map(inc, 1:10)
map(inc, Float64[])
map(inc, ones(3, 3))
map(inc, ones(3, 0))
map(inc, ones(0, 3))
map(*, 1:10, 11:20)
map(*, ones(3, 3), ones(3, 3))
map(*, ones(3, 0), ones(3, 0))
map(*, ones(0, 3), ones(0, 3))
reduce(+, 1:10)
mapreduce(inc, +, 1:10)
mapreduce(*, +, 1:10, 11:20)
sum(1:10)
sum(x -> x^2, 1:10)
prod(1:10)
prod(x -> x + 1, 1:10)
count(isodd.(1:10))
count(isodd, 1:10)
maximum(1:10)
maximum(inc, 1:10)
minimum(1:10)
minimum(inc, 1:10)
any(fill(false, 10))
any([fill(false, 10); true])
all(fill(true, 10))
all([fill(true, 10); false])
findfirst([fill(false, 10); true])
findfirst(iseven, 1:10)
findfirst(reshape([fill(false, 10); true; true], 3, 4))
findfirst(==(5), reshape(1:12, 3, 4))
findlast([fill(true, 10); false])
findlast(isodd, 1:10)
findlast(reshape([fill(true, 10); false; false], 3, 4))
findlast(isodd, reshape(1:12, 3, 4))
findall([fill(false, 10); true])
findall(iseven, 1:10)
findall(reshape([fill(false, 10); true; true], 3, 4))
findall(==(5), reshape(1:12, 3, 4))
extrema(1:10)
extrema(sin, 1:10)
"""

# An array of `(label, (f, args))`
testdata = map(split(raw_testdata, "\n", keepempty = false)) do x
    @debug "Parsing: $x"
    m = match(r"([^(]+)\((.*),? *\)$", x)
    f = m[1]
    args = m[2]
    code = "$f, ($args,)"
    @debug "Evaling: $code"
    ex = Meta.parse(code)
    (x, @eval($ex))
end

@testset "$label" for (label, (f, args)) in testdata
    g = getproperty(ThreadsX, nameof(f))
    @testset for basesize in 1:3
        @test g(args...; basesize = basesize) == f(args...)
    end
end

end  # module
