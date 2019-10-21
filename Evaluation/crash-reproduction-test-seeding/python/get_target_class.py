import sys
import os


## input arguments
project=sys.argv[1]
case=sys.argv[2]
frame=sys.argv[3]
dir_path = os.path.dirname(os.path.realpath(__file__))
log_path= os.path.join(dir_path, "..", "..",  "crashes",project,case,case+".log")
##



log_file = open(log_path, "r")


counter = 0
for line in log_file:
    if counter == int(frame):
        splitted_line_1 = line.split("at ")
        splitted_line_1 = splitted_line_1[1].split("(")
        class_method=splitted_line_1[0]
        last_dot_index=class_method.rfind('.')
        target_class=class_method[:last_dot_index]
        print target_class
        break

    counter += 1
