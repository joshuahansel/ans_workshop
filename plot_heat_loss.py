import pandas
import matplotlib.pyplot as plt

data1 = pandas.read_csv('out1.csv')
data2 = pandas.read_csv('out2.csv')

plt.figure()
ax = plt.subplot(1, 1, 1)
plt.xlabel('Time [s]')
plt.ylabel('Heat Loss [W]')
plt.plot(data1['time'], data1['heat_loss'], linestyle='-',  color='black', label='Input 1')
plt.plot(data2['time'], data2['heat_loss'], linestyle='--', color='red',   label='Input 2')
ax.legend()
plt.show()
