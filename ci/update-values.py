import yaml
import sys
import os.path

valuefile=os.path.abspath(sys.argv[1])
datafile=os.path.abspath(sys.argv[2])
outputfile=valuefile

# Reference https://stackoverflow.com/a/15423007
# How can I control what scalar form PyYAML uses for my data
def should_use_block(value):
    for c in u"\u000a\u000d\u001c\u001d\u001e\u0085\u2028\u2029":
        if c in value:
            return True
    return False

def my_represent_scalar(self, tag, value, style=None):
    if style is None:
        if should_use_block(value):
             style='|'
        else:
            style = self.default_style

    node = yaml.representer.ScalarNode(tag, value, style=style)
    if self.alias_key is not None:
        self.represented_objects[self.alias_key] = node
    return node

with open(valuefile, mode='r') as f:
    result = yaml.load(f, Loader=yaml.FullLoader)

with open(datafile, mode='r') as f:
    data = f.read()

comment = "# This block is generated from 'helm/primehub/jupyterhub_primehub.py'"
result['jupyterhub']['hub']['extraConfig']['primehub'] = '%s\n\n%s' % (comment, data)
yaml.representer.BaseRepresenter.represent_scalar = my_represent_scalar
output = yaml.dump(result, allow_unicode=True)

with open(outputfile, mode='w') as f:
    f.write(output)



