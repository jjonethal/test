-- neural network
-- http://www.ai-junkie.com/ann/evolved/nnt6.html

local ffi    = require"ffi"
local random = math.random
-- input neuron
--[[

input gains

]]

local w,h = 16,16
math.randomseed(os.time())
local image   = ffi.new("uint8_t[?]",w * h)
local weights = ffi.new("double[?]" ,w * h)
function initImage(image,w,h)
	local y = 0
	for i = 0, h - 1 do
		for j = 0, w - 1 do
			image[y + j] = random(255)
			-- print(j, i, image[y + j])
		end
		y = y + w
	end
	print("y", y)
end

function initWeights(weights, n)
	for i = 0, n-1 do
		weights[i] = random() * 0.01 - 0.005
	end
end

-- calculate activation
function calc(weights, image, n)
	local activation = 0
	for i = 0, n - 1 do
		activation = activation + weights[i] * image[i]
	end
	local a = 1.0/(1.0 + math.exp(-activation)) 
	print("activation", a, activation) 
	return a
end

function dumpWeights(weigths,w,h)
	local l = {}
	for j = 0, h-1 do
		local c = {}
		for i = 0, w - 1 do
			c[#c + 1] = string.format("%7.4f",weigths[j * w + i])
		end
		l[#l + 1]=table.concat(c, " ")
	end
	print(table.concat(l,"\n"))
end

function genNeuron(size)
	local n = {}
	for i=1,size do
		n[i]=random()
	end 
end

neuron = {
	weights = {}
}

neuronLayer = {
	neurons = {}
}

neuralNet = {
	{}
}

function sigmoid(activation)
	local a = 1.0/(1.0 + math.exp(-activation)) 
	print("activation", a, activation) 
	return a
end
BIAS = -1

function update(input)
	local output
	for i=1,#neuralNet do -- process all layers
		local neuronLayer = neuralNet[i]
		output={}
		for j=1,#neuronLayer -- all neurons in layer
			local netInput = 0
			local weights = neuronLayer[j]
			for k=1,#weights-1 do
				netInput = netInput + weights[k]*input[k]
			end
			netInput = netInput + weights[#weights]*BIAS
			output[#output+1] = sigmoid(netInput)
		end
		input=output 
	end
	return output
end

initWeights(weights, w * h)
initImage(image, w, h)
dumpWeights(weights, w, h)
print("calc",calc(weights, image, w * h))

