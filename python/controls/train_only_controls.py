"""Purpose: supplementary train-only nuisance/volume control and Haufe utilities.
Inputs: row-aligned arrays (training and held-out); output: transformed arrays.
Dependencies: NumPy. Added during cleanup, NOT the missing original controls.
Authors must confirm covariate definitions and where these enter nested CV.
"""
import numpy as np


def regress_train_test(train_values,test_values,train_covariates,test_covariates):
    """Fit intercept+covariate OLS on training subjects and apply to held-out data.
    Can be called separately for features or targets. Include the appropriate
    nucleus volume in covariates only after defining it and matching subject IDs.
    In nested CV this must be refit inside each inner split, then outer training.
    """
    xtr,xte,ctr,cte=[np.asarray(a,dtype=float) for a in (train_values,test_values,train_covariates,test_covariates)]
    if xtr.ndim!=2 or xte.ndim!=2 or ctr.ndim!=2 or cte.ndim!=2:
        raise ValueError('All arrays must be 2D; one subject per row.')
    if xtr.shape[0]!=ctr.shape[0] or xte.shape[0]!=cte.shape[0] or xtr.shape[1]!=xte.shape[1] or ctr.shape[1]!=cte.shape[1]:
        raise ValueError('Training/test row or column dimensions do not match.')
    if not all(np.isfinite(a).all() for a in (xtr,xte,ctr,cte)):
        raise ValueError('Non-finite input: define missingness handling explicitly.')
    design=np.column_stack([np.ones(len(ctr)),ctr])
    held=np.column_stack([np.ones(len(cte)),cte])
    if np.linalg.matrix_rank(design)<design.shape[1]:
        raise ValueError('Training covariate design is rank deficient.')
    beta=np.linalg.lstsq(design,xtr,rcond=None)[0]
    return xtr-design@beta,xte-held@beta,beta


def haufe_pattern(training_features,training_predictions):
    """Single-output pattern Cov(X_train,yhat_train)/Var(yhat_train).
    This explicit normalization is not assumed identical to the absent custom
    CBIG PFM function. Preserve training-fold feature scaling and parcel order.
    """
    x=np.asarray(training_features,float); y=np.asarray(training_predictions,float)
    if x.ndim!=2 or y.ndim!=1 or len(x)!=len(y) or len(y)<2:
        raise ValueError('Expected subjects x features and a prediction vector.')
    if not np.isfinite(x).all() or not np.isfinite(y).all():
        raise ValueError('Non-finite data.')
    xc=x-x.mean(axis=0);yc=y-y.mean();denominator=yc@yc
    if denominator<=0:raise ValueError('Predictions have zero variance.')
    return xc.T@yc/denominator
