#Prepared by: Alaa & Rawan 
#-------------------------#
#Need To consider: 
#Handling the different inputs that the user may be entering 
#reading the name of the file
# in case of perceptron we assume that the neouron is for class 0, so mapping for the output: if out==0 then class 0 is off and vice versa 
#-------------------------#
.data
numOfFeatures: .byte 0
numOfClasses: .byte 0
numOfSamples: .float 0.0
samplesArray: .float 0:1000  # array of 100 element, each is a word.   
weightsArray: .float 0:255
numOfEpochs: .byte 0
learningRate: .float 0.0
threshold: .float 0.0  # delete this later 
thresholdsArray: .float 0:255
momentum: .float 0.0
fileName: .space 50
bufferTemp: .space 2048
newLine: .asciiz "\n"
welcomeMess: .asciiz "\t\t\t\t ----------- Welcome in our Project ---------- \n"
fileNameMess: .asciiz "Enter the Nmae of the Input File : \n"
weightMess: .asciiz "Enter the Weight: \n"
weightInputNumMess: .asciiz "Weights for Neuron NO."
thresholdMess: .asciiz "Enter the threshold value: \n"
momentumMess: .asciiz "Enter the momentum value: \n"
rateMess: .asciiz "Enter the learning rate: \n"
epochsMess: .asciiz "Enter the number of Epochs: \n"

element1: .asciiz "\n Incrementing by 1 \n"
element2: .asciiz "\n Increamenting by 2 \n"
end: .asciiz "\n End of file reached \n"
testing: .asciiz "\n Testing \n"
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


temp: .asciiz "Ecpected & True Value : \n"


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

	
# printing the name of the file
la $a0, fileName
jal printString

# read the input file
jal readFile

#printing what we have read
la $a0, bufferTemp
jal printString

# printing new line
la $a0,newLine
jal printString


# read the number of features and the number of classes from the input file
jal readFeaturesNumAndClassesNum 

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
	# call 
	jal trainingProcedure
	addi $a1, $a1, 1
	j loopThroughNeurons
exitLoopThroughNeurons:
#######################

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
	move $s0, $v0 # move the file pointer into $s0 
	#Reading the File 
	li $v0, 14  
	move $a0, $s0
	la $a1, bufferTemp
	la $a2, 2048 
	syscall 
	li $v0, 16  #Closing the file
	move $a0, $s0
	syscall
	jr $ra	
# ---------------------- #
						
# ---------------------- #
# reading the number of features and the number of classes from the from the input file 
# ---------------------- #
readFeaturesNumAndClassesNum:

	xor $s1,$s1,$s1  #clearing the register
	la $t0, bufferTemp
	li $v0, 4
	syscall
	li $v0, 5
	syscall 
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
	
	move $a0,$s1
	li $v0, 1
	syscall


	la $t0, bufferTemp     #t0 will hold text that will be iterated through
firstLineLoop:
    	lb $s2, 0($t0)      #Loading char to shift into $s2    
    	beq $s2, '\n' , readNumOfClassesA   #Breaking the loop if we've reached the end: 
    	# s2 contain the current character
    	move $a0,$s2
    	li $v0, 1
    	syscall
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
	la $a0, newLine
	li $v0, 4
	syscall
	lb $s1, ($t1)
	move $a0,$s1
	li $v0, 1
	syscall
	la $a0, newLine
	li $v0, 4
	syscall

secondLineLoop:
    	lb $s2, 0($t0)      #Loading char to shift into $s2    
    	beq $s2, '\n' , finishProcedure   #Breaking the loop if we've reached the end: 
    	# s2 contain the current character
    	move $a0,$s2
    	li $v0, 1
   	syscall
    	addi $t0, $t0, 1    #i++
	j secondLineLoop    #Going back to the beginning of the loop
finishProcedure:   
 	li $v0, 5
 	syscall 
    	la $a0, welcomeMess
    	li $v0, 4
	syscall
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
      la $a0,newLine
      li $v0,4
      syscall
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
      andi $s2,$s2,0x0F # where $t0 contains the ascii digit.
      #tryng to convert 
      mtc1 $s2, $f2
      cvt.s.w $f2, $f2
      #multipplying by ten
      mul.s $f1,$f1,$f10	
      add.s $f1,$f1,$f2
      add $t0, $t0,1
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
	la $a0, end
	li $v0, 4
	syscall
	j exitA
      
newElement1: 
       
	#printing what we have read
 	li $v0, 4
	la $a0, element1
	syscall     
	# storing
	add.s $f12, $f1,$f0
	swc1 $f12, 0($a1) 
	addi $a1, $a1, 4 
	#
	addi $t8,$t8,1
	addi $t0, $t0, 1
	lwc1 $f1, zeroAsFloat   #clearing the register
	lwc1 $f11, tenAsFloat
	j fillingArrayLoop
	 
      
newElement2: 
	
	#printing what we have read
 	li $v0, 4
	la $a0, element2
	syscall     
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
	j fillingArrayLoop            
                  
                
