-- all copyrights (c) 2014 by Jean Jonethal
-- neural network implementation
-- see http://www.ai-junkie.com/ann/evolved/nnt1.html

local random = math.random
BIAS                 = -1       -- scaling / shifting for neuron output
CROSS_OVER_RATE      = 0.7      -- genetic solver crossover rate
MUTATION_RATE        = 0.03     -- mutation rate
MUTATION_DISTURBANCE = 0.001    -- mutation disturbance
--- generate neuron with numInput + 1 weigths activation threshold
-- @param numInputs number of inputs to neuron
-- return neuron with randomly distributed weights
function generateNeuron(numInputs)
	local neuron = {}
	for i = 1, numInputs + 1 do
		neuron[i] = random()
	end
	return neuron
end

--- generate one neuron layer
-- @param numNeurons number of neurons in layer
-- @param numInputs  number of inputs/synapses to neurons
function generateLayer(numNeurons,numInputs)
	local layer = {}
	for i=1, numNeurons do
		layer[i]=generateNeuron(numInputs)
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
function generateNet(layout)
	local network = {}
	for i=2,#layout do
		network[i-1]=generateLayer(layout[i],layout[i-1])
	end
	return network
end

-- sigmoid activation function
function sigmoid(a)
	return 1.0/(1.0 + math.exp(-a))
end

