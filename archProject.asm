.data
numOfFeatures: .byte 0
numOfClasses: .byte 0
numOfSamples: .float 0.0
samplesArray: .float 0:1000  # array of 1000 element, each is a word.
testingArray: .float 0:1000 # array of 1000 element, each is a word
weightsArray: .float 0:255
numOfEpochs: .byte 0
learningRate: .float 0.0
threshold: .float 0.0  # delete this later 
thresholdsArray: .float 0:255
momentum: .float 0.0
fileName: .space 50
bufferTemp: .space 2048 # increase it 
bufferTempT: .space 2048 
newLine: .asciiz "\n"
welcomeMess: .asciiz "\t\t\t\t\t\t\t\t\t----------- Welcome in our Project ---------- \n"
fileNameMess: .asciiz "Enter the Name of the File : \n"
weightMess: .asciiz "Enter the Weight: \n"
weightInputNumMess: .asciiz "Weights for Neuron NO."
thresholdMess: .asciiz "Enter the threshold value: \n"
momentumMess: .asciiz "Enter the momentum value: \n"
rateMess: .asciiz "Enter the learning rate: \n"
epochsMess: .asciiz "Enter the number of Epochs: \n"
testingMess: .asciiz "Now we are done with training, you will enter the testing stage\n"
element1: .asciiz "\n Incrementing by 1 \n"
element2: .asciiz "\n Increamenting by 2 \n"
end: .asciiz "\n End of file reached \n"
testing: .asciiz "\n Testing \n"
#
neuronMess: .asciiz "\nWe are traning the classifier NO."
epochMess: .asciiz "\nWe are in epoch NO."
newEpochMess: .asciiz "\nWe are done with this epoch!"
line: .asciiz "\n----------------------------------------------------------------" 
errorMess: .asciiz "\nThe error in this itteration : "
updateWeightsMess: .asciiz "\nThe updated weights : "
updateThresholdMess: .asciiz "\nThe updated threshold :  "
updateLearningRateMess: .asciiz "\nThe updated learning rate : "
accuracyMess: .asciiz "\nThe accuracy of tested data : "
featureMess: .asciiz "\nThe following are the feature * the weight..\n"
temp: .asciiz "\nEcpected & True Value : "
testingSamplesMess: .asciiz "\nSample with inputs : "
testingWeightsMess: .asciiz "  Weighted sum from classifier: "
#
signFlag: .byte 0 # 0 = positive, 1 = negative
zeroAsFloat: .float 0.0
oneAsFloat: .float 1.0
minusOneAsFloat: .float -1.0 
tenAsFloat: .float 10.0
decreasePointSeven: .float 0.7
increaseOnePointZeroFive: .float 1.05
ratio: .float 1.04
previousSumOfSquareErrors: .float 0.0 
currentSumOfSquareErrors: .float 0.0 
maximumNumOfChars: .byte 50
numberOfTestingSamples: .byte 0 
weightedSumArray: .float 0:1000

#t8 is used as a counter to count the number of elements in the samplesArray
.align 2
.text
.globl main
main:	

# print the welcome string
la $a0, welcomeMess
jal printString

# promt the user to enter the file name 
la $a0, fileNameMess
jal printString

# reading the file name
jal readFileName

# read the input file
la $s7, bufferTemp
jal readFile


# printing new line
la $a0,newLine
jal printString


# read the number of features and the number of classes from the input file
jal readSamplesArray

# read the weights from the user
jal readWeights

# reading the thresolhdsArray 
jal readThresholds

# reading the learning rate
jal readLearningRate


# reading the value of the momentum 
jal readMomentum

# reading thr number of epochs
jal readNumOfEpochs

# start training 
	# $t0 : number of neurons 
	# $t1 : counter
	xor $a1, $a1, $a1
	la $t2, numOfClasses
	lb $t0, 0($t2)
loopThroughNeurons:
	beq $a1, $t0, exitLoopThroughNeurons
	#
	la $a0, neuronMess
	li $v0, 4
	syscall 
	move $a0, $a1
	li $v0, 1
	syscall 
	#
	# call 
	jal trainingProcedure
	addi $a1, $a1, 1
	j loopThroughNeurons
exitLoopThroughNeurons:

la $a0, newLine
li $v0, 4
syscall 
syscall 
la $s0, numOfClasses
xor $s1, $s1, $s1
lb $s1, 0($s0)
la $s2, thresholdsArray
xor $s3, $s3, $s3
loop22:
	#beq $s3, $s1, exitloop22
	#lwc1 $f12, 0($s2)
	#li $v0, 2
	#syscall 
	#la $a0, newLine
#li $v0, 4
#syscall
#	addi $s3, $s3, 1
#	addi $s2, $s2, 4
#	j loop22
exitloop22:

# Start testing 
#
la $a0, newLine
li $v0, 4
syscall 
la $a0, line
li $v0, 4
syscall
syscall
la $a0, newLine
li $v0, 4
syscall 
# 
# promt the user to enter the file name 
la $a0, testingMess
jal printString

# promt the user to enter the file name 
la $a0, fileNameMess
jal printString

# reading the file name
jal readFileName	

# read the input file
la $s7, bufferTempT
jal readFile

jal readTestingArray

# calling softMax procedure  

# looping through the datatest

# $a1 : counter for loopThroughNeurons loop 
# $a3 : counter for loopThroughTestSamples
# $a2 : for numberOfTestingSamples
# $t0 ; for number of classes 
# $t1 : pointer to the weightedSum array 
# $t3 : pointer for the testingArray 
# $s7 : to store the address of the current sample 
# $t7 : contains the class of each current sample
# $f27 : counter for the ture values 
# $f22 : counter for the false values   

lwc1 $f27, zeroAsFloat
lwc1 $f22, zeroAsFloat
 
la $a0, numOfFeatures 
lb $s6, 0($a0)
addi $s6, $s6, 1
sll $s6,$s6, 2

