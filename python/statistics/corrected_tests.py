"""Purpose: explicit supplementary implementations of corrected inference.
Inputs: paired run-level scores or observed/null arrays; outputs: statistics.
Dependencies: NumPy, SciPy.
"""
import numpy as np
from scipy import stats


def bh_fdr(p_values):
    """BH adjusted p values for exactly the supplied family (no NaN dropping)."""
    p = np.asarray(p_values, dtype=float)
    if p.size == 0 or not np.isfinite(p).all() or np.any((p < 0) | (p > 1)):
        raise ValueError('Provide nonempty, finite p values in [0,1].')
    flat = p.ravel()
    order = np.argsort(flat, kind='stable')
    scaled = flat[order] * flat.size / np.arange(1, flat.size + 1)
    adjusted = np.minimum.accumulate(scaled[::-1])[::-1].clip(0, 1)
    result = np.empty_like(flat)
    result[order] = adjusted
    return result.reshape(p.shape)


def corrected_resampled_t(a, b, test_train_ratio=0.25):
    """Two-sided NB test on paired run-level differences; sample variance ddof=1.

    SE = sqrt((1/J + n_test/n_train) * sample_variance(a-b)); df = J-1.
    Pass 100 run-level mean-fold scores, not 500 folds as independent rows.
    Confidence interval uses the same correction. d_z uses uncorrected SD of
    the paired differences. No Fisher-z transform is silently applied.
    """
    a, b = np.asarray(a, dtype=float), np.asarray(b, dtype=float)
    if a.ndim != 1 or b.shape != a.shape or len(a) < 2:
        raise ValueError('Provide paired 1D run-level scores of equal length >=2.')
    if not np.isfinite(a).all() or not np.isfinite(b).all():
        raise ValueError('Missing values require an explicit analysis decision.')
    if not np.isfinite(test_train_ratio) or test_train_ratio <= 0:
        raise ValueError('test_train_ratio must be positive and finite.')
    d = a - b
    mean = float(d.mean())
    sd = float(d.std(ddof=1))
    se = float(np.sqrt((1.0 / len(d) + test_train_ratio) * sd * sd))
    if se == 0:
        raise ValueError('Zero variance of paired differences: test and d_z are undefined.')
    t = mean / se
    df = len(d) - 1
    margin = float(stats.t.ppf(0.975, df) * se)
    return dict(n_runs=len(d), mean_difference=mean, standard_error=se, t=t,
                df=df, p=float(2 * stats.t.sf(abs(t), df)),
                ci95_low=mean-margin, ci95_high=mean+margin, d_z=mean/sd,
                test_train_ratio=float(test_train_ratio))


def spin_pair_tests(observed, null, expected_rotations=1000):
    """Left-tail plus-one empirical tests; BH across exactly 21 unique pairs.

    Input observed: (21,); null: (1000,21), same explicit pair ordering.
    Each call defines one family. No averaging over nuclei is inferred.
    """
    observed, null = np.asarray(observed,float), np.asarray(null,float)
    if observed.shape != (21,) or null.shape != (expected_rotations,21):
        raise ValueError('Expected 21 observed Dice values and rotations x 21 null values.')
    if not np.isfinite(observed).all() or not np.isfinite(null).all():
        raise ValueError('Missing/non-finite Dice values cannot be silently discarded.')
    if np.any((observed<0)|(observed>1)) or np.any((null<0)|(null>1)):
        raise ValueError('Dice similarities must be in [0,1].')
    p = (1 + np.sum(null <= observed[None,:], axis=0)) / float(null.shape[0]+1)
    return p, bh_fdr(p)
