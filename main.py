import random
import csv
def training_generate():
    numberOfFeatures = 4
    numberOfClasses = 3
    sample =""
    i = 0;
    while (i<50):
        j =0
        while(j<4):
            n = random.random()
            n = float("{0:.2f}".format(n))
            sample += str(n)
            sample += ","
            j+=1
        n = random.randint(0,numberOfClasses-1)
        sample += str(n)
        sample += "\n"
        i+=1
    print(sample)
    allSamples = str(numberOfFeatures) + ",\n" + str(numberOfClasses) + ",\n" + sample
    # write the result into  a CSV file
    with open('archTraining_1.csv', mode='w') as file:
        file.write(allSamples)
def testing_generate():
    numberOfFeatures = 4
    numberOfClasses = 3
    sample = ""
    i = 0;
    while (i < 13):
        j = 0
        while (j < 4):
            n = random.random()
            n = float("{0:.2f}".format(n))
            sample += str(n)
            sample += ","
            j += 1
        n = random.randint(0, numberOfClasses-1)
        sample += str(n)
        sample += "\n"
        i += 1
    print(sample)
    # write the result into  a CSV file
    with open('archTesting_1.csv', mode='w') as file:
        file.write(sample)
training_generate()
testing_generate()