#!/home/mzamith/Apps/anaconda3/bin/python
import matplotlib.pyplot as plt
import matplotlib.collections as collections
import csv
import codecs
import statistics
def findAverage(fileName, samples, isX = False):
    X         = []
    Y         = []
    AVE       = []
    
    flag      = 0
    delimiter = ';'
    reader    = codecs.open(fileName, 'r', encoding='utf-8')
    
    for line in reader:
        row = line.split(delimiter)
        x = row[0]
        AVE.append(float(row[1]))
        flag =  flag + 1
        if (flag == samples):
            ave = statistics.mean(AVE)
            AVE = []
            #Memória em Kbytes
            X.append(float(x)/1024)
            Y.append(ave)
            flag = 1

    if isX == True:
        return X, Y
    else:
        return Y

def gTime():
        #10 = número de amostras
    X, Ys = findAverage('sequencial.csv', 10, True)
    Y1 = findAverage('paralelo-struct.csv', 10, False)
#    Y2 = findAverage('/home/mzamith/Documents/Projetos/HPC/n-bodies/source-cpp/test-01/paralelo-sem-struct.csv', 5, False)

    fig = plt.figure()
    ax = fig.add_subplot(111)
    ax.plot(X, Ys, marker='o', markerfacecolor='black', markersize=5, color='black', linewidth=1)
    ax.plot(X, Y1, marker='o', markerfacecolor='blue', markersize=5,color='blue', linewidth=1)
#    ax.plot(X, Y2, marker='o', markerfacecolor='red', markersize=5,color='red', linewidth=1)

    #ax.axvline(262144, color ='green', lw = 2, alpha = 0.75) 
    ax.set_title('Performance do n-corpos') 

    ax.legend(['Sequencial', 'Paralelo 6T'])
    plt.xlabel('KBytes trafegados')
    plt.ylabel('tempo em segundos')
    plt.savefig('Fig-08-tempo.pdf')

def gSpeedup():
    #10 = número de amostras
    X, Ys = findAverage('sequencial.csv', 10, True)
    Y1 = findAverage('paralelo-struct.csv', 10, False)


    A1 = []
 #   A2 = []
    
    for i in range(0, len(X)):
        s = Ys[i] / Y1[i]
        A1.append(s)
  #      s = Ys[i] / Y2[i]
   #     A2.append(s)
        
    fig = plt.figure()
    ax = fig.add_subplot(111)

    ax.plot(X, A1, marker='o', markerfacecolor='blue', markersize=5,color='blue', linewidth=1)
#    ax.plot(X, A2, marker='o', markerfacecolor='red', markersize=5,color='red', linewidth=1)

    #ax.axvline(262144, color ='green', lw = 2, alpha = 0.75) 
    ax.set_title('Performance do n-corpos') 

    ax.legend(['Paralelo 6T '])
    plt.xlabel('KBytes trafegados')
    plt.ylabel('aceleração')
    plt.savefig('Fig-09-aceleracao.pdf')

    
if __name__ == "__main__":
    gTime()
    gSpeedup()
    
    
    
    