la $t3, testingArray 
move $s7, $t3
la $a1, numberOfTestingSamples
lb $a2, 0($a1)
xor $a3, $a3, $a3
loopThroughTestSamples:
	move $s7, $t3 
	beq $a3, $a2, exitLoopThroughTestSamples
	# loop through each neuron 
	xor $a1, $a1, $a1
	la $t2, numOfClasses
	lb $t0, 0($t2)
	la $t1, weightedSumArray
	
	loopThroughNeurons1:
		beq $a1, $t0, exitLoopThroughNeurons1
		move $t3, $s7 
		# calculate the weightedSum for the current sample and the current neuron
		jal calculateTheWeightedSum 
		addi $a1, $a1, 1
		j loopThroughNeurons1
	exitLoopThroughNeurons1:
	lwc1 $f31, 0($t3) 
	cvt.w.s $f0, $f31
	mfc1 $t7, $f0	
	# move t softMax function
	li $a0, 1
	beq $a0, $t0, Perceptron # in case of perceptron finding thr max is not right, we need to do an activation 
	jal softMax
	j calc
	Perceptron: 
		jal actPerceptron
	calc: 
		jal calculations
	add $t3, $t3, 4 
	addi $a3, $a3, 1
	la $a0, line
	li $v0, 4
	syscall
	j loopThroughTestSamples
exitLoopThroughTestSamples:
jal calculateAccuracy
  # looping through the neurons
   

li $v0, 10 
syscall

# ---------------------- #
# procedure to print a string
# ---------------------- #
printString: # address of the string must be put in $a0 register at the caller side
	li $v0, 4
	syscall 
	jr $ra 
# ---------------------- #

# ---------------------- # 
printInteger: 
	li $v0, 1
	syscall 
	jr $ra 
# ---------------------- #

# ---------------------- #
# reading the name of the input file 
# ---------------------- #
readFileName:
	# reading the file name
	li $v0, 8
	la $a0, fileName
	li $a1, 50
	syscall
# add a null character in the end of the file name       
    	xor $a2, $a2, $a2
    	li $a1, 50
loop:
    	lbu $a3, fileName($a2)  
    	addiu $a2, $a2, 1
    	bnez $a3, loop       # Search the NULL char code
    	beq $a1, $a2, skip   # Check whether the buffer was fully loaded
    	subiu $a2, $a2, 2    # Otherwise 'remove' the last character
    	sb $0, fileName($a2)     # and put a NULL instead
skip:
	jr $ra 
# ---------------------- #	

# ---------------------- #
# open the file with name in fileName to read and read it
# ---------------------- #	
readFile:
	li $v0, 13  #for open file
	la $a0, fileName
	li $a1, 0  #Flag=0 for read
	syscall
	#Checkign that this file exits
	blt $v0,0, wrong
	move $s0, $v0 # move the file pointer into $s0 
	#Reading the File 
	li $v0, 14  
	move $a0, $s0
	move $a1, $s7 
	la $a2, 2048 
	syscall 
	li $v0, 16  #Closing the file
	move $a0, $s0
	syscall
	jr $ra	
#Terminating, if the file does not exist.
wrong:	
	li $v0, 10 
	syscall
# ---------------------- #
						
# ---------------------- #
# reading the number of features and the number of classes from the from the input file 
# ---------------------- #
readSamplesArray:

	xor $s1,$s1,$s1  #clearing the register
	la $t0, bufferTemp
	#li $v0, 4
	#move $a0, $t0
	#syscall

#Getting the number of feature from the first line 
readNumOfFeatures: 
	lb $t1, ($t0)
	beq $t1,',', connecting
	move $a0,$t1
	andi $a0,$a0,0x0F # where $t0 contains the ascii digit .
        	#multipplying by ten using shift
        	sll  $s4, $s1, 1	 
        	sll  $s5, $s1, 3	
        	addu $s1, $s4, $s5
        	add  $s1,$s1,$a0
        	addi $t0, $t0, 1
        	j readNumOfFeatures

connecting: 	
	la $t0, numOfFeatures  #storing the first number as numOfFeatures.
	sb $s1,($t0)
	
	la $t0, bufferTemp     #t0 will hold text that will be iterated through
firstLineLoop:
    	lb $s2, 0($t0)      #Loading char to shift into $s2    
    	beq $s2, '\n' , readNumOfClassesA   #Breaking the loop if we've reached the end: 
    	# s2 contain the current character
    	
    	#move $a0,$s2
    	#li $v0, 1
    	#syscall
    	addi $t0, $t0, 1    #i++
	j firstLineLoop    #Going back to the beginning of the loop
    
    
# reading the number of calsses from the second line
readNumOfClassesA:
	xor $s1,$s1,$s1  #clearing the register
	addi $t0, $t0, 1
#Getting the number of feature from the first line 
readNumOfClasses: 
        lb $t1, ($t0)
        beq $t1,',', connecting1
        move $a0,$t1
        andi $a0,$a0,0x0F # where $t0 contains the ascii digit .
        #multipplying by ten using shift
        sll  $s4, $s1, 1	 
        sll  $s5, $s1, 3	
        addu $s1, $s4, $s5
        add  $s1,$s1,$a0
        addi $t0, $t0, 1
        j readNumOfClasses

connecting1: 	
	la $t1, numOfClasses  #storing the first number as numOfFeatures.
	# number of classes represents the number of needed neurons, so if numberOfClasses=2 need one neuron
	xor $t9, $t9, $t9
	addi $t9, $t9, 2
	bne $s1, $t9, storingNumOfClasses
	addi $s1, $s1, -1
storingNumOfClasses:	
	sb $s1,($t1)
	#la $a0, newLine
	#li $v0, 4
	#syscall
	lb $s1, ($t1)
	
	#move $a0,$s1
	#li $v0, 1
	#syscall
	
	#la $a0, newLine
	#li $v0, 4
	#syscall

