#!/usr/bin/python
# -*- coding: utf-8 -*-

"""
=====================
Classifier comparison
=====================

A comparison of a several classifiers in scikit-learn on synthetic datasets.
The point of this example is to illustrate the nature of decision boundaries
of different classifiers.
This should be taken with a grain of salt, as the intuition conveyed by
these examples does not necessarily carry over to real datasets.

Particularly in high-dimensional spaces, data can more easily be separated
linearly and the simplicity of classifiers such as naive Bayes and linear SVMs
might lead to better generalization than is achieved by other classifiers.

The plots show training points in solid colors and testing points
semi-transparent. The lower right shows the classification accuracy on the test
set.
"""
#print(__doc__)


# Code source: Gaël Varoquaux
#              Andreas Müller
# Modified for documentation by Jaques Grobler
# License: BSD 3 clause

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.datasets import make_moons, make_circles, make_classification
from sklearn.neural_network import MLPClassifier
from sklearn.neighbors import KNeighborsClassifier
from sklearn.svm import SVC
from sklearn.gaussian_process import GaussianProcessClassifier
from sklearn.gaussian_process.kernels import RBF
from sklearn.tree import DecisionTreeClassifier
from sklearn.ensemble import RandomForestClassifier, AdaBoostClassifier
from sklearn.naive_bayes import GaussianNB
from sklearn.discriminant_analysis import QuadraticDiscriminantAnalysis

from sklearn.metrics import roc_curve, auc
from sklearn.feature_selection import chi2, f_classif, mutual_info_classif
from sklearn.feature_selection import SelectKBest
from sklearn.metrics import precision_recall_curve
from scipy.stats import sem

h = .02  # step size in the mesh

names = ["Nearest Neighbors", "Linear SVM", "RBF SVM", "Gaussian Process",
         "Decision Tree", "Random Forest", "Neural Net", "AdaBoost",
         "Naive Bayes", "QDA"]

classifiers = [
    KNeighborsClassifier(3),
    SVC(kernel="linear", C=0.025),
    SVC(gamma=2, C=1),
    GaussianProcessClassifier(1.0 * RBF(1.0), warm_start=True),
    DecisionTreeClassifier(max_depth=5),
    RandomForestClassifier(max_depth=5, n_estimators=10, max_features=1),
    MLPClassifier(alpha=1),
    AdaBoostClassifier(),
    GaussianNB(),
    QuadraticDiscriminantAnalysis()]

X_in = np.genfromtxt ('X_try.txt', delimiter="\t")
y_in_D = np.genfromtxt ('y_dynamic.txt', dtype=int,delimiter="\t")
y_in_R = np.genfromtxt ('y_reinduce.txt', dtype=int,delimiter="\t")

X_in_pruned=SelectKBest(f_classif,k=5).fit_transform(X_in,y_in_D)
X_in_pruned=X_in[:,[0,9,12]] #override math, cuz math be fucked

dynamic_dataset = (X_in_pruned, y_in_D)
reinduce_dataset = (X_in_pruned, y_in_R)

#datasets = [dynamic_dataset, reinduce_dataset]
datasets = [dynamic_dataset]

# iterate over datasets
plot_x=0
plot_y=0
f,axarr=plt.subplots(2,5)

plt.figure()

param_iterer=0

