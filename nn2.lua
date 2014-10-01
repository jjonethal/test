-- neural network implementation

local random = math.random
BIAS = -1

-- neuron with numInput weigth + 1 activation threshold
function generateNeuron(numInputs)
	local neuron = {}
	for i = 1, numInputs + 1 do
		neuron[i] = random() * 2 - 1
	end
	return neuron
end

function generateLayer(numNeurons,numInputs)
	local layer = {}
	for i=1, numNeurons do
		layer[i]=generateNeuron(numInputs)
	end
	return layer
end


--- generate neural network
-- layout -- 1 number of inputs
function generateNet(layout)
	local network = {}
	for i=2,#layout do
		network[i-1]=generateLayer(layout[i],layout[i-1])
	end
	return network
end

-- sigmoid activation mapping
function sigmoid(a)
	return 1.0/(1.0 + math.exp(-a))
end

-- calculate the activation of the neuron
function calculateActivation(input, neuron)
	local activation = 0
	for i = 1, #input do
		activation = activation + input[i]*neuron[i]
	end
	activation = activation + BIAS * neuron[#neuron]
	return sigmoid(activation)
end

function calculateLayer(input, layer)
	local output={}
	for i = 1, #layer do
		local neuron = layer[i]
		output[i] = calculateActivation(input, neuron)
	end
	return output
end

function calculateNetwork(input, network)
	print("calculateNetwork",input,network)
	for i = 1, #network do
		local layer = network[i]
		output = calculateLayer(input, layer)
		input  = output
	end
	return output
end

function dump(t)
	local ss={}
	for i,v in ipairs(t) do
		ss[i]=string.format("%7.3f", v)
	end
	print(table.concat(ss," "))
end

local nn = generateNet{64,64,10}
local input = {
	0,0,0,0,1,0,0,0,
	0,0,0,1,1,0,0,0,
	0,0,1,0,1,0,0,0,
	0,0,0,0,1,0,0,0,
	0,0,0,0,1,0,0,0,
	0,0,0,0,1,0,0,0,
	0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,
}
local o = calculateNetwork(input, nn)
dump(o)

function error(o, expectedOutput)
	local e = 0
	for i=1,#o do
		e = e + math.abs(o[i]-expectedOutput[i])
	end
	return e
end


