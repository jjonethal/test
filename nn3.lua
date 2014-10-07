-- nn3.lua
local exp    = math.exp
local random = math.random
BIAS = -1

-- sigmoid activation function
function sigmoid(a)
	return 1.0/(1.0 + exp(-a))
end

--- calculate neuron activation
--  @return activation value of neuron
function calcNeuron(neuron, inp)
	local a = 0
	for i=1,#neuron-1 do
		a = a + neuron[i] * inp[i]
--		print("a",a)
	end
	a = a + neuron[#neuron] * BIAS
	return sigmoid(a)
end

--- calculate neuron layer activation
--  @return neuron output
function calcLayer(layer, inp, out)
	local o=out or {}
	clear(o)
	for k,n in ipairs(layer) do
		o[k]=calcNeuron(n,inp)
	end
	return o
end


--- calculate neural net
--  @param nn the neural net to be computed
--  @param inp input vector to nn
--  @param out optional reusable output vector
--  @return the output of the neural network
function calcNN(nn, inp, out)
	local i = copy(inp,out)
	local o = {}
	for _,n in ipairs(nn) do
		o   = calcLayer(n,i,o)
		local t = i
		i = o
		o = i	
	end
	return i
end

--- clear table. set all members to nil
--  @param t table to clear
function clear(t)
	for k,_ in pairs(t) do
		t[k] = nil
	end
end

--- copy a table
--  @param t1 table to be copied
--  @param t2 optional destination table
--  @return copy of t1 / reference to t2
function copy(t1, t2)
	if t2 == t1 then
		t2 = nil
	end
	local t2 = t2 or {}
	for i,v in ipairs(t1) do
		t2[i]=v
	end
	return t2
end

--- generate neuron with numInput + 1 weigths activation threshold
-- @param numInputs number of inputs to neuron
-- return neuron with randomly distributed weights
function generateNeuron(numInputs, init, layerId, neuronId)
	local neuron = {}
	init = init or function(layerId, neuronId) return random() end
	for i = 1, numInputs + 1 do
		neuron[i] = init(layerId, neuronId)
	end
	return neuron
end

--- generate one neuron layer
-- @param numNeurons number of neurons in layer
-- @param numInputs  number of inputs/synapses to neurons
function generateLayer(numNeurons,numInputs, init, layerId)
	local layer = {}
	for i=1, numNeurons do
		layer[i]=generateNeuron(numInputs, init,layerId,i)
	end
	return layer
end

--- generate neural network
-- @param layout table containing number of inputs { input layer1 ... }
-- @return neural net with layout and randomly distributed weights
-- layout eg. { 35 35 10 } :
-- 35 inputs
-- 35 neurons on 1st layer
-- 10 neurons on last layer
function generateNet(layout, init)
	local network = {}
	for i=2,#layout do
		network[i-1]=generateLayer(layout[i],layout[i-1],init,i-1)
	end
	return network
end


function testCalcNeuron()
	local inp    = {0.1,0.1,0.1,0.1}
	local neuron = {1.0,1.0,1.0,1.0,1.0}
	print("calcNeuron",calcNeuron(neuron, inp))
end


function testSigmoid()
	for i=-10,10 do
		print(i,sigmoid(i))
	end
end

function testCalcNN()
	local inp     = { 0.1, 0.1, 0.1, 0.1}
	local neuron1 = { 1.0, 1.0, 1.0, 1.0, 1.0}
	local neuron2 = {-1.0,-1.0,-1.0,-1.0,-1.0}
	local nl1 = {neuron1,neuron2}
	local nn = {nl1}
	local o = calcNN(nn, inp, out)
	for i,v in ipairs(o) do
		print(i,v)
	end
end

function printf(fmt,...)
	io.write(string.format(fmt,...))
end

--- dump a neural net
--  @param the neural net
function dumpNN(nn)
	for l,layer in ipairs(nn) do
		printf("layer:%2d\n", l) -- print layer number
		for n,neuron in ipairs(layer) do
			printf("  n:%2d ", n)
			for _,w in ipairs(neuron) do
				printf("%7.4f ", w)
			end
			printf("\n") -- end of neuron
		end
	end
end

--- format a table with fmt and separator
--  @param t table to be formated
--  @param fmt format is string.format for each table entry
--  @param sep table separator
function tableFormat(t,fmt,sep)
	return string.format(string.rep(fmt,#t>0 and 1 or 0) .. string.rep(sep..fmt,#t-1),unpack(t))
end

--- dump a neural net to a string
--  @param the neural net
function dumpNNString(nn)
	local t={"return {"}
	for l,layer in ipairs(nn) do
		t[#t+1] = "  {" -- print layer number
		for n,neuron in ipairs(layer) do
			t[#t+1]="    { " .. tableFormat(neuron,"%.18E",", ") .. "},"
		end
		t[#t+1] = "  }," -- layer end number
	end
	t[#t+1] = "}"
	return table.concat(t,"\n")
end

function extractWeights(nn, ww)
	local ww = ww or {}
	clear(ww)
	for l,layer in ipairs(nn) do
		for n,neuron in ipairs(layer) do
			for _,w in ipairs(neuron) do
				ww[#ww+1=w]
			end
		end
	end
	return ww
end

function test_generateNet()
	local layout = {2,2,2}
	local nn = generateNet(layout,function() return 1 end)
	dumpNN(nn)
end

function compareNN(nn1, nn2)
	for l,layer in ipairs(nn1) do
		printf("layer:%2d\n", l) -- print layer number
		for n,neuron in ipairs(layer) do
			printf("  n:%2d ", n)
			for i,w in ipairs(neuron) do
				local wnn2 = nn2[l][n][i]
				local err = math.abs((wnn2-w)/wnn2)
				local ok = err < 1.0e-13
				printf("%7.4f ~ %7.4f : %s err: %E ", w, wnn2, ok, err)
				if not ok then
					return false
				end
			end
			printf("\n") -- end of neuron
		end
	end
	return true
end


function test_dumpNNStream()
	local layout = {2,2,2}
	local nn = generateNet(layout)
	local src = dumpNNString(nn)
	print(src)
	local nn2=loadstring(src)()
	local ok = compareNN(nn, nn2)
	print("result",ok)
end

-- testCalcNeuron()
testCalcNN()
test_generateNet()
test_dumpNNStream()
