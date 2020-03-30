import os
import ranger.api
import subprocess
from ranger.api.commands import *

HOOK_INIT_OLD = ranger.api.hook_init


def hook_init(fm):
    def update_autojump(signal):
        subprocess.Popen(["autojump", "--add", signal.new.path])

    def update_autojump_file(signal):
        os.environ["IGNORE_INITIAL_AUTOJUMP"] = "1"
        subprocess.Popen(["autojump", "--add", fm.thisfile.path])

    fm.signal_bind('cd', update_autojump)
    fm.signal_bind('execute.before', update_autojump_file)
    HOOK_INIT_OLD(fm)


ranger.api.hook_init = hook_init


class j(Command):
    """:j

    Uses autojump to set the current directory.
    """

    def execute(self):
        path = subprocess.check_output(["autojump", self.arg(1)])
        path = path.decode("utf-8", "ignore")
        path = path.rstrip('\n')
        if os.path.isdir(path):
            self.fm.execute_console("cd " + path)
        elif os.path.isfile(path):
            self.fm.execute_console("edit " + path)
