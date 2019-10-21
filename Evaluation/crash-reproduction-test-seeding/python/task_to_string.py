from sys import argv
import json



application=argv[1]
version=argv[2]
case=argv[3]
frame=argv[4]
execution_idx=argv[5]
search_budget=argv[6]
p_object_pool=argv[7]
seed_clone=argv[8]
seed_mutations=argv[9]



data = {'application': application,
        'version': version,
        'case': case,
        'frame': frame,
        'execution_idx': execution_idx,
        'search_budget': search_budget,
        'p_object_pool': p_object_pool,
        'seed_clone': seed_clone,
        'seed_mutations': seed_mutations
        }


read_json =  json.dumps(data)
print read_json.replace(",", "|")
