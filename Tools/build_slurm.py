import re
import os
import argparse
import pandas as pd

parser = argparse.ArgumentParser(description='Generate shell script for group processing')
parser.add_argument('-s', '--sample_id', help='sample id', required=True)

args = parser.parse_args()

home_path = os.path.dirname(os.path.realpath(__file__))  + '/../'
template_file = home_path + 'Tools/job_template.sh'

def func(m):
    return replace_pair[m.group(1).strip('_')]
    
if __name__ == "__main__":
    dfs = []
    
    # build slurm
    slurm_file = home_path + 'sh/Kneaddata-' + args.sample_id + '.sh'
    
    replace_pair = {}
    replace_pair['SAMPLE_ID'] = args.sample_id
    with open(template_file) as ft, \
        open(slurm_file, 'w') as fs:
        for line in ft:
            p = re.compile('(__.+?__)')
            s = p.search(line.strip())
            if s:
                fs.write(p.sub(func, line.strip()) + '\n')
            else:
                fs.write(line)