secondLineLoop:
    	lb $s2, 0($t0)      #Loading char to shift into $s2    
    	beq $s2, '\n' , finishProcedure   #Breaking the loop if we've reached the end: 
    	# s2 contain the current character
    	#move $a0,$s2
    	#li $v0, 1
   	#syscall
    	addi $t0, $t0, 1    #i++
	j secondLineLoop    #Going back to the beginning of the loop
finishProcedure:   
 	#li $v0, 5
 	#syscall 
    	#la $a0, welcomeMess
    	#li $v0, 4
	#syscall
fillingArrayLoopA:

      #temp 
      xor $t7, $t7, $t7
      #
      addi $t0,$t0,1    #moving byte by byte from the read string
      lwc1 $f0, zeroAsFloat  #Setting them for future use
      lwc1 $f10, tenAsFloat  #Setting them for future use
      lwc1 $f11, tenAsFloat
      move $t8, $zero # counter for the samplesarray 
      # newLine
      #la $a0,newLine
      #li $v0,4
      #syscall
      #
      la $a1, samplesArray   #the base address of array 
      
      j fillingArrayLoop

#register $f1, $f2 will be used in reading the numbers 
#$a1 is the base for samplesArray 

fillingArrayLoop: 
      lb $s2,0($t0)
      beq  $s2,'\0' endOfFile # reach end of file need to exit the procedure 
      beq  $s2,',', newElement1 # anther element at the same line 
      beq  $s2,13, newElement2 # another element at the next line 
      beq  $s2,'.', division  # reading the fraction part 
      beq $s2, '-', updateFlag # reading negative number
      andi $s2,$s2,0x0F # where $t0 contains the ascii digit.
      #tryng to convert 
      mtc1 $s2, $f2
      cvt.s.w $f2, $f2
      #multipplying by ten
      mul.s $f1,$f1,$f10	
      add.s $f1,$f1,$f2
      add $t0, $t0,1
      j fillingArrayLoop
updateFlag: 
	li $t4, 1
	la $t5, signFlag
	sb $t4, 0($t5)
	addi $t0, $t0, 1
	#lwc1 $f1, zeroAsFloat   #clearing the register
	#lwc1 $f11, tenAsFloat
	j fillingArrayLoop     
division: # same logic as above
	add $t0, $t0,1
	lb $s2,0($t0)
        beq  $s2,'\0' endOfFile
        beq  $s2,',', newElement1
        beq  $s2,13, newElement2
	andi $s2,$s2,0x0F # where $t0 contains the ascii digit .
        #tryng to convert 
        mtc1 $s2, $f2
        cvt.s.w $f2, $f2
        div.s $f2, $f2, $f11
        add.s $f1, $f1, $f2
	mul.s $f11,$f11,$f10  #first time divide by 10 , 100 , 1000
        j division         
      
      
endOfFile:
        #printing what we have read
	#la $a0, end
	#li $v0, 4
	#syscall
	j exitA
      
newElement1: 
       
	#printing what we have read
 	# checking signFlag 
 	la $t5, signFlag
 	lb $t4, 0($t5)
 	beq $t4, 0, storeElement1   
 	# mul by -1 
 	lwc1 $f12, minusOneAsFloat
 	mul.s $f1, $f1, $f12
 	lwc1 $f12, zeroAsFloat
	# storing
	storeElement1:
	add.s $f12, $f1,$f0
	swc1 $f12, 0($a1) 
	addi $a1, $a1, 4 
	#
	addi $t8,$t8,1
	addi $t0, $t0, 1
	lwc1 $f1, zeroAsFloat   #clearing the register
	lwc1 $f11, tenAsFloat
	li $t4, 0
	la $t5, signFlag
	sb $t4, 0($t5)
	j fillingArrayLoop
	 
      
newElement2: 
	
	#printing what we have read
 	# checking signFlag 
 	la $t5, signFlag
 	lb $t4, 0($t5)
 	beq $t4, 0, storeElement2   
 	# mul by -1 
 	lwc1 $f12, minusOneAsFloat
 	mul.s $f1, $f1, $f12
 	lwc1 $f12, zeroAsFloat
	# storing
	storeElement2:     
	# storing
	add.s $f12, $f1,$f0
	swc1 $f12, 0($a1) 
	addi $a1, $a1, 4 
	#
	addi $t8,$t8,1
	addi $t0, $t0, 2
	lwc1 $f1, zeroAsFloat    #clearing the register
	lwc1 $f11, tenAsFloat
	addi $t7, $t7, 1
	li $t4, 0
	la $t5, signFlag
	sb $t4, 0($t5)
	j fillingArrayLoop            
                  
                
exitA: 
	la $a1, samplesArray
	#move $a0,$t8
	#li $v0, 1
	#syscall 
	la $a3, numOfSamples
	#add.s $f12, $f1,$f0
	mtc1 $t7, $f2
     	cvt.s.w $f2, $f2
	swc1 $f2, 0($a3)
	j exit
	
printingSamples:
    	beq $t6, $t8, exit	
	lwc1 $f12, ($a1)
	li $v0, 2
	syscall
	la $a0, newLine
	li $v0, 4
	syscall 

	addi $a1, $a1, 4
	addi $t6, $t6, 1
	j printingSamples
	
exit:
 	jr $ra	
# ---------------------- #

# ---------------------- #
# reading weights 
# ---------------------- #
readWeights:
	#reading weights
	la $t0, numOfFeatures
	la $t1, numOfClasses 
	lb $s0, ($t0)   #number of features stored here
	lb $s5, ($t1)   #number of classes stoed here
	xor $s1, $s1, $s1  #acts as a counter for the first loop, need to clear it
	xor $s3, $s3, $s3 
	addi $s3, $s3, 2  
	la $t0, weightsArray
	la $a1, weightsArray
	la $a0, weightMess
	xor $t6,$t6,$t6 
		
						
