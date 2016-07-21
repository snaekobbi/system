from ansible.errors import AnsibleError
from ansible.plugins.action import ActionBase

import hashlib
import os
import posixpath
import re
from shutil import copyfile
import subprocess
import urllib2

class ActionModule(ActionBase):
    def run(self, tmp=None, task_vars=None):
        result = super(ActionModule, self).run(tmp, task_vars)
        dest = self._task.args['dest']
        recipe = self._task.args['recipe']
        expected_md5 = recipe.get('md5', None)
        if not os.path.exists(dest):
            if not os.path.exists(os.path.dirname(dest)):
                os.makedirs(os.path.dirname(dest))
        elif os.path.isdir(dest):
            raise AnsibleError('dest must not point to a directory.', obj=self._task)
        else:
            if expected_md5:
                actual_md5 = hashlib.md5()
                chunk_size = 8192
                with open(dest, 'rb') as f:
                    for chunk in iter(lambda: f.read(chunk_size), ''):
                        actual_md5.update(chunk)
                if not actual_md5.hexdigest() == expected_md5:
                    os.remove(dest)
                else:
                    result['changed'] = False
                    return result
            else:
                result['changed'] = False
                return result
        recipe_type = recipe['type']
        if recipe_type == 'maven':
            coords = recipe['maven_coords']
            group_id = coords['g']
            artifact_id = coords['a']
            version = coords.get('v', recipe['version'])
            classifier = coords.get('c', None)
            extension = 'deb'
            for repo in task_vars['pipeline2_maven_repos']:
                url = posixpath.join(repo,
                                     group_id.replace('.', '/'),
                                     artifact_id,
                                     re.sub(r'-[0-9]\{8\}\.[0-9]\{6\}-[0-9][0-9]*', '-SNAPSHOT', version),
                                     artifact_id + '-' + version + ('-' + classifier if classifier else '') + '.' + extension)
                try:
                    response = urllib2.urlopen(url)
                    if response.code == 200:
                        chunk_size = 8192
                        with open(dest, 'w') as f:
                            while True:
                                chunk = response.read(chunk_size)
                                if not chunk:
                                    break
                                f.write(chunk)
                        maven_md5 = None
                        try:
                            response = urllib2.urlopen(url + '.md5')
                            if response.code == 200:
                                maven_md5 = response.read()
                        except Exception:
                            pass
                        if expected_md5 or maven_md5:
                            actual_md5 = hashlib.md5()
                            chunk_size = 8192
                            with open(dest, 'rb') as f:
                                for chunk in iter(lambda: f.read(chunk_size), ''):
                                    actual_md5.update(chunk)
                            actual_md5 = actual_md5.hexdigest()
                            for expected_md5 in [expected_md5, maven_md5]:
                                if expected_md5 and not actual_md5 == expected_md5:
                                    os.remove(dest)
                                    result['failed'] = True
                                    result['msg'] = 'Actual md5 checksum (' + actual_md5 + ') does not match expected (' + expected_md5 + ')'
                                    return result
                        result['changed'] = True
                        return result
                except Exception:
                    continue
            result['failed'] = True
            result['msg'] = 'Failed to download artifact'
            return result
        elif recipe_type == 'build':
            build_dir = recipe['build_dir']
            if os.path.isabs(build_dir):
                raise AnsibleError('build_dir must be a path relative to playbook_dir')
            build_command = recipe['build_command']
            if not isinstance(build_command, list):
                build_command = build_command.split()
            build_file = os.path.join(build_dir, recipe['build_file'])
            p = subprocess.Popen(build_command, cwd=build_dir, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            out, err = p.communicate()
            if p.returncode == 0:
                copyfile(build_file, dest)
                result['changed'] = True
            else:
                result['failed'] = True
                result['msg'] = 'Build failed: ' + err
            return result
        else:
            raise AnsibleError('Unknown recipe type: ' + recipe_type, obj=self._task)