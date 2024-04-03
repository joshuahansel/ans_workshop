import pandas
import matplotlib.pyplot as plt

data1 = pandas.read_csv('out1_top_vpp_FINAL.csv')
data2 = pandas.read_csv('out2_top_vpp_FINAL.csv')

plt.figure()
ax = plt.subplot(1, 1, 1)
plt.xlabel('Position [m]')
plt.ylabel('Temperature [K]')
plt.plot(data1['x'], data1['T_inf'], linestyle='-',  color='cornflowerblue',  label='Environment')
plt.plot(data1['x'], data1['T'], linestyle='-',  color='black',     label='Surface, Input 1')
plt.plot(data2['x'], data2['T'], linestyle='--', color='indianred', label='Surface, Input 2')
ax.legend()
plt.show()