loopingThroughNeurons:
	beq $s1, $s5, exit2 # check if outer loop counter == number of neurons 
	addi $s1,$s1,1
	xor $s2, $s2, $s2  #acts as a counter for the second loop, need to clear it. 
	#########beq $s3, $s5, readingOneWeight
	# special message 
	la $a0, weightInputNumMess # change the name and the message 
	li $v0, 4
	syscall
	li $v0, 1
	move $a0, $s1
	syscall 
	la $a0, newLine 
	li $v0, 4
	syscall 
	la $a0, weightMess
	
	j readingWeightsForCurrentNeuronLoop
readingWeightsForCurrentNeuronLoop:
	beq $s0, $s2, loopingThroughNeurons # ending of the inner loop-> go back to the outer loop
	li $v0, 4
	syscall
	li $v0, 6
	syscall 
	swc1 $f0, ($t0)
	addi $s2,$s2,1
	addi $t0, $t0, 4
	j readingWeightsForCurrentNeuronLoop
exit2:
    	#beq $t6, $s0, e	
	#lwc1 $f12, ($a1)
	#li $v0, 2
	#syscall
	#la $a0, newLine
	#li $v0, 4
	#syscall

	#addi $a1, $a1, 4
	#addi $t6, $t6, 1
	#j exit2	
e:
	jr $ra
# ---------------------- #

# ---------------------- #
# reading thresholds
# ---------------------- #
readThresholds:
	la $t0, numOfClasses
	lb $s0, ($t0)   #number of classe stored here
	xor $s1,$s1,$s1  #acts as a counter, need to clear it
	#xor $s2, $s2, $s2 
	#addi $s2, $s2, 2
	la $t0, thresholdsArray
	la $a0, thresholdMess
	la $a1, thresholdsArray
	xor $t6,$t6,$t6 

readingThresholdsLoop: 
	beq $s1,$s0,exit3 
	li $v0, 4
	syscall 
	li $v0, 6
	syscall 
	swc1 $f0, ($t0)
	addi $s1,$s1,1
	addi $t0, $t0, 4
	j readingThresholdsLoop	
	
exit3:
    	#beq $t6, $s0, e1	
	#lwc1 $f12, ($a1)
	#li $v0, 2
	#syscall
	#la $a0, newLine
	#li $v0, 4
	#syscall

	#addi $a1, $a1, 4
	#addi $t6, $t6, 1
	#j exit3
e1:
	jr $ra
# ---------------------- #

# ---------------------- #
# reading learning rate 
# ---------------------- #
readLearningRate:
	la $a0,rateMess
	li $v0, 4
	syscall 
	li $v0, 6
	syscall
	la $t9, learningRate
	swc1 $f0, ($t9)
	#lwc1 $f12, 0($t9)
	#li $v0,2
	#syscall
	jr $ra 
# ---------------------- #

# ---------------------- #
# reading momentum 
# ---------------------- #
readMomentum:
	la $a0,momentumMess
	li $v0, 4
	syscall
	li $v0, 6
	syscall
	la $t9, momentum
	swc1 $f0, 0($t9)
	#lwc1 $f12, 0($t9)
	#li $v0,2
	#syscall
	jr $ra
# ---------------------- #

# ---------------------- #
# reading number of epochs 
# ---------------------- #
readNumOfEpochs:
	la $a0,epochsMess
	li $v0, 4
	syscall
	li $v0, 5
	syscall
	la $t9, numOfEpochs
	sb $v0, ($t9)
	# --------------------------
	#li $v0, 1
	#la $a1, numOfEpochs
	#lb $a0,($a1)
	#syscall
	jr $ra
# ---------------------- #

# ---------------------- #
# 
# ---------------------- #
NeuronProcedure:

	jr $ra
# ---------------------- #

# ---------------------- #
# binary classifier "ONE V. ALL"
# ---------------------- #
trainingProcedure:
	# $a1, $0, $t2 can't be used here  
	# a1 is the current number of neuron 
	# $s0 : shift amount for weight 
	# $s1 : shift amount for threshold
	# $s2 : number of epochs
	# $s3 : number of features 
	# $f3: number of samples 
	# $f1 : counter for the samples "inner loop"
	# $s4 : counter for the epochs "outer loop"
	# $s5 : counter for the features "inner inner loop" 
	# $f2 : oneAsFloat
	# $f4 : weightedSum 
	# $t4 : address of weightsArray 
	# $t5 : address of thresholdsArray 
	# $t6 : address of the samples array 
	# $f5 : get expected class of sample
	# $f6 : get true class of sample 
	# $f7 : the current threshold 
	# $f13 and $f14 : get the feature and the weight 
	# $f25: sumOfSquareErrors 
	# $f26: previousSumOfSquareErrors 
	# $f24: error*error 
	
	move $s0, $a1         #$s0 has the current neuron number
	la $s2, numOfFeatures
	xor $s3, $s3, $s3
	lb $s3, ($s2)         
	multu $s0, $s3 
	mflo $s0 # $s0 shift amount to the weight for the current neuron
	sll $s0, $s0, 2
	move $s1, $a1 # $s1 shift amount to the threshold of the current neuron 
	sll $s1, $s1, 2
	
	la $t1, numOfEpochs
	xor $s2, $s2, $s2
	lb $s2, 0($t1)
	
	la $a3, numOfSamples
	lwc1 $f3, 0($a3)
	lwc1 $f12, zeroAsFloat    #clearing the register
	lwc1 $f0, zeroAsFloat    #clearing the register
	#add.s $f12, $f3, $f0 
	xor $s4, $s4, $s4
	xor $s5, $s5, $s5
	lwc1 $f1, zeroAsFloat    #clearing the register
	lwc1 $f12, zeroAsFloat    #clearing the register
	#add.s $f12, $f1, $f0
	lwc1 $f2, oneAsFloat  #Setting them for future use

         la $t4, weightsArray
       
         add $t4, $t4, $s0 
         la $t5, thresholdsArray 
         add $t5, $t5, $s1
         la $t6, samplesArray