aucs_rep=np.ndarray(shape=(10,3))
for param_iter in (0.3, 0.4, 0.5):
    plot_x=0
    plot_y=0
    for ds_cnt, ds in enumerate(datasets):
        # preprocess dataset, split into training and test part
        X, y = ds
        X = StandardScaler().fit_transform(X)
        X_train, X_test, y_train, y_test = \
            train_test_split(X, y, test_size=param_iter, random_state=42)

        # iterate over classifiers
        for name, clf in zip(names, classifiers):
            clf.fit(X_train, y_train)
            score = clf.score(X_test, y_test)
            #print('{0} accuracy: {1}'.format(name,score))

            if(name == "Linear SVM"):
                proba=clf.decision_function(X_test)
            elif(name == "RBF SVM"):
                proba=clf.decision_function(X_test)
            else:
                proba=clf.predict_proba(X_test)
                proba=np.transpose(proba[:,1])

            fpr=dict()
            tpr=dict()
            roc_auc=dict()

            fpr["micro"],tpr["micro"],_=roc_curve(y_test,proba)
            roc_auc["micro"]=auc(fpr["micro"],tpr["micro"])

            aucs_rep[plot_x,param_iterer]=roc_auc["micro"]
                


            #precision = dict()
            #recall = dict()
            #average_precision = dict()
            #for pr_ind in range(len(y)):
            #    precision[pr_ind], recall[pr_ind], _ = precision_recall_curve(y_test,proba)

        
            #plot_x_coord=0 if plot_x >= 5 else 1
            #_, plot_y_coord=divmod(plot_y,5)
            #axarr[plot_x_coord,plot_y_coord].plot(fpr["micro"],tpr["micro"],lw=2,label='AUC = %0.2f' % roc_auc["micro"])
            #axarr[plot_x_coord,plot_y_coord].legend(loc="lower right",markerscale=0)

            #axarr[plot_x_coord,plot_y_coord].plot([0, 1], [0, 1], color='navy', lw=2, linestyle='--')
        
            ##axarr[plot_x_coord,plot_y_coord].set_xlim([0.0, 1.0])
            ##axarr[plot_x_coord,plot_y_coord].set_ylim([0.0, 1.05])
            #if(plot_x_coord==1):
            #    axarr[plot_x_coord,plot_y_coord].set_xlabel('False Positive Rate')
            #if(plot_y_coord==0):
            #    axarr[plot_x_coord,plot_y_coord].set_ylabel('True Positive Rate')
            #axarr[plot_x_coord,plot_y_coord].set_title('%s' % name)
            ##axarr[plot_x_coord,plot_y_coord].annotate('AUC = %0.2f' % roc_auc[2], xy=(-12, -12), xycoords='axes points',
            ##    size=14, ha='right', va='top',
            ##    bbox=dict(boxstyle='round', fc='w'))

            #plt.setp([a.get_xticklabels() for a in axarr[0, :]], visible=False)
            #plt.setp([a.get_yticklabels() for a in axarr[:, 1]], visible=False)
            #plt.setp([a.get_yticklabels() for a in axarr[:, 2]], visible=False)
            #plt.setp([a.get_yticklabels() for a in axarr[:, 3]], visible=False)
            #plt.setp([a.get_yticklabels() for a in axarr[:, 4]], visible=False)

            plot_y+=1
            plot_x+=1 

        
            #plot_x_coord=0 if plot_x >= 5 else 1
            #_, plot_y_coord=divmod(plot_y,5)
            #axarr[plot_x_coord,plot_y_coord].plot(precision[2],recall[2],lw=2)
        

            #if(plot_x_coord==1):
            #    axarr[plot_x_coord,plot_y_coord].set_xlabel('Recall')
            #if(plot_y_coord==0):
            #    axarr[plot_x_coord,plot_y_coord].set_ylabel('Precision')
            #axarr[plot_x_coord,plot_y_coord].set_title('%s' % name)
            ##axarr[plot_x_coord,plot_y_coord].annotate('AUC = %0.2f' % roc_auc[2], xy=(-12, -12), xycoords='axes points',
            ##    size=14, ha='right', va='top',
            ##    bbox=dict(boxstyle='round', fc='w'))

            #plt.setp([a.get_xticklabels() for a in axarr[0, :]], visible=False)
            #plt.setp([a.get_yticklabels() for a in axarr[:, 1]], visible=False)
            #plt.setp([a.get_yticklabels() for a in axarr[:, 2]], visible=False)
            #plt.setp([a.get_yticklabels() for a in axarr[:, 3]], visible=False)
            #plt.setp([a.get_yticklabels() for a in axarr[:, 4]], visible=False)

            #plot_y+=1
            #plot_x+=1 
    param_iterer+=1
print(aucs_rep)
plt.show()