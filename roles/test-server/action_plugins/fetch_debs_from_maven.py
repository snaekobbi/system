from ansible.plugins.action import ActionBase

import os
import subprocess

class ActionModule(ActionBase):
    def run(self, tmp=None, task_vars=None):
        if task_vars is None:
            task_vars = dict()
        result = super(ActionModule, self).run(tmp, task_vars)
        cwd = os.path.join(os.path.dirname(os.path.realpath(__file__)), '../files/debs')
        p = subprocess.Popen(['make','debs'], cwd=cwd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        out, err = p.communicate()
        if p.returncode == 0:
            if out == 'make: Nothing to be done for `debs''.':
                result['changed'] = False
        else:
            result['failed'] = True
            result['msg'] = err
        return result