epochs:  
	beq $s2, $s4, exitTraining	# if $s4==num of epochs "$s2" well done 
	#
	la $a0, epochMess
	li $v0, 4
	syscall 
	move $a0, $s4
	li $v0, 1
	syscall 
	#
	addi $s4, $s4, 1
	lwc1 $f1, zeroAsFloat    #clearing the register
	la $t4, weightsArray 
         add $t4, $t4, $s0 # reset the pointer to the needed weight 
         la $t6, samplesArray 
samples: 
	lwc1 $f4, zeroAsFloat    #clearing the weighted sum register
	la $t4, weightsArray 
         add $t4, $t4, $s0 # needs to get the weights again 
	xor $s5, $s5, $s5	  
	c.eq.s $f1, $f3 # if $f1==num of samples "$f3" start new epoch
	bc1t epochA
	add.s $f1, $f1, $f2   #$f1=$f1+1
	
	la $a0, featureMess
	li $v0, 4
	syscall 
	
newSample: 
	lwc1 $f13, 0($t6) # get the feature in f13
	lwc1 $f14, 0($t4) # get the weight in f14 
	beq $s5,$s3, getClass # if $s5==num of features "$s3" we will read the class of this sample
	mul.s $f13, $f13, $f14
	add.s $f4, $f4, $f13 # add W*F into the weighted sum 
	lwc1 $f12, 0($t6)
	li $v0, 2
	syscall 
	# printing the * 
	li $a0,'*'
	li $v0,11
	syscall
	# print the weight
	lwc1 $f12, 0($t4)
	li $v0, 2
	syscall
	# printing the ' ' 
	li $a0,' '
	li $v0,11
	syscall
	# printing the | 
	li $a0,'|'
	li $v0,11
	syscall 
	# printing the ' ' 
	li $a0,' '
	li $v0,11
	syscall
	addi $t4, $t4, 4
	addi $t6, $t6, 4
	addi $s5, $s5, 1
         j newSample 

getClass: # call update weights, thresholds.  
	lwc1 $f5, 0($t6) # expected current sample class is in $f5
	lwc1 $f7, 0($t5) # get the threshold in $f7 
	######################
	# printing the 
	#li $a0,'B'
	#li $v0,11
	#syscall 
         lwc1 $f12, zeroAsFloat
         add.s $f12, $f12, $f4
         #li $v0, 2
         #syscall 
         #####################
        sub.s $f4, $f4, $f7 # weighted sum - threshold 
        ######################
        # printing the  
	#li $a0,'A'
	#li $v0,11
	#syscall 
         lwc1 $f12, zeroAsFloat
         add.s $f12, $f12, $f4
         #li $v0, 2
         #syscall 
         #####################
	# call activation function 
	# calculate the error
	# update the weight and the threshold 
	addi $sp, $sp, -8 
	# needed to call another procedure 
	sw $s6, 0($sp)
	sw $ra, 4($sp)
	jal activationProcedure
	lw $s6, 0($sp)
	lw $ra, 4($sp)
	
	addi $sp, $sp, -8 
	# needed to call another procedure 
	sw $s6, 0($sp)
	sw $ra, 4($sp)
	jal updateWeightsAndThreshold
	lw $s6, 0($sp)
	lw $ra, 4($sp)
	
	la $a0, newLine
	li $v0, 4
	syscall 
	addi $t6, $t6, 4
	j samples 

epochA:
	addi $sp, $sp, -8 
	# needed to call another procedure 
	sw $s6, 0($sp)
	sw $ra, 4($sp)
	jal updateLearningRate
	lw $s6, 0($sp)
	lw $ra, 4($sp)
	j epochs 		                  		                  
exitTraining: 	
	                        
	jr $ra
# ---------------------- #

# ---------------------- #
# activation function "unit step"
# ---------------------- #
activationProcedure:
	# make a decision about the output 
	# f4 weightedsum, and the thresold for the comparsion is 0
	# $f5 : expected, $f6 : ture value 
	lwc1 $f0, zeroAsFloat
	c.le.s $f4, $f0
	bc1t zeroValue
	lwc1 $f6, oneAsFloat
	j makeDecision
zeroValue:
	lwc1 $f6, zeroAsFloat 
makeDecision:
	#tryng to convert 
      	cvt.w.s $f0, $f5
	mfc1 $t7, $f0
	beq $a1, $t7, MakeDecision1
	lwc1 $f5, zeroAsFloat
	j calcError
	
MakeDecision1:
	lwc1 $f5, oneAsFloat
calcError: 	
	la $a0, temp 
	li $v0, 4
	syscall 
	lwc1 $f12, zeroAsFloat
	add.s $f12, $f12, $f5
	li $v0, 2
	syscall 
	li $a0, ' '
	li $v0, 11
	syscall 
	lwc1 $f12, zeroAsFloat
	add.s $f12, $f12, $f6
	li $v0, 2
	syscall 
	jr $ra
# ---------------------- #

