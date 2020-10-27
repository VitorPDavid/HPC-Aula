#!/home/mzamith/Apps/anaconda3/bin/python
import matplotlib.pyplot as plt
import matplotlib.collections as collections
import csv
import codecs
import statistics
import sys
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
    X, Y2 = findAverage('paralelo-2T.csv', 10, True)
    Y4 = findAverage('paralelo-4T.csv', 10, False)
    Y6 = findAverage('paralelo-6T.csv', 10, False)
    Y8 = findAverage('paralelo-8T.csv', 10, False)

#    Y2 = findAverage('/home/mzamith/Documents/Projetos/HPC/n-bodies/source-cpp/test-01/paralelo-sem-struct.csv', 5, False)

    fig = plt.figure()
    ax = fig.add_subplot(111)
    ax.plot(X, Y2, marker='o', markerfacecolor='black', markersize=5, color='black', linewidth=1)
    ax.plot(X, Y4, marker='o', markerfacecolor='blue', markersize=5,color='blue', linewidth=1)
    ax.plot(X, Y6, marker='o', markerfacecolor='green', markersize=5, color='green', linewidth=1)
    ax.plot(X, Y8, marker='o', markerfacecolor='red', markersize=5,color='red', linewidth=1)
#    ax.plot(X, Y2, marker='o', markerfacecolor='red', markersize=5,color='red', linewidth=1)

    #ax.axvline(262144, color ='green', lw = 2, alpha = 0.75) 
    ax.set_title('Performance do n-corpos') 

    ax.legend(['Paralelo 2T', 'Paralelo 4T', 'Paralelo 6T', 'Paralelo 8T'])
    plt.xlabel('KBytes trafegados')
    plt.ylabel('tempo em segundos')
    #plt.show()
    plt.savefig('Fig-10-tempo-mt.pdf')

def gSpeedup():
    #10 = número de amostras
    Ys = findAverage('sequencial.csv', 10, False)
    X, Y2 = findAverage('paralelo-2T.csv', 10, True)
    Y4 = findAverage('paralelo-4T.csv', 10, False)
    Y6 = findAverage('paralelo-6T.csv', 10, False)
    Y8 = findAverage('paralelo-8T.csv', 10, False)


#    print(len(Y2))
#    print(len(Ys))
#    sys.exit(0)
    A2 = []
    A4 = []
    A6 = []
    A8 = []
 #   A2 = []
    
    for i in range(0, len(Y2)):
        s = Ys[i] / Y2[i]
        A2.append(s)
        s = Ys[i] / Y4[i]
        A4.append(s)
        s = Ys[i] / Y6[i]
        A6.append(s)
        s = Ys[i] / Y8[i]
        A8.append(s)

  #      s = Ys[i] / Y2[i]
   #     A2.append(s)
        
    fig = plt.figure()
    ax = fig.add_subplot(111)

    ax.plot(X, A2, marker='o', markerfacecolor='black', markersize=5,color='black', linewidth=1)
    ax.plot(X, A4, marker='o', markerfacecolor='blue', markersize=5,color='blue', linewidth=1)
    ax.plot(X, A6, marker='o', markerfacecolor='green', markersize=5, color='green', linewidth=1)
    ax.plot(X, A8, marker='o', markerfacecolor='red', markersize=5,color='red', linewidth=1)

    #ax.axvline(262144, color ='green', lw = 2, alpha = 0.75) 
    ax.set_title('Performance do n-corpos') 

    ax.legend(['Paralelo 2T', 'Paralelo 4T', 'Paralelo 6T', 'Paralelo 8T'])
    plt.xlabel('KBytes trafegados')
    plt.ylabel('aceleração')
#    plt.show()
    plt.savefig('Fig-11-aceleracao-mt.pdf')

    
if __name__ == "__main__":
    gTime()
    gSpeedup()
    
    
    
    