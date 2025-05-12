import matplotlib.pyplot as plt
import numpy as np 
import rdata
# from sklearn.model_selection import train_test_split
#from sklearn.linear_model import LogisticRegression
#from sklearn.metrics import accuracy_score, classification_report
#from sklearn.datasets import load_breast_cancer


import rdata
parsed = rdata.parser.parse_file("D:/git/data/bot_vs_human/human_vs_bot_data.RData")
converted = rdata.conversion.convert(parsed)
print(converted.keys())

training_dat = converted["training_data"]
myVars = training_dat[['sd_inter_click','rate','isBot']]
# Plot settings
fig, ax = plt.subplots(figsize=(4,3))
x_min, x_max, y_min, y_max = -3,14,0,8
ax.set(xlim=(x_min,x_max), ylim = (y_min,y_max))

# Plot samples by color and add legend
scatter = ax.scatter(myVars.iloc[:,0],myVars.iloc[:,1], s = 150, c = myVars.iloc[:,2], label = myVars.iloc[:,2], edgecolors = "k")
ax.legend(*scatter.legend_elements(), loc="upper right", title = "Classes")
ax.set_title("Samples in two-dimensional feature space")
_ = plt.show()