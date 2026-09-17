"""Purpose: export NB+BH or 21-pair spin+BH tables with explicit data contracts.
Inputs: documented CSV files; output: new CSV (existing files are refused).
Dependencies: NumPy, SciPy; corrected_tests. No neuroimaging jobs are launched.
"""
import argparse
import csv
import itertools
from pathlib import Path
import numpy as np
from corrected_tests import bh_fdr, corrected_resampled_t, spin_pair_tests


def load_csv(path):
    with open(path, newline='', encoding='utf-8-sig') as f:
        reader = csv.DictReader(f)
        rows = list(reader)
        return reader.fieldnames, rows


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('mode',choices=['nb','spin'])
    p.add_argument('--scores',required=True, help='NB: run + model columns; spin: pair + observed columns')
    p.add_argument('--null',help='Spin: 21 pair-named columns, one rotation per row')
    p.add_argument('--comparisons',help='NB: model_a,model_b rows define the complete BH family')
    p.add_argument('--ratio',type=float,default=0.25)
    p.add_argument('--runs',type=int,default=100)
    p.add_argument('--rotations',type=int,default=1000)
    p.add_argument('--output',required=True)
    args=p.parse_args()
    output=Path(args.output)
    if output.exists():p.error('Output already exists; choose a fresh file.')
    fields, rows=load_csv(args.scores)
    results=[]
    if args.mode=='nb':
        if not args.comparisons:p.error('--comparisons is required; the BH family must be declared.')
        if 'run' not in fields or len(rows)!=args.runs or len({r['run'] for r in rows})!=args.runs:
            p.error('Run IDs must be unique; expected one row per configured run.')
        _, comparisons=load_csv(args.comparisons)
        if not comparisons:p.error('Empty comparison family.')
        pairs=[(c['model_a'],c['model_b']) for c in comparisons]
        if any(a==b for a,b in pairs) or len({frozenset(x) for x in pairs})!=len(pairs):
            p.error('Self-comparisons and duplicate pairs are not allowed.')
        for a,b in pairs:
            if a not in fields or b not in fields:p.error('Comparison references an unknown model.')
            result=corrected_resampled_t([float(r[a]) for r in rows],[float(r[b]) for r in rows],args.ratio)
            results.append(dict(model_a=a,model_b=b,**result))
        q=bh_fdr([r['p'] for r in results])
        for r,v in zip(results,q):r['q']=float(v)
    else:
        if not args.null:p.error('--null is required.')
        pairs=['_'.join(x) for x in itertools.combinations(['VIS','SMN','DAN','VAN','LIM','FPN','DMN'],2)]
        if fields != ['pair','observed'] or [r['pair'] for r in rows] != pairs:
            p.error('Observed file must contain the 21 unique network pairs in documented order.')
        null_fields,null_rows=load_csv(args.null)
        if null_fields!=pairs:p.error('Null columns must match the observed pair order exactly.')
        observed=np.array([float(r['observed']) for r in rows])
        null=np.array([[float(r[k]) for k in pairs] for r in null_rows])
        pv,q=spin_pair_tests(observed,null,args.rotations)
        results=[dict(pair=k,observed=float(v),p=float(a),q=float(b),significant=bool(b<0.05)) for k,v,a,b in zip(pairs,observed,pv,q)]
    output.parent.mkdir(parents=True,exist_ok=True)
    with output.open('x',newline='',encoding='utf-8') as f:
        writer=csv.DictWriter(f,fieldnames=list(results[0]));writer.writeheader();writer.writerows(results)


if __name__=='__main__':
    main()
