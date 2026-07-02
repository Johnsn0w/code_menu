import yaml, json
from dataclasses import dataclass
import pathlib
from textwrap import dedent
import os
from pprint import pprint as print

@dataclass
class Command:
    name:       str
    command:    str
    tags:       list


@dataclass
class Paths:
    export_dir = "./exported/"
    if not os.path.exists(export_dir):
        os.makedirs(export_dir)
    bash = export_dir + "_bash"
    ps   = "./poweshell/_ps"

def replace_spaces(_string):
    return _string.replace(" ", "_")

class App:
    def __init__(self):
        with open("db.yaml", "r") as db_file:
            self.db = yaml.safe_load(db_file)
        self.commands = []
        for k, v in self.db.items():
            self.commands.append(
                Command(name=k, command=v["command"], tags=v.get("tags", [])))
        self.test()
        print(self.db)


    def test(self):
        # print(self.commands)
        self.export_to_bash_functions()
        self.export_to_json()
        pass

    def export_to_json(self):
        with open(PATHS.ps, "w") as file:
            file.write(json.dumps(self.db, indent=2))

    def export_to_bash_functions(self):
        bash_cmds: list[Command] = [
            cmd for cmd in self.commands if "bash" in cmd.tags]

        with open(PATHS.bash, "w", newline="\n") as file:
            file.write("#!/usr/bin/env bash\n\n")
            file.write(f'function_names=("{'" "'.join([replace_spaces(cmd.name) for cmd in bash_cmds])}")\n')
            # `eval ${function_names[1]}`  execute item of array
            for bash_cmd in bash_cmds:
                file.write(
                    dedent(
                        f"""    
                        {replace_spaces(bash_cmd.name)}(){{
                        {bash_cmd.command}
                        }}
                        """
                    )
                )


if __name__ == "__main__":
    PATHS = Paths()
    app = App()
