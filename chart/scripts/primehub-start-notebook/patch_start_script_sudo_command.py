def patch_sudo_command(script_path):
    with open(script_path, "r") as f:
        lines = f.readlines()
        outputs = []
        for line in lines:
            if 'exec sudo -E' in line and 'LD_LIBRARY_PATH' not in line:
                line = line.replace(r'PATH=$PATH', r"""PATH=$PATH LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}""")
                outputs.append(line)
            else:
                outputs.append(line)
        patched_content = "".join(outputs)

    with open(script_path, "w") as f:
        f.write(patched_content)


if __name__ == '__main__':
    patch_sudo_command('/usr/local/bin/start.sh')
