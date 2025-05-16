import matplotlib.pyplot as plt
import numpy as np 
import rdata
import os
# from matplotlib import pyplot as plt
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix


#from sklearn.metrics import accuracy_score, classification_report
#from sklearn.datasets import load_breast_cancer


parsed = rdata.parser.parse_file("D:/git/data/bot_vs_human/human_vs_bot_data.RData")
converted = rdata.conversion.convert(parsed)
print(converted.keys())

training_dat = converted["training_data"]
test_dat = converted["test_data"]

colNames = training_dat.columns

myTrainVars = training_dat[['rate','sd_inter_click','isBot']]
# Plot settings
fig, ax = plt.subplots(figsize=(4,3))
x_min, x_max, y_min, y_max = -3,14,0,8
ax.set(xlim=(x_min,x_max), ylim = (-1,y_max))
# Plot samples by color and add legend
scatter = ax.scatter(myTrainVars.iloc[:,1],myTrainVars.iloc[:,0], s = 150, c = myTrainVars.iloc[:,2], label = myTrainVars.iloc[:,2], edgecolors = "k")
ax.legend(*scatter.legend_elements(), loc="upper right", title = "Classes")
ax.set_title("Samples in two-dimensional feature space")
plt.xlabel("SD", fontsize=16)
plt.ylabel("Rate", fontsize = 16)
plt.title("Scatter Plot of Rate vs SD")
#_ = plt.show()

plt.savefig("visualizations/scatterPlot_sdRate.png")
plt.close()

# prep for logistic regression; L2 is ridge regression
X = myTrainVars[['rate']]
y = myTrainVars[['isBot']].values.ravel()

logReg1_L2 = LogisticRegression()
logReg1_L2.fit(X,y)

intercept_L2 = round(logReg1_L2.intercept_[0],3)

print("Model with only rate:",
      "intercept: {}".format(intercept_L2),
      "Coefficient: {}".format(round(logReg1_L2.coef_[0][0],3)),
      sep = os.linesep)

#logReg1_R = LogisticRegression(penalty='none', solver='lbfgs', max_iter=1000)
logReg1_R = LogisticRegression(penalty="l2", C=1e10,solver='lbfgs', max_iter=1000)
logReg1_R.fit(X,y)

intercept_noPenalty = round(logReg1_R.intercept_[0],3)

print("Model with only rate:",
      "intercept: {}".format(intercept_noPenalty),
      "Coefficient: {}".format(round(logReg1_R.coef_[0][0],3)),
      sep = os.linesep)

## Matches closer to R output
######################################

# logistic regression using two predictors
X2 = myTrainVars[['rate','sd_inter_click']]
features = X2.columns
logReg2_R = LogisticRegression(penalty="l2", C=1e10,solver='lbfgs', max_iter=1000)
logReg2_R.fit(X2,y)

intercept2_noPenalty = round(logReg2_R.intercept_[0],3)

print("Model with only rate:",
      f"intercept: {intercept2_noPenalty}",
      "Coefficient:",
      "   {}: {}".format(features[0],round(logReg2_R.coef_[0][0],3)),
      "   {}: {}".format(features[1],round(logReg2_R.coef_[0][1],3)),
      sep = os.linesep)
rate_x1_range = np.linspace(training_dat['rate'].min(),training_dat['rate'].max(),100)
sd_x2_range = np.linspace(training_dat['sd_inter_click'].min(),training_dat['sd_inter_click'].max(),100)

x1Rate, x2SD = np.meshgrid(rate_x1_range,sd_x2_range)

## new cases: 100 values based on training data min and max values for predictors
grid = np.c_[x1Rate.ravel(),x2SD.ravel()]


## use model developed using to predictors to predict probabilites on 'new' cases: grid
probs = logReg2_R.predict_proba(grid)[:,1].reshape(x1Rate.shape)

## Figure/Plot settings: plot new data
myFig = plt.figure()
myPlot2D = myFig.add_subplot(111, projection = '3d')
myPlot2D.plot_surface(x1Rate,x2SD,probs,cmap="viridis",edgecolor = 'none')
myPlot2D.set_xlabel("Rate")
myPlot2D.set_ylabel("SD")
myPlot2D.set_zlabel('P(y=1)')
# plt.show()
# plt.savefig("visualizations/logReg_3D_predictionsSigmoidPlot.png")
# plt.close()

## plot scatter plot from above of two predictor variables, but with decision boundary
plt.contour(x1Rate,x2SD,probs, levels = [0.5], colors = 'black')

plt.scatter(X2.iloc[:,0],X2.iloc[:,1], c = y, cmap="bwr", edgecolor="k")
plt.xlabel("Rate")
plt.ylabel("SD")
plt.title("Logistic Regression Decision Boundary")
plt.show()


## plot sigmoid in 2D (rate) - plot 0,1 values for isBot
myFig2D = plt.figure()
myPlot2D = myFig2D.add_subplot(111)
myPlot2D.plot(x1Rate[52,:],probs[52])
myPlot2D.set_xlabel("Rate")
myPlot2D.set_ylabel("P(isBot=TRUE)")

plt.axhline(y=0.5, color = 'gray', linestyle='--', label='Threshold = 0.5')
decision_idx = np.argmin(np.abs(probs[52] - 0.5))
plt.axvline(x=x1Rate[52,:][decision_idx], color = 'black', linestyle=':',label = "Decision Boundary")

#test_dat_isBot = test_dat

plt.scatter(test_dat["rate"],test_dat["isBot"].astype(int), c = "red")

plt.title("Sigmoid Curve at SD ~ {}".format(round(x2SD[52,0],2)))
plt.show()


## plot sigmoid in 2D (sd_inter_click) - plot 0,1 values for isBot
myFig2D_SD = plt.figure()
myPlot2D_SD = myFig2D_SD.add_subplot(111)
myPlot2D_SD.plot(x2SD[:,52],probs[52])
myPlot2D_SD.set_xlabel("SD")
myPlot2D_SD.set_ylabel("P(isBot=TRUE)")

plt.axhline(y=0.5, color = 'gray', linestyle='--', label='Threshold = 0.5')
decision_idx_SD = np.argmin(np.abs(probs[52] - 0.5))
plt.axvline(x=x2SD[:,52][decision_idx_SD], color = 'black', linestyle=':',label = "Decision Boundary")

#test_dat_isBot = test_dat

plt.scatter(test_dat["sd_inter_click"],test_dat["isBot"].astype(int), c = "red")

plt.title("Sigmoid Curve at Rate ~ {}".format(round(x1Rate[52,0],2)))
plt.show()