exitA: 
	la $a1, samplesArray
	move $a0,$t8
	li $v0, 1
	syscall 
	la $a3, numOfSamples
	#add.s $f12, $f1,$f0
	mtc1 $t7, $f2
     	cvt.s.w $f2, $f2
	swc1 $f2, 0($a3)
	j printingSamples
	
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
	lb $s5, ($t1)
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
    	beq $t6, $s0, e	
	lwc1 $f12, ($a1)
	li $v0, 2
	syscall
	la $a0, newLine
	li $v0, 4
	syscall

	addi $a1, $a1, 4
	addi $t6, $t6, 1
	j exit2	
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
	xor $s2, $s2, $s2
	addi $s2, $s2, 2
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
    	beq $t6, $s0, e1	
	lwc1 $f12, ($a1)
	li $v0, 2
	syscall
	la $a0, newLine
	li $v0, 4
	syscall

	addi $a1, $a1, 4
	addi $t6, $t6, 1
	j exit3
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
	swc1 $f0, ($t9)
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
	li $v0, 1
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
	
	move $s0, $a1 
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
	add.s $f12, $f3, $f0 
	xor $s4, $s4, $s4
	xor $s5, $s5, $s5
	lwc1 $f1, zeroAsFloat    #clearing the register
	lwc1 $f12, zeroAsFloat    #clearing the register
	add.s $f12, $f1, $f0
	lwc1 $f2, oneAsFloat  #Setting them for future use

         la $t4, weightsArray
       
         add $t4, $t4, $s0 
         la $t5, thresholdsArray 
         add $t5, $t5, $s1
         la $t6, samplesArray

               
epochs:  
	beq $s2, $s4, exitTraining	# if $s4==num of epochs "$s2" well done 
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
	add.s $f1, $f1, $f2
newSample: 
	lwc1 $f13, 0($t6) # get the feature in f13
	lwc1 $f14, 0($t4) # get the weight in f14 
	beq $s5,$s3, getClass # if $s5==num of features "$s3" we will read the class of this sample
	mul.s $f13, $f13, $f14
	add.s $f4, $f4, $f13 # add W*F into the weighted sum 
	lwc1 $f12, 0($t6)
	addi $t6, $t6, 4
	addi $t4, $t4, 4
	li $v0, 2
	syscall 
	addi $s5, $s5, 1
         j newSample 

getClass: # call update weights, thresholds.  
	lwc1 $f5, 0($t6) # expected current sample class is in $f5
	lwc1 $f7, 0($t5) # get the threshold in $f7 
	######################
         lwc1 $f12, zeroAsFloat
         add.s $f12, $f12, $f4
         li $v0, 2
         syscall 
         #####################
        	sub.s $f4, $f4, $f7 # weighted sum - threshold 
        	######################
         lwc1 $f12, zeroAsFloat
         add.s $f12, $f12, $f4
         li $v0, 2
         syscall 
         #####################
	# call activation function 
	# calculate the error
	# update the weight and the threshold 
	la $a0, welcomeMess
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
	mul.s $f24, $f9, $f9 # error8erro 
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
	add.s $f8, $f8, $f20 # newWeight 
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
	add.s $f22, $f22, $f7 # new threshold
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
	lwc1 $f18, learningRate
	lwc1 $f26, previousSumOfSquareErrors
	beq $s4, 1, updatePreviousSumOfSqaureErrors
	lwc1 $f0, zeroAsFloat
	c.eq.s $f26, $f0
	bc1t updatePreviousSumOfSqaureErrors
	la $a0, newLine
	li $v0, 4
	syscall  
	la $a0, welcomeMess
	li $v0, 4
	syscall
	li $v0, 1
	move $a0, $s4
	syscall 
	la $a0, newLine
	li $v0, 4
	syscall 
	# find the ratio 
	div.s $f27, $f25, $f26 # $f27 = currentSumOfSquareerrors/previousSumOfSquareerrors
	lwc1 $f0, ratio
	c.le.s $f27, $f0
	bc1t increase
	# decreases the learning rate by 0.7 
	lwc1 $f27, decreasePointSeven
	mul.s $f18, $f18, $f27
	swc1 $f18, learningRate
	j updatePreviousSumOfSqaureErrors
increase: # increase the learning rate by 1.05
	la $a0, temp
	li $v0, 4
	syscall   
	lwc1 $f27, increaseOnePointZeroFive
	mul.s $f18, $f18, $f27
	swc1 $f18, learningRate
updatePreviousSumOfSqaureErrors: 
	swc1 $f25, previousSumOfSquareErrors
	lwc1 $f25, zeroAsFloat
	la $a0, newLine
	li $v0, 4
	syscall  	
	lwc1 $f12, learningRate
	li $v0 , 2
	syscall 
	la $a0, newLine
	li $v0, 4
	syscall 
	jr $ra 
# ---------------------- #

# ---------------------- #
# findMaxPropability procedure  
# ---------------------- #

# ---------------------- #


# ---------------------- #
# ........ 
# ---------------------- #

# ---------------------- #
