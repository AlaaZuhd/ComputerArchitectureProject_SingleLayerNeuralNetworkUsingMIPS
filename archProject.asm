#Prepared by: Alaa & Rawan 
#-------------------------#
#Need To consider: 
#Handling the different inputs that the user may be entering 
#reading the name of the file
#-------------------------#
.data
numOfFeatures: .byte 0
numOfClasses: .byte 0
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
welcomeMess: .asciiz "\t\t ----------- Welcome in our Project ---------- \n"
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
tenAsFloat: .float 10.0
maximumNumOfChars: .byte 50
#t8 is used as a counter to count the number of elements in the samplesArray
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
	
li $v0, 13  #for open file
la $a0, fileName
li $a1, 0  #Flag=0 for read
syscall
move $s0, $v0
#


#Reading the File 
li $v0, 14  
move $a0, $s0
la $a1, bufferTemp
la $a2, 2048 
syscall 

#printing what we have read
la $a0, bufferTemp
jal printString


# printing new line
la $a0,newLine
jal printString
xor $s1,$s1,$s1  #clearing the register
la $t0, bufferTemp
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
	sb $s1,($t1)
	la $a0, newLine
	jal printString
	lb $s1, ($t1)
	move $a0,$s1
	li $v0, 1
	syscall
	la $a0, newLine
	jal printString

secondLineLoop:
    lb $s2, 0($t0)      #Loading char to shift into $s2    
    beq $s2, '\n' , fillingArrayLoopA   #Breaking the loop if we've reached the end: 
    # s2 contain the current character
    move $a0,$s2
    li $v0, 1
    syscall
    addi $t0, $t0, 1    #i++
    j secondLineLoop    #Going back to the beginning of the loop
    
##########################    
    
          
fillingArrayLoopA:

      #temp 
      addi $t7, $zero, 9
      #
      addi $t0,$t0,1    #moving byte by byte from the read string
      lwc1 $f0, zeroAsFloat  #Setting them for future use
      lwc1 $f10, tenAsFloat  #Setting them for future use
      lwc1 $f11, tenAsFloat
      move $t8, $zero
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
      beq  $s2,'\0' endOfFile
      beq  $s2,',', newElement1
      beq  $s2,13, newElement2
      beq  $s2,'.', division
      andi $s2,$s2,0x0F # where $t0 contains the ascii digit .
      #tryng to convert 
      mtc1 $s2, $f2
      cvt.s.w $f2, $f2
      #multipplying by ten using shift
      mul.s $f1,$f1,$f10	
      add.s $f1,$f1,$f2
      add $t0, $t0,1
      j fillingArrayLoop
      
division: 
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
	jal printString
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
	j fillingArrayLoop            
                  
                
exitA: 
	la $a1, samplesArray
	move $a0,$t8
	li $v0, 1
	syscall 
	j printingSamples
	
printingSamples:
    	beq $t6, $t8, exit	
	lwc1 $f12, ($a1)
	li $v0, 2
	syscall
	la $a0, newLine
	jal printString

	addi $a1, $a1, 4
	addi $t6, $t6, 1
	j printingSamples
	
exit:	


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

bne $s5, $s3 loopingThroughNeurons
sub $s5, $s5, 1		
						
loopingThroughNeurons:
	beq $s1, $s5, exit2 # check if outer loop counter == number of neurons 
	addi $s1,$s1,1
	xor $s2, $s2, $s2  #acts as a counter for the second loop, need to clear it. 
	#########beq $s3, $s5, readingOneWeight
	# special message 
	la $a0, weightInputNumMess # change the name and the message 
	jal printString
	li $v0, 1
	move $a0, $s1
	syscall 
	la $a0, newLine 
	jal printString 
	la $a0, weightMess
	
	j readingWeightsForCurrentNeuronLoop
readingWeightsForCurrentNeuronLoop:
	beq $s0, $s2, loopingThroughNeurons # ending of the inner loop-> go back to the outer loop
	jal printString
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
	jal printString

	addi $a1, $a1, 4
	addi $t6, $t6, 1
	j exit2	
e:

# reading the thresolhdsArray 

la $t0, numOfClasses
lb $s0, ($t0)   #number of classe stored here
xor $s1,$s1,$s1  #acts as a counter, need to clear it
xor $s2, $s2, $s2
addi $s2, $s2, 2
la $t0, thresholdsArray
la $a0, thresholdMess
la $a1, thresholdsArray
xor $t6,$t6,$t6 






# if numOfClasses == 2: then read one value in the thresholdsArray, else read as many values as the numOfClasses
bne $s2, $s0, readingThresholdsLoop
jal printString
li $v0, 6
syscall 
swc1 $f0, ($t0)
addi $s1,$s1,1
addi $t0, $t0, 4
j exit3 

readingThresholdsLoop: 
	beq $s1,$s0,exit3 
	jal printString
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

#################################



# reading the learning rate
la $a0,rateMess
jal printString
li $v0, 6
syscall
la $t9, learningRate
swc1 $f0, ($t9)


# reading the value of the momentum 
la $a0,momentumMess
jal printString
li $v0, 6
syscall
la $t9, momentum
swc1 $f0, ($t9)




# reading thr number of epochs
la $a0,epochsMess
jal printString
li $v0, 5
syscall
la $t9, numOfEpochs
sb $v0, ($t9)
# --------------------------
li $v0, 1
la $a1, numOfEpochs
lb $a0,($a1)
syscall



li $v0, 16  #Closing the file
move $a0, $s0
syscall

li $v0, 10 
syscall


#printing a float
#li $v0, 2
#l.s $a0, threshold
#syscall

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
# reading the number of features from the input file 
# ---------------------- #

	
# ---------------------- #