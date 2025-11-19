import numpy as np
import pandas as pd
from math import ceil
import random
import random_concept_generator
import tableau_exp
import timeit
import forms


#set the random seed
random_seed = 99
random.seed(random_seed)


#1. Generating sets of random formulas----------------

#1.1. preparation --

#number of formulas to generate
no_formulas = 150

#create empty data.frame first
data = pd.DataFrame(index=range(no_formulas), columns=['formula', 'formula2',
                                                       'no_atoms', 'form_size',
                                                       'modal_depth', 'no_modal', 'modal_share',
                                                       'time_parsing', 
                                                       'time_tableau_min','time_tableau_avg',
                                                       'no_conj',
                                                       'no_descr_global', 'no_descr_local','descr_global_share', 'descr_local_share',
                                                       'no_occurr_atoms', 'no_diff_atoms',
                                                       'time_out', 'is_satisfiable',
                                                       'no_rules_applied', 'no_branches_explored'])



#1.2. generating the random formulas --

for i in range(no_formulas):

    #choose the number of atoms; this will determine the size of the generated syntax tree
    no_atoms = random.randint(10,200)

    #set parameters of formulas to be generated    
    rand_form = random_concept_generator.random_ALCi_concept_str(no_atoms = no_atoms,
                                                                 no_diff_atoms = ceil(no_atoms/2),
                                                                 neg_chance = 0.5,
                                                                 no_modal = ceil((2*no_atoms-1)*0.3),
                                                                 no_LD = ceil(0.1*(no_atoms-1)),
                                                                 GD_chance = None,
                                                                 GD_count = 0)


    data.loc[i, 'formula'] = rand_form
    data.loc[i, 'no_atoms'] = no_atoms



#2. Parsing the formula and gathering data about it ----------------


#2.1. measuring parsing time --

tableau_parser = """ 
parser_tree = forms.parser_DL.parse(form)
fml = forms.ToFml().transform(parser_tree)
"""

for row in data.itertuples():
    
    form = row.formula
    
    time_parsing = timeit.repeat(stmt=tableau_parser,
                                  number=1, 
                                  repeat = 1,
                                  globals=globals())
    
    data.loc[row.Index, 'time_parsing'] = min(time_parsing)
        


#2.2. gathering data about the formula --

for row in data.itertuples():
    
    form = row.formula
    
    parser_tree = forms.parser_DL.parse(form)
    fml = forms.ToFml().transform(parser_tree)

    data.loc[row.Index, 'formula2'] = fml.formula_string()
    data.loc[row.Index, 'modal_depth'] = fml.modal_degree()
    data.loc[row.Index, 'no_modal'] = fml.modal_count()
    data.loc[row.Index, 'no_descr_global'] = fml.descr_global_count()
    data.loc[row.Index, 'no_descr_local'] = fml.descr_local_count()
    data.loc[row.Index, 'no_conj'] = fml.binary_count()
    data.loc[row.Index, 'no_diff_atoms'] = fml.var_count()



data['no_neg'] = data['formula2'].str.count('¬')
data['form_size'] = data['no_atoms'] + data['no_descr_global'] + data['no_descr_local'] + data['no_conj'] + data['no_neg'] + data['no_modal']
data['modal_share'] = data['no_modal']/(2*data['no_atoms']-1)
data['descr_local_share'] = data['no_descr_local']/(2*data['no_atoms']-1)
data['descr_global_share'] = data['no_descr_global']/(data['no_atoms']-1)



#3. Building the tableau ----------------


#3.1. measuring tableau generation time --

preparation_parser = """
import tableau_exp
tab = tableau_exp.DL_Tableau_exp(formula = form)
"""

n=0
for row in data.itertuples():
    
    form = row.formula

    time_tableau = timeit.repeat(stmt='tab.build_tableau()',
                                  setup = preparation_parser,
                                  number=1, 
                                  repeat = 5,
                                  globals=globals())
    
    data.loc[row.Index, 'time_tableau_min'] = min(time_tableau)
    data.loc[row.Index, 'time_tableau_avg'] = np.mean(time_tableau)
    n +=1
    print("tab built", n)


#3.2. gathering information about the tableau --


for row in data.itertuples():
    
    form = row.formula

    tab = tableau_exp.DL_Tableau_exp(formula = form)

    tab_result = tab.build_tableau()

    data.loc[row.Index, 'time_out'] = tab_result[0]
    data.loc[row.Index, 'is_satisfiable'] = tab_result[1]
    data.loc[row.Index, 'no_branches_explored'] = (tab_result[2] + 1) if tab_result[1] else tab_result[2]
    data.loc[row.Index, 'no_rules_applied'] = tab_result[3]
    
    
    

data.to_csv('data.csv')
data.to_excel('data.xlsx')