# ---------------------- #
# update weights and threshold procedure
# ---------------------- #
updateWeightsAndThreshold:
	# threshold, previousweights, error, momentum  
	# $f7 : the current threshold
	# $f8 : previous weight "to be edit" 
	# $f9 : the error
	# $f10: momentum
	# $f11: the current feature
	# $s3 : number of features
	# $t9 : pointer to the needed input  
	# $t8 : counter for the features 
	# $f18: learning rate 
	# $19: used for input 
	# $f20: used in calculation for the second term of the newWeight equation
	# $f21: used to store -1.0
	# $f22: used to store 1.0 
	# newWeight = Momentum*previousWeight + (1-Momentum)*learningRate*Feature*error 
	# $f25: sumOfSquareErrors 
	# $f26: previousSumOfSquareErrors 
	# $f24: error8error 
	 la $t4, weightsArray 
         add $t4, $t4, $s0 # needs to get the weights again
         lwc1 $f7, 0($t5) # get the threshold in $f7
         lwc1 $f10, momentum
         lwc1 $f9, zeroAsFloat
         sub.s $f9, $f5, $f6 # the error now in $f9  
	
	#         
	mul.s $f24, $f9, $f9 # error*error 
	add.s $f25, $f25, $f24 # add the current sqaure error to the sumOfErrors for the current epoch 
	
	#                        
         xor $s3, $s3, $s3
         la $t1, numOfFeatures
         lb $s3, 0($t1)
         
         move $t9, $t6 
         sll $s3, $s3, 2
         sub $t9, $t9, $s3 # $t9 pointer to the needed input 
         xor $s3, $s3, $s3
         la $t1, numOfFeatures
         lb $s3, 0($t1) # $s5 contains the number of features 
         
         la $t1, learningRate
         lwc1 $f18, 0($t1)
  
         xor $t8, $t8, $t8 # set the counter to 0 
         #
	la $a0, updateWeightsMess
	li $v0, 4
	syscall 
	#
loopThroughFeatures:
	lwc1 $f10, momentum
	beq $t8,$s3, exitLoppThroughFeatures
	lwc1 $f8, 0($t4) # get the weight 
	lwc1 $f19, 0($t9) # get the input 
	mul.s $f8, $f8, $f10 # weight = weight*momentum 
	lwc1 $f20, oneAsFloat
	mul.s $f20, $f20, $f18 # f20=learning rate  
	mul.s $f20, $f20, $f19 # f20=learningRate*input
	mul.s $f20, $f20, $f9  # f20= learningRate*input*error
	lwc1 $f21, minusOneAsFloat
	mul.s $f10, $f10, $f21 # f10 = -1*momentum 
	lwc1 $f22, oneAsFloat
	add.s $f10, $f10, $f22
	mul.s $f20, $f20, $f10 # f20= (1-Momentum)*learningRate*Feature*error
	add.s $f8, $f8, $f20 # newWeight =  weight*momentum + (1-Momentum)*learningRate*Feature*error
	# 
	# printing the   
	mov.s $f12, $f8
	li $v0,2
	syscall
	li $a0,' '
	li $v0,11
	syscall
	#
	swc1 $f8, 0($t4)  
	addi $t4, $t4, 4
	addi $t9, $t9, 4
	addi $t8, $t8, 1
	j loopThroughFeatures
exitLoppThroughFeatures:

# update threshold 
	# thrseshold update= moment*old + (1-momemnt)*rate*erorr
	# $f22: used in calculation for the second term of the newWeight equation
	# $f21: used to store -1.0
	# $f22: used to store 1.0 
	# $f7 : the current threshold
	# $f8 : sued in threshold calculation as the first term 
	# $f9 : the error
	# $f10: momentum
	# $f18: learning rate 	
	lwc1 $f20, zeroAsFloat
	lwc1 $f21, minusOneAsFloat
	lwc1 $f22, oneAsFloat
	# f7 loaded with the threshold value from the previous step
	lwc1 $f8, zeroAsFloat
	lwc1 $f10, momentum
	mul.s $f7, $f7, $f10 # f7 = threshold*momentum 
	mul.s $f10, $f10, $f21 # f10 = -1*momentum 
	lwc1 $f22, oneAsFloat
	add.s $f10, $f10, $f22 # $f10 = 1-momentum 
	mul.s $f22, $f9, $f10 # f22= (1-Momentum)*error 
	mul.s $f22, $f22, $f18 # f22 = (1-Momentum)*error*learningRate "we decided that the input is fixed to 1"
	add.s $f22, $f22, $f7 # new threshold = threshold*momnetun + (1-Momentum)*error*learningRate
	# printing the T 
	#
	la $a0, updateThresholdMess
	li $v0, 4
	syscall 
	mov.s $f12, $f22
	li $v0,2
	syscall
	la $a0, line
	li $v0, 4
	syscall 
	#
	swc1 $f22, 0($t5) # store the new threshold 		 
	jr $ra
# ---------------------- #

# ---------------------- #
# update the learning rate  
# ---------------------- #
updateLearningRate:
	# $f25: sumOfSquareErrors 
	# $f26: previousSumOfSquareErrors 
	# $f24: error*error 
	# $f27: for calculations 
	# $f18: learning rate
	# if sumofSquareError == 0 then no need to update the learning rate. 
	lwc1 $f0, zeroAsFloat
	c.eq.s $f25, $f0
	bc1t updatePreviousSumOfSqaureErrors
	
	lwc1 $f18, learningRate
	lwc1 $f26, previousSumOfSquareErrors
	beq $s4, 1, updatePreviousSumOfSqaureErrors
	lwc1 $f0, zeroAsFloat
	c.eq.s $f26, $f0
	bc1t updatePreviousSumOfSqaureErrors  
	# find the ratio 
	sub.s $f27, $f25, $f26  # $f27 = currentSumOfSquareerrors-previousSumOfSquareerrors
	# div.s $f27, $f25, $f26 
	lwc1 $f0, ratio
	c.le.s $f27, $f0
	bc1t increase
	# decreases the learning rate by 0.7 
	lwc1 $f27, decreasePointSeven
	mul.s $f18, $f18, $f27
	swc1 $f18, learningRate
	j updatePreviousSumOfSqaureErrors
increase: # increase the learning rate by 1.05
	#la $a0, temp
	#li $v0, 4
	#syscall   
	lwc1 $f27, increaseOnePointZeroFive
	mul.s $f18, $f18, $f27
	swc1 $f18, learningRate
