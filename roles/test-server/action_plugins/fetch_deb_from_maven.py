from ansible.errors import AnsibleError
from ansible.plugins.action import ActionBase

import os
import posixpath
import re
import urllib2

class ActionModule(ActionBase):
    def run(self, tmp=None, task_vars=None):
        result = super(ActionModule, self).run(tmp, task_vars)
        files_dir = os.path.join(os.path.dirname(os.path.realpath(__file__)), '../files/')
        dest = self._task.args['dest']
        dest = os.path.join(files_dir, dest)
        if not os.path.exists(dest):
            if not os.path.exists(os.path.dirname(dest)):
                os.makedirs(os.path.dirname(dest))
        elif os.path.isdir(dest):
            raise AnsibleError("dest must not point to a directory.", obj=self._task)
        else:
            # TODO: redownload if cached artifact doesn't match provided checksum
            result['changed'] = False
            return result
        group_id = self._task.args['group_id']
        artifact_id = self._task.args['artifact_id']
        version = self._task.args['version']
        classifier = self._task.args['classifier']
        extension = 'deb'
        for repo in task_vars['pipeline2_maven_repos']:
            url = posixpath.join(repo,
                                 group_id.replace('.', '/'),
                                 artifact_id,
                                 re.sub(r'-[0-9]\{8\}\.[0-9]\{6\}-[0-9][0-9]*', '-SNAPSHOT', version),
                                 artifact_id + '-' + version + ('-' + classifier if classifier != '' else '') + '.' + extension)
            try:
                response = urllib2.urlopen(url)
                if response.code == 200:
                    with open(dest,'w') as f:
                        chunk_size = 8192
                        while True:
                            chunk = response.read(chunk_size)
                            if not chunk:
                                break
                            f.write(chunk)
                    # TODO: verify checksum
                    result['changed'] = True
                    return result
            except Exception:
                pass
        result['failed'] = True
        result['msg'] = "Failed to download artifact " + artifact_id
        return result
