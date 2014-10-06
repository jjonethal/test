-- nn3.lua
local exp=math.exp
BIAS = -1

-- sigmoid activation function
function sigmoid(a)
	return 1.0/(1.0 + exp(-a))
end

function calcNeuron(neuron, inp)
	local a = 0
	for i=1,#neuron-1 do
		a = a + neuron[i] * inp[i]
		print("a",a)
	end
	a = a + neuron[#neuron] * BIAS
	return sigmoid(a)
end

function calcLayer(layer, inp)
	local o={}
	for k,n in ipairs(layer) do
		o[k]=calcNeuron(n,inp)
	end
	return o
end

function calcNN(nn, inp)
	local o=nil
	for _,n in ipairs(nn) do
		o=calcLayer(n,inp)
		inp = o
	end
	return o
end

function copy(t1)
	local t2={}
	for i,v in ipairs(t1) do
		t2[i]=v
	end
	return t2
end

function testCalcNeuron()
	local inp    = {0.1,.1,.1,.1}
	local neuron = {1,   1,  1,  1,  1}
	print("calcNeuron",calcNeuron(neuron, inp))
end


function testSigmoid()
	for i=-10,10 do
		print(i,sigmoid(i))
	end
end

testCalcNeuron()