--- calculate the activation of the neuron
-- @param input the input array {i1 ... iN}
-- @param neuron then neuron weights { w1 ... wN+1 } wN+1 is the activation bias of the neuron
-- @return the activation value for the neuron
function calculateActivation(input, neuron)
	local activation = 0
	for i = 1, #input do
		activation = activation + input[i]*neuron[i]
	end
	activation = activation + BIAS * neuron[#neuron]
	return sigmoid(activation)
end
--- calculate the activation values for a complete neuron layer
-- @param input the input vector of the layer
-- @param layer the table with neurons. each neuron must have 
function calculateLayer(input, layer, output)
	output = output or {}
	for i = 1, #layer do
		local neuron = layer[i]
		output[i] = calculateActivation(input, neuron)
	end
	output[#layer + 1] = nil
	return output
end

--- calculate nn answer from input
-- @param input input vector
-- @param network the neural network to calculate answer from
-- @return output vector fom neural network
function calculateNetwork(input, network)
	-- print("calculateNetwork",input,network)
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

--- extract the genom from neural net
-- @param nn the neural net to extract genom from
-- @return the genom of neural net thus all weights
function getGenom(nn)
	local gen = {}
	for k=1,#nn do
		local layer=nn[k]
		for j=1,#layer do
			local neuron = layer[j]
			for i=1,#neuron do
				gen[#gen+1] = neuron[i]
			end
		end
	end
	return gen
end

--- program genom to neural net
-- @param nn the neural net to be modified
-- @gen the weight data to be programmed into the neural net
-- @return nothing
function putGenom(nn,gen)
	local g=1
	for k=1,#nn do
		local layer=nn[k]
		for j=1,#layer do
			local neuron = layer[j]
			for i=1,#neuron do
				neuron[i] = gen[g]
			end
		end
	end
end

--- function to calculate absolute difference between two vectors
-- @param output the actual result
-- @param expectedOutput the expected result
-- @return the absolute error
function error(output, expectedOutput)
	local e = 0
	for i=1,#output do
		e = e + math.abs(output[i]-expectedOutput[i])
	end
	print("error",e)
	return e
end

--- calculate fittness of a neural net to expected output
-- the higher the value, the better the network performs
-- @param nn the network to be checked
-- @param input the inputvector to neural net
-- @param expectedOutput the expected output to be compared with output from neural net
function fitness(nn,input,expectedOutput)
	local output = calculateNetwork(input, nn)
	local e = error(output, expectedOutput)
	return 1/e
end

--- create genom set for neural net. initialize genome with random values
-- @param nn the neural network template
-- @return the genome set for neural net
function initGenoms(nn)
	local genoms={}
	local template=getGenom(nn)
	local n=#template
	for j=1,n do
		local g={}
		for i=1,n do
			g[i]=random()
		end
		genoms[j]=g
	end
	return genoms
end

--- calculate fitness for all genoms in the population
--  @param genoms the table with genoms of the population
--  @param nn the neural network template
--  @param input input to neural network
--  @param expectedOutput the 
function generationFittness(genoms,nn,input,expectedOutput,fitnessTable)
	fitnessTable = fitnessTable or {}
	local numGenoms=#genoms
	for i,gen in ipairs(genoms) do
		putGenom(nn,gen)
		fitnessTable[i]=fitness(nn,input,expectedOutput)
	end
	return fitnessTable
end


--- some statistics check for min/max
--  @param fitnessTable the table with values to be checked
--  @return max, idx of max, min, idx of min
function getBestFitness(fitnessTable)
	local min,max=fitnessTable[1],fitnessTable[1]
	local minIdx,maxIdx=1,1
	for i=1,#fitnessTable do
		local f=fitnessTable[i]
		if min > f then min = f minIdx=i end
		if max < f then max = f maxIdx=i end
	end
	return max,maxIdx,min,minIdx
end

--- summ all values together
--  @param fitnessTable
--  @return summ off all values
function summ(fitnessTable)
	local s=0
	for i=1,#fitnessTable do
		s=s+fitnessTable[i]
	end
	return s
end

--- getting index for random genom for mating probability depends on fitness
--  @param fitnessTable table containing fitness values of all genoms
--  @param sum precomputed sum of all fitness values
function grabGenomForMate(fitnessTable, sum)
	sum=sum or summ(fitnessTable)
	local rand = random()*sum
	local idx=1
	local s=0
	for i=1,#fitnessTable do
		s = s + fitnessTable[i]
		if(rand<s) then
			idx = i
			break
		end
	end
	return idx
end

--- copy vector 1 to vector 2 reusing vector 2
--  @param v1 source vector to be copied
--  @param v2 target vector to be copied over
--  @return reference to target vector 
function copyVector(v1,v2)
	v2 = v2 or {}
	for i=1,#v1 do
		v2[i] = v1[i]
	end
	v2[#v1+1]=nil
	return v2
end

--- cross over to genes depending on cross over rate
--  @param g1 first gene to be mutated
--  @param g2 second gene to be mutated
function crossover(g1,g2)
	if random()>CROSS_OVER_RATE then
		local pos = random(#g2)
		for i=pos, #g2 do
			local t = g2[i]
			g2[i] = g1[i]
			g1[i] = t
		end
	end
end

--- mutate a genom table
--  @param g the genom table to be mutated
function mutate(g)
	for i=1,#g do
		if random() < MUTATION_RATE then
			g[i] = g[i] + (random() - 0.5) * MUTATION_DISTURBANCE
		end
	end
end

--- create a next generation
--  @param genoms the genomes of the population
--  @param fitnessTable contains all fitness values of the population
--  @param newGen the table that will contain the genoms of new generation
--  @return the new table

function nextGen(genoms, fitnessTable, newGen)
	newGen       = newGen or {}
	local sum    = summ(fitnessTable)
	local nexIdx = 1
	for i = 1, math.floor(#genoms/2.0 + 0.5) do
		local maleIdx    = grabGenomForMate(fitnessTable, sum)
		local femaleIdx  = grabGenomForMate(fitnessTable, sum)
--		print("nextGen",maleIdx, femaleIdx)
		local male       = copyVector(genoms[maleIdx],  newGen[nexIdx]  )
		local female     = copyVector(genoms[femaleIdx],newGen[nexIdx+1])
		crossover(male,female)
		mutate(male)
		mutate(female)
		newGen[nexIdx]   = male
		newGen[nexIdx+1] = female
		nexIdx           = nexIdx + 2
	end
	return newGen
end

function dumpOutput(o)
	local t = {}
	for i,v in ipairs(o) do
		t[i]=string.format("v%02d %4.3f",i,v)
	end
	return(table.concat(t," "))
end

generation = 0

function printGenom(genoms)
	for i,g in ipairs(genoms) do
		io.write(string.format("\nG%03d :",i))
		for j,v in ipairs(g) do 
			io.write(string.format("%5.3f ",v))
		end
	end
	io.write("\n")
end



function evolution(trainingData, nn, genoms, newGen)
	generation = generation + 1
	local inputData      = trainingData[1]
	local expectedOutput = trainingData[2]
	local fitnessTable   = generationFittness(genoms,nn,inputData,expectedOutput)
	print("fitnessTable",table.concat(fitnessTable," "))
	local max,maxIdx,min,minIdx = getBestFitness(fitnessTable)
	putGenom(nn,genoms[maxIdx])
	local output = calculateNetwork(inputData, nn)
	print(string.format("%5d %9.3f %4d %9.3f %4d",generation, max or 0,maxIdx or 0,min or 0,minIdx or 0),dumpOutput(output))
	newGen = nextGen(genoms, fitnessTable, newGen)
	return newGen
end

function simulateNN(trainingData,layout)
	local nn = generateNet(layout)
	local inputData      = trainingData[1]
	local expectedOutput = trainingData[2]
	local genoms = initGenoms(nn)
	local newGen = nil
	while(true) do
		printGenom(genoms)
		newGen = evolution(trainingData, nn, genoms, newGen)
		local oldgen = genoms
		genoms = newGen
		newGen = oldgen
	end
end


local nn = generateNet{35,35,10}

local input_1a={
	0,0,0,0,1,
	0,0,0,1,1,
	0,0,1,0,1,
	0,0,0,0,1,
	0,0,0,0,1,
	0,0,0,0,1,
	0,0,0,0,0,
}

local input_1b={
	0,0,0,1,0,
	0,0,1,1,0,
	0,1,0,1,0,
	0,0,0,1,0,
	0,0,0,1,0,
	0,0,0,1,0,
	0,0,0,0,0,
}

local traningVector={
	{ input_1a, {0,1,0,0,0,0,0,0,0,0} },
	{ input_1b, {0,1,0,0,0,0,0,0,0,0} },
}

local inputData = input_1a


local expectedOutput = {0,1,0,0,0,0,0,0,0,0}
local o = calculateNetwork(inputData, nn)
dump(o)
print("fitness",fitness(nn,inputData,expectedOutput))
local genoms = initGenoms(nn)
print("#genoms",#genoms)
local fitnessTable = generationFittness(genoms,nn,inputData,expectedOutput,fitnessTable)
print("getBestFitness",getBestFitness(fitnessTable))
print("summ(fitnessTable)",summ(fitnessTable))

local t1={1,0}
local o1={0,1}
local layout = {2,2,2}
simulateNN({t1,o1},layout)



local layout = {35,35,10}
simulateNN(traningVector[1],layout)

local layout = {35,35,10}
simulateNN(traningVector[1],layout)