updatePreviousSumOfSqaureErrors: 
	swc1 $f25, previousSumOfSquareErrors
	lwc1 $f25, zeroAsFloat
	la $a0, updateLearningRateMess
	li $v0, 4
	syscall  	
	lwc1 $f12, learningRate
	li $v0 , 2
	syscall
	la $a0, newEpochMess
	li $v0, 4
	syscall 
	la $a0, line
	li $v0, 4
	syscall 
	la $a0, line
	li $v0, 4
	syscall 
	jr $ra 
# ---------------------- #

# ---------------------- #
# read the testing file procedure
# ---------------------- #
readTestingArray:
fillingArrayLoopAT:

      #temp 
      xor $t7, $t7, $t7
      #
      la $t0, bufferTempT
      lwc1 $f0, zeroAsFloat  #Setting them for future use
      lwc1 $f1, zeroAsFloat  #loading $f1 with 0.0
      lwc1 $f10, tenAsFloat  #Setting them for future use
      lwc1 $f11, tenAsFloat  
      move $t8, $zero # counter for the testingarray 
      #
      la $a1, testingArray   #the base address of array 
      j fillingArrayLoopT

#register $f1, $f2 will be used in reading the numbers 
#$a1 is the base for samplesArray 

fillingArrayLoopT: 
      lb $s2,0($t0)
      beq  $s2,'\0' endOfFileT # reach end of file need to exit the procedure 
      beq  $s2,',', newElement1T # anther element at the same line 
      beq  $s2,13, newElement2T # another element at the next line 
      beq  $s2,'.', divisionT  # reading the fraction part 
      beq $s2, '-', updateFlagT # reading negative number
      andi $s2,$s2,0x0F # where $t0 contains the ascii digit.
      #tryng to convert 
      mtc1 $s2, $f2
      cvt.s.w $f2, $f2
      #multipplying by ten
      mul.s $f1,$f1,$f10	
      add.s $f1,$f1,$f2
      add $t0, $t0,1
      
      j fillingArrayLoopT

updateFlagT: 
	li $t4, 1
	la $t5, signFlag
	sb $t4, 0($t5)
	addi $t0, $t0, 1
	#lwc1 $f1, zeroAsFloat   #clearing the register
	#lwc1 $f11, tenAsFloat
	j fillingArrayLoopT          
                  
divisionT: # same logic as above
	add $t0, $t0,1
	lb $s2,0($t0)
        beq  $s2,'\0' endOfFileT
        beq  $s2,',', newElement1T
        beq  $s2,13, newElement2T
	andi $s2,$s2,0x0F # where $t0 contains the ascii digit .
        #tryng to convert 
        mtc1 $s2, $f2
        cvt.s.w $f2, $f2
        div.s $f2, $f2, $f11
        add.s $f1, $f1, $f2
        mul.s $f11,$f11,$f10  #first time divide by 10 , 100 , 1000
        j divisionT         
      
      
endOfFileT:
	j exitAT
      
newElement1T: 
	#
	# checking signFlag 
 	la $t5, signFlag
 	lb $t4, 0($t5)
 	beq $t4, 0, storeElement1T   
 	# mul by -1 
 	lwc1 $f12, minusOneAsFloat
 	mul.s $f1, $f1, $f12
 	lwc1 $f12, zeroAsFloat
	# storing
	storeElement1T:
	# storing
	add.s $f12, $f1,$f0
	swc1 $f12, 0($a1) 
	addi $a1, $a1, 4 
	#
	#addi $t8,$t8,1
	addi $t0, $t0, 1
	lwc1 $f1, zeroAsFloat   #clearing the register
	lwc1 $f11, tenAsFloat
	li $t4, 0
	la $t5, signFlag
	sb $t4, 0($t5)
	j fillingArrayLoopT
	 
      
newElement2T: 
	# checking signFlag 
 	la $t5, signFlag
 	lb $t4, 0($t5)
 	beq $t4, 0, storeElement2T   
 	# mul by -1 
 	lwc1 $f12, minusOneAsFloat
 	mul.s $f1, $f1, $f12
 	lwc1 $f12, zeroAsFloat
	# storing
	storeElement2T:     
	# storing
	add.s $f12, $f1,$f0
	swc1 $f12, 0($a1) 
	addi $a1, $a1, 4 
	#
	addi $t8,$t8,1
	addi $t0, $t0, 2
	lwc1 $f1, zeroAsFloat    #clearing the register
	lwc1 $f11, tenAsFloat
	addi $t7, $t7, 1
	li $t4, 0
	la $t5, signFlag
	sb $t4, 0($t5)
	j fillingArrayLoopT            
                  
                
exitAT: 
	la $a1, testingArray
	xor $t6, $t6, $t6 
	# newline
	la $a3, numberOfTestingSamples
	sb $t8, 0($a3)
	j exitT
	
printingSamplesT:
    	beq $t6, $t8, exitT	
	lwc1 $f12, ($a1)
	li $v0, 2
	syscall
	la $a0, newLine
	li $v0, 4
	syscall 

	addi $a1, $a1, 4
	addi $t6, $t6, 1
	j printingSamplesT
	
exitT:
 	jr $ra	
# ---------------------- #

# ---------------------- # 
# calculateTheWeightedSum procedure 
# ---------------------- #
calculateTheWeightedSum:
	
	# $s0 : shift amount for weight 
	# $s1 : shift amount for threshold
	# $s3 : number of features
	# $t4 : address of weightsArray 
	# $t5 : address of thresholdsArray 
	# $f5 : get expected class of sample
	# $f6 : get true class of sample 
	# $f7 : the current threshold 
	# $f13 and $f14 : get the feature and the weight
	# $s4 : counter for the epochs "outer loop"
	# $s5 : counter for the features "inner inner loop" 
	# $f2 : oneAsFloat
	# $f4 : for the weightedSum 
	# $a1 : counter for loopThroughNeurons loop 
	# $a3 : counter for loopThroughTestSamples
	# $a2 : for numberOfTestingSamples
	# $t0 ; for number of classes 
	# $t1 : pointer to the weightedSum array 
	# $t3 : pointer for the testingArray   
	
	la $s2, numOfFeatures
	xor $s3, $s3, $s3
	lb $s3, ($s2)  # s3 : number of featuress in one sample 
	
	move $s0, $a1 # a1 contains the number of the current neuron 
	multu $s0, $s3 
	mflo $s0 # $s0 shift amount to the weight for the current neuron
	sll $s0, $s0, 2
	move $s1, $a1 # $s1 shift amount to the threshold of the current neuron 
	sll $s1, $s1, 2
	la $t4, weightsArray
         add $t4, $t4, $s0 
         
         la $t5, thresholdsArray 
         add $t5, $t5, $s1
	
	xor $s4, $s4, $s4 # counter for the outer loop 
	lwc1 $f4, zeroAsFloat 
	# loop through the features in the current sample
	la $a0, testingSamplesMess
	li $v0, 4
	syscall 
	loopThroughFeatures1: 
		beq $s4, $s3, exitloopThroughFeatures1
		
		lwc1 $f13, 0($t3) # get the feature in f13
		lwc1 $f14, 0($t4) # get the weight in f14 
		mul.s $f13, $f13, $f14
		add.s $f4, $f4, $f13 # add W*F into the weighted sum 
		#
		lwc1 $f12, 0($t3)
		li $v0, 2
		syscall 
		li $a0, ' '
		li $v0, 11
		syscall 
		#
		addi $t3, $t3, 4
		addi $t4, $t4, 4
		addi $s5, $s5, 1
		addi $s4, $s4, 1
		j loopThroughFeatures1
	exitloopThroughFeatures1: 
	
	# subtract the threshold 
	lwc1 $f13, 0($t5) # the threshold value of the current neuron 
	# for printing
	lwc1 $f12, 0($t5)
	# 
	sub.s $f4, $f4, $f13
	
	# store the currnet weightedSum ($f4) into weightedSum array 
	swc1 $f4, 0($t1)
	# for printing 
	lwc1 $f12, zeroAsFloat
	add.s $f12, $f12, $f4
	#
	la $a0, testingWeightsMess
	li $v0, 4
	syscall 
	li $v0, 2
	syscall 
	#
	addi $t1, $t1, 4 
	
	jr $ra
# ---------------------- # 

# ---------------------- #
# soft max function 
# ---------------------- #
softMax:
	# we will store the max in $f30
	# $f28 : used for calculations 
	# $a1 : counter for the loop in this proc
	# $a3 : counter for loopThroughTestSamples
	# $a2 : for numberOfTestingSamples
	# $t0 ; for number of classes 
	# $t1 : pointer to the weightedSum array 
	# $t3 : pointer for the testingArray 
	# $s7 : to store the address of the current sample  
	# $t9 : store the number of neuron with the maximum weighted sum 
	la $t2, numOfClasses
	lb $t0, 0($t2)
	la $t1, weightedSumArray
	xor $a1, $a1, $a1
	xor $t9, $t9, $t9 
	addi $a1, $a1, 1 
	lwc1 $f30, 0($t1)
	addi $t1, $t1, 4
	
	loopMax: 
		beq $a1, $t0, exitLoppMax
		addi $a1, $a1, 1
		lwc1 $f28, 0($t1)
		addi $t1, $t1, 4
		#if f20 > f30 == f30 < f28 then update f30
		c.le.s $f30, $f28
		bc1t updateMax
		j loopMax
		updateMax: 
			mov.s $f30, $f28
			move $t9, $a1
			addi $t9, $t9, -1
			j loopMax
	exitLoppMax:
	jr $ra 
# ---------------------- #

# ---------------------- #
# actPerceptron proc
# ---------------------- #
actPerceptron:
	# $t9 : if weightedSum > 0 it wil be 0
	la $t1, weightedSumArray
	lwc1 $f4, 0($t1)
	lwc1 $f0, zeroAsFloat
	c.le.s $f0, $f4
	bc1t zeroValue1
	li $t9, 1
	j returnActPerceptron
zeroValue1:
	li $t9, 0
returnActPerceptron:
	jr $ra
# ---------------------- #


# ---------------------- #
# proc to calculate the P, A, R to measure the performance of the generated model
# ---------------------- #
calculations:
	# we will store the max in $f30
	# $f28 : used for calculations 
	# $a1 : counter for the loop in this proc
	# $a3 : counter for loopThroughTestSamples
	# $a2 : for numberOfTestingSamples
	# $t0 ; for number of classes 
	# $t1 : pointer to the weightedSum array 
	# $t3 : pointer for the testingArray 
	# $s7 : to store the address of the current sample  
	# $t9 : store the number of neuron with the maximum weighted sum 
	# $t7 : contains the expected output 
	# $f27 : counter for the ture values 
	# $f22 : counter for the false values 
	# f13 : one
	lwc1 $f13, oneAsFloat 
	la $a0, temp
	li $v0, 4
	syscall 
	move $a0, $t7
	li $v0, 1
	syscall 
	li $a0, ' '
	li $v0, 11
	syscall 
	move $a0, $t9
	li $v0, 1
	syscall
	beq $t9, $t7, addTrue # if expected == ture
	add.s $f22, $f22, $f13 
	j return
	addTrue:
		add.s $f27, $f27, $f13  
	return: 
		jr $ra
# ---------------------- #

# ---------------------- #
# procedure to calculate the accuracy of the training model no the test-data
# ---------------------- #
calculateAccuracy: 
	# $f27 : counter for the ture values 
	# $f22 : counter for the false values 
	# f13 : accuracy 
	add.s $f22, $f22, $f27 # f22 = total 
	div.s $f13, $f27, $f22
	la $a0, newLine
	li $v0, 4
	syscall 
	la $a0, accuracyMess
	li $v0, 4
	syscall
	mov.s $f12, $f13
	li $v0, 2
	syscall 
	jr $ra
# ---------------------- #
